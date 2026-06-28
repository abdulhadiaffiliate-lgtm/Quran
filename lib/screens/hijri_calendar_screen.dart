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
  int _monthOffset = 0; // months forward/back from the current month

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
    var todayMonthIndex = t.hijriMonthNumber! - 1;
    var todayYear = t.hijriYear!;
    var normalizedToday = today;

    if (normalizedToday < 1) {
      todayMonthIndex -= 1;
      if (todayMonthIndex < 0) {
        todayMonthIndex = 11;
        todayYear -= 1;
      }
      normalizedToday = _monthLengths[todayMonthIndex];
    } else if (normalizedToday > _monthLengths[todayMonthIndex]) {
      normalizedToday = 1;
      todayMonthIndex += 1;
      if (todayMonthIndex > 11) {
        todayMonthIndex = 0;
        todayYear += 1;
      }
    }

    // Apply the month navigation offset to get the month actually being
    // viewed, which may differ from the month containing "today".
    var monthIndex = todayMonthIndex + _monthOffset;
    var year = todayYear;
    while (monthIndex > 11) {
      monthIndex -= 12;
      year += 1;
    }
    while (monthIndex < 0) {
      monthIndex += 12;
      year -= 1;
    }

    final isViewingCurrentMonth = _monthOffset == 0;
    final daysInMonth = _monthLengths[monthIndex];
    final monthName = _hijriMonthNames[monthIndex];

    // Anchor: today's Gregorian date corresponds to normalizedToday in
    // the CURRENT Hijri month. When viewing a different month, we offset
    // by whole months' worth of days (using average month length) to
    // estimate the Gregorian dates for that month's grid.
    final now = DateTime.now();
    final monthsApart = (year - todayYear) * 12 + (monthIndex - todayMonthIndex);
    final estimatedDayShift = (monthsApart * 29.53).round();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppColors.gold,
                    onPressed: () => setState(() => _monthOffset--),
                  ),
                  Expanded(
                    child: Text(
                      '$monthName $year AH',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppColors.gold,
                    onPressed: () => setState(() => _monthOffset++),
                  ),
                ],
              ),
              if (!isViewingCurrentMonth) ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => setState(() => _monthOffset = 0),
                  child: const Text('Back to current month'),
                ),
              ],
              if (isViewingCurrentMonth) ...[
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
            final isToday = isViewingCurrentMonth && hijriDay == normalizedToday;
            // For the current month, anchor directly off today's real
            // date. For navigated months, apply the estimated whole-month
            // shift on top of that same anchor.
            final dayDelta = isViewingCurrentMonth
                ? hijriDay - normalizedToday
                : (hijriDay - normalizedToday) + estimatedDayShift;
            final gregorian = now.add(Duration(days: dayDelta));
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
