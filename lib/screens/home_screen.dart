import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/streak_service.dart';
import '../services/app_settings.dart';
import '../services/calc_method_resolver.dart';
import '../services/notification_service.dart';
import 'hijri_calendar_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/good_deeds.dart';

class HomeScreen extends StatefulWidget {
  final PrayerTimes? sharedTimes;
  final int hijriOffset;

  const HomeScreen({
    super.key,
    this.sharedTimes,
    this.hijriOffset = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  PrayerTimes? _times;
  String? _error;
  bool _loading = true;
  Timer? _ticker;
  int _streak = 0;
  int _hijriOffset = 0;
  String? _userName;

  // Subtle pulse on the leading dot of the arc
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Use times already fetched by the shell if available.
    if (widget.sharedTimes != null) {
      _times = widget.sharedTimes;
      _hijriOffset = widget.hijriOffset;
      _loading = false;
    } else {
      _load();
    }
    _loadStreak();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _times != null) setState(() {});
    });
  }

  @override
  void didUpdateWidget(HomeScreen old) {
    super.didUpdateWidget(old);
    // Sync when shell provides updated times.
    if (widget.sharedTimes != null && widget.sharedTimes != old.sharedTimes) {
      setState(() {
        _times = widget.sharedTimes;
        _hijriOffset = widget.hijriOffset;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStreak() async {
    await StreakService.recordOpen();
    final s = await StreakService.getCurrentStreak();
    final name = await AppSettings.getUserName();
    if (mounted) setState(() { _streak = s; _userName = name; });
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final offset = await AppSettings.getHijriOffset();
    if (mounted) setState(() => _hijriOffset = offset);
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
        final detected = CalcMethodResolver.resolveFromCoordinates(lat, lng);
        await AppSettings.setCalcMethod(detected);
        await AppSettings.setCalcMethodAutoDetected(true);
      }
      if (await AppSettings.isHijriOffsetAutoDetected() &&
          CalcMethodResolver.isSouthAsia(lat, lng)) {
        await AppSettings.setHijriOffset(-1);
        if (mounted) setState(() => _hijriOffset = -1);
      }
      final method = await AppSettings.getCalcMethod();
      final times = await PrayerService.getTodayTimings(
        latitude: lat, longitude: lng, method: method,
      );
      if (!mounted) return;
      setState(() { _times = times; _loading = false; });
      NotificationService.schedulePrayers(times);
      NotificationService.scheduleDailyReminders();
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
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
    return ListView(children: [
      const SizedBox(height: 140),
      Icon(Icons.location_off_rounded,
          size: 56, color: AppColors.gold.withValues(alpha: 0.7)),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(_error ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge),
      ),
      const SizedBox(height: 20),
      Center(
        child: FilledButton(onPressed: _load, child: const Text('Try again')),
      ),
    ]);
  }

  Widget _buildContent() {
    final times = _times!;
    final now = DateTime.now();
    final next = times.nextPrayer(now);

    // Progress between previous prayer and next.
    final ordered = times.ordered.where((e) => e.key != 'Sunrise').toList();
    DateTime prevTime = times.fajr.subtract(const Duration(hours: 6));
    for (final p in ordered) {
      if (p.value.isBefore(next.value) && p.value.isBefore(now)) {
        prevTime = p.value;
      }
    }
    final totalSec = next.value.difference(prevTime).inSeconds;
    final elapsedSec = now.difference(prevTime).inSeconds;
    final progress = totalSec > 0 ? (elapsedSec / totalSec).clamp(0.0, 1.0) : 0.0;

    final remaining = next.value.difference(now);
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;
    final remainingLabel = h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = _userName?.split(' ').first;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName != null
                          ? 'Assalamu Alaikum, $firstName'
                          : 'Assalamu Alaikum',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => HijriCalendarScreen(times: times),
                      )),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              size: 13, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(
                            times.hijriDateWithOffset(_hijriOffset),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Streak badge — always visible
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_streak day${_streak == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 22),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        // ── Premium arc ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => _ArcCard(
              progress: progress,
              nextPrayerName: next.key,
              remainingLabel: remainingLabel,
              nextTimeLabel: _fmt(next.value),
              pulseScale: _pulse.value,
              isDark: isDark,
            ),
          ),
        ),

        // ── Prayer times ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _PrayerListCard(
            times: times,
            nextName: next.key,
            now: now,
            fmt: _fmt,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:${m} ${t.hour < 12 ? 'AM' : 'PM'}';
  }
}

// ─── Premium Arc Card ────────────────────────────────────────────────────────

class _ArcCard extends StatelessWidget {
  final double progress;
  final String nextPrayerName;
  final String remainingLabel;
  final String nextTimeLabel;
  final double pulseScale;
  final bool isDark;

