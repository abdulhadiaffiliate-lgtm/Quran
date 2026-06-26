import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/streak_service.dart';
import '../services/app_settings.dart';
import '../services/calc_method_resolver.dart';
import '../theme/app_colors.dart';
import '../utils/good_deeds.dart';
import '../widgets/countdown_arc.dart';
import '../widgets/goals_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTimes? _times;
  String? _error;
  bool _loading = true;
  Timer? _ticker;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _loadStreak();
    // Refresh the countdown display every second.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _times != null) setState(() {});
    });
  }

  Future<void> _loadStreak() async {
    final s = await StreakService.getCurrentStreak();
    if (mounted) setState(() => _streak = s);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      double lat, lng;
      try {
        final pos = await LocationService.getCurrentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
      } on LocationException {
        final cached = await LocationService.getCachedLocation();
        if (cached == null) rethrow;
        lat = cached.lat;
        lng = cached.lng;
      }
      if (!await AppSettings.isCalcMethodAutoDetected()) {
        final detected =
            CalcMethodResolver.resolveFromCoordinates(lat, lng);
        await AppSettings.setCalcMethod(detected);
        await AppSettings.setCalcMethodAutoDetected(true);
      }
      final method = await AppSettings.getCalcMethod();
      final times = await PrayerService.getTodayTimings(
        latitude: lat,
        longitude: lng,
        method: method,
      );
      if (!mounted) return;
      setState(() {
        _times = times;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.location_off_rounded,
            size: 56, color: AppColors.gold.withValues(alpha: 0.7)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _error ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton(
            onPressed: _load,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final times = _times!;
    final now = DateTime.now();
    final next = times.nextPrayer(now);

    // Compute progress from the previous prayer to the next.
    final ordered = times.ordered.where((e) => e.key != 'Sunrise').toList();
    DateTime prevTime = times.fajr.subtract(const Duration(hours: 6));
    for (final p in ordered) {
      if (p.value.isBefore(next.value) && p.value.isBefore(now)) {
        prevTime = p.value;
      }
    }
    final total = next.value.difference(prevTime).inSeconds;
    final elapsed = now.difference(prevTime).inSeconds;
    final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;

    final remaining = next.value.difference(now);
    final remainingLabel =
        '${remaining.inHours.toString().padLeft(2, '0')}:'
        '${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalamu Alaikum',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  times.hijriDate,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_streak > 0) _buildStreakBadge(),
        CountdownArc(
          progress: progress,
          nextPrayerName: next.key,
          remainingLabel: remainingLabel,
          nextTimeLabel: _fmt(next.value),
        ),
        const SizedBox(height: 16),
        _buildPrayerList(times, next.key),
        const SizedBox(height: 16),
        const GoalsCard(),
        const SizedBox(height: 20),
        _buildDailyGoodDeed(),
      ],
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: AppColors.gold, size: 18),
          const SizedBox(width: 6),
          Text(
            '$_streak day streak',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList(PrayerTimes times, String nextName) {
    final items = times.ordered;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: items.map((e) {
            final isNext = e.key == nextName;
            final isSunrise = e.key == 'Sunrise';
            return Container(
              decoration: BoxDecoration(
                color: isNext
                    ? AppColors.gold.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: ListTile(
                dense: true,
                leading: Icon(
                  isSunrise
                      ? Icons.wb_twilight_rounded
                      : Icons.mosque_rounded,
                  color: isNext
                      ? AppColors.gold
                      : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.6),
                  size: 20,
                ),
                title: Text(
                  e.key,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                    color: isNext ? AppColors.gold : null,
                  ),
                ),
                trailing: Text(
                  _fmt(e.value),
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                    color: isNext ? AppColors.gold : null,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDailyGoodDeed() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.volunteer_activism_rounded,
                color: AppColors.gold, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'One good thing today',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    GoodDeeds.todays(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}
