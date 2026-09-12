import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';

/// Draws the map's pins and cluster bubbles.
///
/// Google's default red pin gives no sense of the app and, at 300+ cafés,
/// no sense of density either. These are painted to the palette and cached,
/// since a bitmap is only ever a function of its inputs.
abstract final class MapMarkers {
  static final _cache = <String, BitmapDescriptor>{};

  /// The glyph inside every pin.
  ///
  /// The same cup the Home tab uses, so a pin on the map and the tab that
  /// leads to cafés are recognisably the same thing. Drawn from the bundled
  /// MaterialIcons font rather than an asset: it is already in the binary, it
  /// is a vector at any pixel ratio, and it cannot fall out of sync with the
  /// tab bar.
  static const _cupGlyph = Icons.coffee_rounded;

  /// A café pin, [selected] when it is the one whose card is open.
  ///
  /// [open] tints the cup and its ring, so which cafés are serving right now
  /// is readable without tapping anything.
  static Future<BitmapDescriptor> pin({
    required bool open,
    required bool selected,
    required double devicePixelRatio,
  }) {
    return _cached('pin-$open-$selected-$devicePixelRatio', () async {
      // The selected pin is drawn half again as large. At 300 pins a selected
      // one that is merely a different colour is genuinely hard to find again
      // after panning.
      final width = selected ? 46.0 : 36.0;
      final height = selected ? 60.0 : 48.0;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final scale = devicePixelRatio;
      canvas.scale(scale);

      // Selected inverts the fill so the cup reads as lit rather than outlined.
      final bodyColour = selected ? AppColors.accent : AppColors.cardDark;
      final accentColour = open ? AppColors.accent : AppColors.onCardDisabled;
      final glyphColour = selected ? Colors.white : accentColour;

      final body = Paint()..color = bodyColour;
      final ring = Paint()
        ..color = selected ? AppColors.cream : accentColour
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 3 : 2.5;

      // Teardrop: a circle with a tail down to the anchor point.
      final centre = Offset(width / 2, width / 2);
      final radius = width / 2 - 2;

      final tail = Path()
        ..moveTo(width / 2 - 7, width / 2 + 8)
        ..quadraticBezierTo(width / 2, height, width / 2, height)
        ..quadraticBezierTo(width / 2, height, width / 2 + 7, width / 2 + 8)
        ..close();

      canvas
        ..drawShadow(
          Path()..addOval(Rect.fromCircle(center: centre, radius: radius)),
          AppColors.shadow,
          2,
          false,
        )
        ..drawPath(tail, body)
        ..drawCircle(centre, radius, body)
        ..drawCircle(centre, radius, ring);

      _drawGlyph(
        canvas,
        glyph: _cupGlyph,
        centre: centre,
        size: radius * 1.15,
        colour: glyphColour,
      );

      return _toBitmap(recorder, width, height, scale);
    });
  }

  /// Paints an icon glyph centred on [centre].
  static void _drawGlyph(
    Canvas canvas, {
    required IconData glyph,
    required Offset centre,
    required double size,
    required Color colour,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(glyph.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: glyph.fontFamily,
          package: glyph.fontPackage,
          color: colour,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(centre.dx - painter.width / 2, centre.dy - painter.height / 2),
    );
  }

  /// A cluster bubble whose size and shade grow with the count, so density is
  /// legible without reading the numbers.
  static Future<BitmapDescriptor> cluster({
    required int count,
    required double devicePixelRatio,
  }) {
    final bucket = _bucket(count);

    return _cached('cluster-$bucket-$count-$devicePixelRatio', () async {
      final diameter = switch (bucket) {
        0 => 46.0,
        1 => 54.0,
        2 => 62.0,
        _ => 72.0,
      };
      final fill = switch (bucket) {
        0 => AppColors.accent,
        1 => AppColors.brownWarm,
        2 => AppColors.brownDeep,
        _ => AppColors.brownDarkest,
      };

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final scale = devicePixelRatio;
      canvas.scale(scale);

      final centre = Offset(diameter / 2, diameter / 2);

      canvas
        // A soft halo reads as "several pins underneath".
        ..drawCircle(
          centre,
          diameter / 2,
          Paint()..color = fill.withValues(alpha: 0.25),
        )
        ..drawCircle(centre, diameter / 2 - 5, Paint()..color = fill)
        ..drawCircle(
          centre,
          diameter / 2 - 5,
          Paint()
            ..color = AppColors.cream.withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );

      final label = count > 999 ? '999+' : '$count';
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: diameter * 0.32,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(centre.dx - painter.width / 2, centre.dy - painter.height / 2),
      );

      return _toBitmap(recorder, diameter, diameter, scale);
    });
  }

  static int _bucket(int count) {
    if (count < 10) return 0;
    if (count < 50) return 1;
    if (count < 200) return 2;
    return 3;
  }

  static Future<BitmapDescriptor> _cached(
    String key,
    Future<BitmapDescriptor> Function() build,
  ) async {
    final hit = _cache[key];
    if (hit != null) return hit;
    return _cache[key] = await build();
  }

  static Future<BitmapDescriptor> _toBitmap(
    ui.PictureRecorder recorder,
    double width,
    double height,
    double scale,
  ) async {
    final image = await recorder.endRecording().toImage(
          (width * scale).round(),
          (height * scale).round(),
        );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: width,
      height: height,
    );
  }
}