  const _ArcCard({
    required this.progress,
    required this.nextPrayerName,
    required this.remainingLabel,
    required this.nextTimeLabel,
    required this.pulseScale,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkSurfaceAlt]
              : [Colors.white, AppColors.lightSurfaceAlt],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealPrimary.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(260, 260),
                  painter: _ArcPainter(
                    progress: progress,
                    isDark: isDark,
                    pulseScale: pulseScale,
                  ),
                ),
                Positioned(
                  top: 28,
                  child: Column(
                    children: [
                      Text(
                        nextPrayerName.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        remainingLabel,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          height: 1.0,
                          color: isDark
                              ? AppColors.textOnDarkPrimary
                              : AppColors.textWarmDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 13,
                              color: (isDark
                                      ? AppColors.textOnDarkSecondary
                                      : AppColors.textWarmDark)
                                  .withValues(alpha: 0.55)),
                          const SizedBox(width: 4),
                          Text(
                            nextTimeLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: (isDark
                                      ? AppColors.textOnDarkSecondary
                                      : AppColors.textWarmDark)
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Text(
                    'Time remaining',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: (isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textWarmDark)
                          .withValues(alpha: 0.4),
                    ),
                  ),
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
  final double pulseScale;
  _ArcPainter({
    required this.progress,
    required this.isDark,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.80;
    final r = size.width * 0.46;

    const startAngle = math.pi * 0.85;
    const sweepTotal = math.pi * 1.30;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle, sweepTotal, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..color = (isDark
                ? AppColors.tealPrimaryLight
                : AppColors.tealPrimary)
            .withValues(alpha: 0.18),
    );

    if (progress <= 0.005) return;

    final clampedP = progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Gradient fill
    canvas.drawArc(
      rect, startAngle, sweepTotal * clampedP, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepTotal,
          colors: const [AppColors.goldLight, AppColors.gold],
        ).createShader(rect),
    );

    // Pulsing dot at leading edge
    final endAngle = startAngle + sweepTotal * clampedP;
    final dx = cx + r * math.cos(endAngle);
    final dy = cy + r * math.sin(endAngle);
    final dotBase = 7.0;

    // Outer glow
    canvas.drawCircle(
      Offset(dx, dy),
      dotBase * pulseScale * 1.6,
      Paint()..color = AppColors.gold.withValues(alpha: 0.2),
    );
    // Solid dot
    canvas.drawCircle(
      Offset(dx, dy),
      dotBase,
      Paint()..color = AppColors.gold,
    );
    // White center
    canvas.drawCircle(
      Offset(dx, dy),
      4.0,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress ||
      old.isDark != isDark ||
      old.pulseScale != pulseScale;
}

// ─── Prayer List Card ────────────────────────────────────────────────────────

class _PrayerListCard extends StatelessWidget {
  final PrayerTimes times;
  final String nextName;
  final DateTime now;
  final String Function(DateTime) fmt;

  const _PrayerListCard({
    required this.times,
    required this.nextName,
    required this.now,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = times.ordered;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                const Icon(Icons.mosque_rounded,
                    size: 16, color: AppColors.gold),
                const SizedBox(width: 8),
                const Text(
                  'Prayer times',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.gold.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...items.map((e) {
            final isNext = e.key == nextName;
            final isPast = e.value.isBefore(now) && !isNext;
            final isSunrise = e.key == 'Sunrise';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isNext
                    ? AppColors.gold.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -1),
                leading: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isNext
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : (isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSunrise
                        ? Icons.wb_twilight_rounded
                        : Icons.mosque_rounded,
                    size: 17,
                    color: isNext
                        ? AppColors.gold
                        : isPast
                            ? (isDark
                                ? AppColors.textOnDarkSecondary
                                : AppColors.textWarmDark)
                                .withValues(alpha: 0.35)
                            : AppColors.tealPrimaryLight,
                  ),
                ),
                title: Text(
                  e.key,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                    color: isNext
                        ? AppColors.gold
                        : isPast
                            ? (isDark
                                ? AppColors.textOnDarkSecondary
                                : AppColors.textWarmDark)
                                .withValues(alpha: 0.35)
                            : null,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isNext)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            color: AppColors.darkBg,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    Text(
                      fmt(e.value),
                      style: TextStyle(
                        fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                        color: isNext
                            ? AppColors.gold
                            : isPast
                                ? (isDark
                                    ? AppColors.textOnDarkSecondary
                                    : AppColors.textWarmDark)
                                    .withValues(alpha: 0.35)
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ─── Good Deed Card ──────────────────────────────────────────────────────────

class _GoodDeedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkSurfaceAlt]
              : [AppColors.lightSurfaceAlt, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.volunteer_activism_rounded,
                color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ONE GOOD THING TODAY',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  GoodDeeds.todays(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
