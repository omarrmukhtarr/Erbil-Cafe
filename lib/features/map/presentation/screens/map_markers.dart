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

  /// A café pin. [open] tints the dot so open cafés stand out at a glance.
  static Future<BitmapDescriptor> pin({
    required bool open,
    required double devicePixelRatio,
  }) {
    return _cached('pin-$open-$devicePixelRatio', () async {
      const width = 34.0;
      const height = 46.0;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final scale = devicePixelRatio;
      canvas.scale(scale);

      final body = Paint()..color = AppColors.cardDark;
      final ring = Paint()
        ..color = open ? AppColors.accent : AppColors.onCardDisabled
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      // Teardrop: a circle with a tail down to the anchor point.
      const centre = Offset(width / 2, width / 2);
      const radius = width / 2 - 2;

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
        ..drawCircle(centre, radius, ring)
        ..drawCircle(centre, 5, Paint()..color = AppColors.cream);

      return _toBitmap(recorder, width, height, scale);
    });
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
