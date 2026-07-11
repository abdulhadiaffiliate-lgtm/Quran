import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../services/streak_service.dart';
import '../services/app_settings.dart';
import '../services/hadith_service.dart';
import '../models/hadith.dart';
import '../theme/app_colors.dart';
import '../utils/good_deeds.dart';
import '../widgets/goals_card.dart';
import 'emotions_screen.dart';
import 'quran_screen.dart';
import 'tasbih_screen.dart';
import 'qibla_screen.dart';

/// The main "Home" tab — an engaging daily dashboard showing the user's
/// streak, goals, daily hadith snippet, good deed, quick actions, and an
/// emotions shortcut. Prayer times live in the Prayer tab.
class DashboardScreen extends StatefulWidget {
  /// Passed from the shell so the dashboard can show the next prayer
  /// without duplicating the location/times fetch.
  final PrayerTimes? times;
  final int hijriOffset;

  const DashboardScreen({
    super.key,
    this.times,
    this.hijriOffset = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _streak = 0;
  String? _userName;
  Hadith? _hadith;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await StreakService.getCurrentStreak();
    final name = await AppSettings.getUserName();
    final hadith = await HadithService.getDailyHadith();
    if (!mounted) return;
    setState(() {
      _streak = s;
      _userName = name;
      _hadith = hadith;
    });
  }

  String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = _userName?.split(' ').first;
    final times = widget.times;
    final next = times?.nextPrayer(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [

            // ── Header ────────────────────────────────────────────────────
            Row(
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
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Here\'s your daily dashboard',
                        style: TextStyle(
                          fontSize: 13,
                          color: (isDark
                                  ? AppColors.textOnDarkSecondary
                                  : AppColors.textWarmDark)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Streak
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppColors.gold, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        '$_streak day${_streak == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Next prayer compact banner ─────────────────────────────────
            if (next != null) ...[
              _NextPrayerBanner(
                name: next.key,
                time: _fmt(next.value),
                remaining: next.value.difference(DateTime.now()),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
            ],

            // ── Quick actions ─────────────────────────────────────────────
            Row(
              children: [
                _QuickAction(
                  icon: Icons.menu_book_rounded,
                  label: 'Quran',
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const QuranScreen())),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.explore_rounded,
                  label: 'Qibla',
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const QiblaScreen())),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.radio_button_checked_rounded,
                  label: 'Tasbih',
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const TasbihScreen())),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.favorite_rounded,
                  label: 'Feelings',
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const EmotionsScreen())),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Goals ─────────────────────────────────────────────────────
            const GoalsCard(),

            const SizedBox(height: 16),

            // ── Daily hadith snippet ──────────────────────────────────────
            if (_hadith != null)
              _HadithSnippet(hadith: _hadith!, isDark: isDark),

            const SizedBox(height: 16),

            // ── Good deed ─────────────────────────────────────────────────
            _GoodDeedCard(isDark: isDark),

            const SizedBox(height: 16),

            // ── Emotions shortcut ─────────────────────────────────────────
            _EmotionsShortcut(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EmotionsScreen())),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Next Prayer Banner ───────────────────────────────────────────────────────

class _NextPrayerBanner extends StatelessWidget {
  final String name;
  final String time;
  final Duration remaining;
  final bool isDark;

  const _NextPrayerBanner({
    required this.name,
    required this.time,
    required this.remaining,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final label = h > 0 ? '${h}h ${m}m' : '${m}m';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEXT PRAYER',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'in $label',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Tile ────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.gold, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Daily Hadith Snippet ─────────────────────────────────────────────────────

class _HadithSnippet extends StatelessWidget {
  final Hadith hadith;
  final bool isDark;

  const _HadithSnippet({required this.hadith, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded,
                  color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'HADITH OF THE DAY',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sahih',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hadith.englishText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            hadith.reference ?? hadith.book,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Good Deed Card ───────────────────────────────────────────────────────────

class _GoodDeedCard extends StatelessWidget {
  final bool isDark;
  const _GoodDeedCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkSurfaceAlt]
              : [AppColors.lightSurfaceAlt, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
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

// ─── Emotions Shortcut ────────────────────────────────────────────────────────

class _EmotionsShortcut extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _EmotionsShortcut({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B4B4F), Color(0xFF2E6B70)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get a verse and hadith for your mood',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('😊 😔 😌',
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
