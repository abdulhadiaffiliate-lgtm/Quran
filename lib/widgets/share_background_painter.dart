import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ShareBackground { nightSky, geometricGold, mosqueSilhouette, tealGradient }

extension ShareBackgroundLabel on ShareBackground {
  String get label {
    switch (this) {
      case ShareBackground.nightSky:
        return 'Night Sky';
      case ShareBackground.geometricGold:
        return 'Geometric';
      case ShareBackground.mosqueSilhouette:
        return 'Mosque';
      case ShareBackground.tealGradient:
        return 'Simple Teal';
    }
  }
}

/// Paints a generated, Islamic-themed background for verse share cards.
/// No external images — everything is drawn with gradients, shapes, and
/// simple geometric patterns so there are no licensing concerns.
class ShareBackgroundPainter extends CustomPainter {
  final ShareBackground style;
  ShareBackgroundPainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case ShareBackground.nightSky:
        _paintNightSky(canvas, size);
        break;
      case ShareBackground.geometricGold:
        _paintGeometric(canvas, size);
        break;
      case ShareBackground.mosqueSilhouette:
        _paintMosque(canvas, size);
        break;
      case ShareBackground.tealGradient:
        _paintSimpleGradient(canvas, size);
        break;
    }
  }

  void _paintSimpleGradient(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.darkBg, AppColors.tealPrimary],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = gradient);
  }

  void _paintNightSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0B1B2B), AppColors.darkBg],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = gradient);

    // Scattered stars (deterministic so the image is stable).
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final rand = math.Random(42);
    for (int i = 0; i < 70; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height * 0.6;
      final r = rand.nextDouble() * 1.6 + 0.4;
      canvas.drawCircle(Offset(dx, dy), r, starPaint);
    }

    // A simple crescent moon.
    final moonCenter = Offset(size.width * 0.78, size.height * 0.18);
    final moonPaint = Paint()..color = AppColors.goldLight.withValues(alpha: 0.9);
    canvas.drawCircle(moonCenter, 26, moonPaint);
    final shadowPaint = Paint()..color = const Color(0xFF0B1B2B);
    canvas.drawCircle(
        moonCenter.translate(10, -6), 24, shadowPaint);
  }

  void _paintGeometric(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.darkBg, AppColors.darkSurface],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = gradient);

    // Repeating 8-point star / lattice motif, drawn faintly.
    final linePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const step = 70.0;
    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        _drawStarMotif(canvas, Offset(x, y), step * 0.45, linePaint);
      }
    }
  }

  void _drawStarMotif(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _paintMosque(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1B2E33), AppColors.darkBg],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = gradient);

    // Soft glow behind where the dome will sit.
    final glowPaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.55), 140, glowPaint);

    // Mosque silhouette: simple dome + two minarets, drawn as filled shapes.
    final silPaint = Paint()..color = const Color(0xFF0E1A1D);
    final baseY = size.height * 0.78;
    final path = Path();

    // Left minaret
    final lmX = size.width * 0.22;
    path.addRect(Rect.fromLTWH(lmX - 6, baseY - 170, 12, 170));
    path.addOval(Rect.fromCircle(center: Offset(lmX, baseY - 178), radius: 9));

    // Right minaret
    final rmX = size.width * 0.78;
    path.addRect(Rect.fromLTWH(rmX - 6, baseY - 170, 12, 170));
    path.addOval(Rect.fromCircle(center: Offset(rmX, baseY - 178), radius: 9));

    // Central dome on a rectangular base.
    final domeCenterX = size.width / 2;
    path.addRect(Rect.fromLTWH(domeCenterX - 90, baseY - 90, 180, 90));
    final domeRect =
        Rect.fromCircle(center: Offset(domeCenterX, baseY - 95), radius: 78);
    path.addArc(domeRect, math.pi, math.pi);
    path.addRect(
        Rect.fromLTWH(domeCenterX - 78, baseY - 95, 156, 20));

    // Small finial on top of the dome.
    path.addRect(Rect.fromLTWH(domeCenterX - 2, baseY - 200, 4, 30));
    path.addOval(
        Rect.fromCircle(center: Offset(domeCenterX, baseY - 205), radius: 5));

    canvas.drawPath(path, silPaint);

    // Ground line.
    final groundPaint = Paint()..color = const Color(0xFF0E1A1D);
    canvas.drawRect(
        Rect.fromLTWH(0, baseY, size.width, size.height - baseY),
        groundPaint);
  }

  @override
  bool shouldRepaint(covariant ShareBackgroundPainter oldDelegate) =>
      oldDelegate.style != style;
}
