import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../services/app_settings.dart';
import '../theme/app_colors.dart';

/// Shows a simple monthly calendar view, anchored on the current Hijri
/// month (adjusted by the user's manual offset), with each day labeled by
/// its Gregorian date underneath. This is an approximate calendar grid —
/// Hijri month lengths can vary by a day in reality, but this gives a
/// useful at-a-glance view.
class HijriCalendarScreen extends StatefulWidget {
  final PrayerTimes times;
  const HijriCalendarScreen({super.key, required this.times});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  int _offset = 0;
  bool _loading = true;

  static const _hijriMonthNames = [
    'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Shaban',
    'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah',
  ];
  static const _monthLengths = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final o = await AppSettings.getHijriOffset();
    if (!mounted) return;
    setState(() {
      _offset = o;
      _loading = false;
    });
  }

  Future<void> _setOffset(int value) async {
    await AppSettings.setHijriOffset(value);
    setState(() => _offset = value);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.times;
    final hasHijri =
        t.hijriDay != null && t.hijriMonthNumber != null && t.hijriYear != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Calendar')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : !hasHijri
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Calendar isn\'t available right now — try again once prayer times have loaded.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : _buildCalendar(t),
      ),
    );
  }

  Widget _buildCalendar(PrayerTimes t) {
    final today = t.hijriDay! + _offset;
    var monthIndex = t.hijriMonthNumber! - 1;
    var year = t.hijriYear!;
    var normalizedToday = today;

    if (normalizedToday < 1) {
      monthIndex -= 1;
      if (monthIndex < 0) {
        monthIndex = 11;
        year -= 1;
      }
      normalizedToday = _monthLengths[monthIndex];
    } else if (normalizedToday > _monthLengths[monthIndex]) {
      normalizedToday = 1;
      monthIndex += 1;
      if (monthIndex > 11) {
        monthIndex = 0;
        year += 1;
      }
    }

    final daysInMonth = _monthLengths[monthIndex];
    final monthName = _hijriMonthNames[monthIndex];

    // Anchor: today's Gregorian date corresponds to normalizedToday in
    // this Hijri month. Compute Gregorian dates for every day in the
    // month by offsetting from today.
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Offset control
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                '$monthName $year AH',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Today: $normalizedToday $monthName $year',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Moon-sighting can differ from this calculation by a day. Adjust if your local mosque announces a different date.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _offsetButton('-1 day', -1),
                  const SizedBox(width: 10),
                  _offsetButton('Today', 0),
                  const SizedBox(width: 10),
                  _offsetButton('+1 day', 1),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, i) {
            final hijriDay = i + 1;
            final isToday = hijriDay == normalizedToday;
            final gregorian = now.add(Duration(days: hijriDay - normalizedToday));
            return Container(
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.gold
                    : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$hijriDay',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isToday ? AppColors.darkBg : null,
                    ),
                  ),
                  Text(
                    '${gregorian.day}/${gregorian.month}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday
                          ? AppColors.darkBg.withValues(alpha: 0.7)
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _offsetButton(String label, int value) {
    final selected = _offset == value;
    return GestureDetector(
      onTap: () => _setOffset(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.tealPrimary
              : AppColors.tealPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.gold,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
