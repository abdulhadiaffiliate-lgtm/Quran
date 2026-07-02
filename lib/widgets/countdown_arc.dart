import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The centrepiece of the home screen: a soft arc that fills as time
/// progresses toward the next prayer, with a clean countdown in the
/// centre and the next prayer name displayed prominently.
class CountdownArc extends StatelessWidget {
  final double progress;       // 0.0 → 1.0
  final String nextPrayerName;
  final String remainingLabel; // e.g. "1h 23m"
  final String nextTimeLabel;  // e.g. "5:32 PM"

  const CountdownArc({
    super.key,
    required this.progress,
    required this.nextPrayerName,
    required this.remainingLabel,
    required this.nextTimeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Arc
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 200),
                  painter: _ArcPainter(
                    progress: progress,
                    isDark: isDark,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      nextPrayerName,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remainingLabel,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textOnDarkPrimary
                            : AppColors.textWarmDark,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'at $nextTimeLabel',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textOnDarkSecondary
                            : AppColors.textWarmDark.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _ArcPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.88);
    final radius = size.width * 0.44;

    // Arc: 210 degrees wide, opening like a dome
    const startAngle = math.pi * 0.85;
    const sweepAngle = math.pi * 1.30;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = (isDark ? AppColors.tealPrimaryLight : AppColors.tealPrimary)
            .withValues(alpha: 0.22),
    );

    // Progress fill
    if (progress > 0.005) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..shader = const SweepGradient(
            startAngle: 0,
            endAngle: math.pi * 2,
            colors: [AppColors.goldLight, AppColors.gold, AppColors.brownSecondary],
            stops: [0.0, 0.5, 1.0],
          ).createShader(rect),
      );

      // Dot at the leading edge of the arc
      final endAngle = startAngle + sweepAngle * progress.clamp(0.0, 1.0);
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        6,
        Paint()..color = AppColors.gold,
      );
      canvas.drawCircle(
        Offset(dotX, dotY),
        3.5,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
