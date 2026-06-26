import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The signature element of the home screen: a soft arc that fills as time
/// progresses from the previous prayer toward the next one, with the
/// remaining time shown in the center.
class CountdownArc extends StatelessWidget {
  final double progress; // 0.0 -> 1.0 toward the next prayer
  final String nextPrayerName;
  final String remainingLabel;
  final String nextTimeLabel;

  const CountdownArc({
    super.key,
    required this.progress,
    required this.nextPrayerName,
    required this.remainingLabel,
    required this.nextTimeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: CustomPaint(
            painter: _ArcPainter(progress: progress),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    remainingLabel,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'at $nextTimeLabel',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Next: $nextPrayerName',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = size.width * 0.42;

    // Arc spans 200 degrees, opening downward like a dome/horizon.
    const startAngle = math.pi * 0.9; // ~162°
    const sweepAngle = math.pi * 1.2; // 216°

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = AppColors.tealPrimary.withValues(alpha: 0.45);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [AppColors.gold, AppColors.goldLight],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
