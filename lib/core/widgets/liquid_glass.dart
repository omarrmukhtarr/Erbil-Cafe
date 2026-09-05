import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Apple's Liquid Glass material.
///
/// Flutter exposes no Liquid Glass API on any channel — stable, beta or master
/// — so this bridges to UIKit's own `UIGlassEffect` through a platform view.
/// That is the same material the system uses for its bars on iOS 26, including
/// its refraction and its response to whatever scrolls behind it, which a
/// Dart-side blur cannot reproduce.
///
/// Everywhere else (Android, web, iOS below 26) it degrades to a
/// [BackdropFilter] with the same tint, so callers need no platform branch.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    this.tint,
    this.style = LiquidGlassStyle.regular,
    this.interactive = false,
    this.fallbackBlur = 24,
    this.child,
    super.key,
  });

  /// Tints the glass. Keeps the material tied to the app's palette rather than
  /// reading as neutral system chrome.
  final Color? tint;

  final LiquidGlassStyle style;

  /// iOS 26 only: lets the material react to touches.
  final bool interactive;

  /// Blur sigma used where the native effect is unavailable.
  final double fallbackBlur;

  /// Drawn above the glass.
  final Widget? child;

  static const _viewType = 'erbilcafe/liquid_glass';

  static bool get _isSupported => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final glass = _isSupported
        ? UiKitView(
            viewType: _viewType,
            creationParams: <String, dynamic>{
              'style': style.name,
              'interactive': interactive,
              if (tint != null) 'tint': _argb(tint!),
            },
            creationParamsCodec: const StandardMessageCodec(),
            // The Flutter widget above owns hit testing; the glass is decor.
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          )
        : _FallbackGlass(tint: tint, blur: fallbackBlur);

    if (child == null) return glass;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(child: glass),
        child!,
      ],
    );
  }

  /// UIColor is rebuilt from an ARGB int on the native side.
  static int _argb(Color color) {
    int channel(double v) => (v * 255).round().clamp(0, 255);
    return (channel(color.a) << 24) |
        (channel(color.r) << 16) |
        (channel(color.g) << 8) |
        channel(color.b);
  }
}

enum LiquidGlassStyle {
  /// Standard glass — the default for bars and controls.
  regular,

  /// Clear glass, for content that should read through more strongly.
  clear,
}

class _FallbackGlass extends StatelessWidget {
  const _FallbackGlass({required this.tint, required this.blur});

  final Color? tint;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: ColoredBox(color: tint ?? Colors.transparent),
      ),
    );
  }
}
