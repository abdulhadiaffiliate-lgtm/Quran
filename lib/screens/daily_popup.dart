import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/daily_duas.dart';

/// A dialog shown once per day on app open, celebrating the login streak
/// and presenting the day's dua.
class DailyPopup extends StatelessWidget {
  final int streak;
  const DailyPopup({super.key, required this.streak});

  static Future<void> show(BuildContext context, int streak) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DailyPopup(streak: streak),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dua = DailyDuas.todays();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streak badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: AppColors.darkBg, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '$streak day streak',
                    style: const TextStyle(
                      color: AppColors.darkBg,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              streak <= 1
                  ? 'Good to have you here. Day one — let\'s go.'
                  : 'Maa shaa Allah — you keep showing up. Don\'t stop.',
              style: TextStyle(
                color: isDark
                    ? AppColors.textOnDarkSecondary
                    : AppColors.brownSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dua of the day',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              dua['arabic']!,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color!,
                fontSize: 24,
                height: 1.9,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              dua['translit']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: isDark
                    ? AppColors.textOnDarkSecondary
                    : AppColors.brownSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              dua['meaning']!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.5),
            ),
            if (dua['reference'] != null) ...[
              const SizedBox(height: 8),
              Text(
                dua['reference']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ameen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
