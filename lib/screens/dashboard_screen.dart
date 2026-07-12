import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/prayer_times.dart';
import '../services/streak_service.dart';
import '../services/app_settings.dart';
import '../services/hadith_service.dart';
import '../models/hadith.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/good_deeds.dart';
import '../widgets/goals_card.dart';
import 'emotions_screen.dart';
import 'quran_screen.dart';
import 'tasbih_screen.dart';
import 'qibla_screen.dart';

// ─── Story data ───────────────────────────────────────────────────────────────

class _Story {
  final String arabic;
  final String english;
  final String reference;
  final List<Color> gradient;
  final String theme;

  const _Story({
    required this.arabic,
    required this.english,
    required this.reference,
    required this.gradient,
    required this.theme,
  });
}

// 20 curated ayat from verified bundled Quran data, each with a
// distinct gradient. Rotates deterministically by day-of-year.
const _stories = [
  _Story(
    arabic: 'فَإِنَّ مَعَ ٱلۡعُسۡرِ يُسۡرًا',
    english: 'For indeed, with hardship will be ease.',
    reference: 'Quran 94:5',
    theme: 'Hope',
    gradient: [Color(0xFF1a3a5c), Color(0xFF0d6e6e)],
  ),
  _Story(
    arabic: 'وَلَسَوۡفَ يُعۡطِيكَ رَبُّكَ فَتَرۡضَىٰٓ',
    english: 'Your Lord will give you, and you will be satisfied.',
    reference: 'Quran 93:5',
    theme: 'Promise',
    gradient: [Color(0xFF2d1b69), Color(0xFF11998e)],
  ),
  _Story(
    arabic: 'أَلَا بِذِكۡرِ ٱللَّهِ تَطۡمَئِنُّ ٱلۡقُلُوبُ',
    english: 'Verily, in the remembrance of Allah do hearts find rest.',
    reference: 'Quran 13:28',
    theme: 'Peace',
    gradient: [Color(0xFF0d2b1a), Color(0xFF1a6b3c)],
  ),
  _Story(
    arabic: 'وَيَرۡزُقۡهُ مِنۡ حَيۡثُ لَا يَحۡتَسِبُۚ',
    english: 'Allah will provide for him from where he does not expect.',
    reference: 'Quran 65:3',
    theme: 'Trust',
    gradient: [Color(0xFF4a1942), Color(0xFF8b0000)],
  ),
  _Story(
    arabic: 'لَا يُكَلِّفُ ٱللَّهُ نَفۡسًا إِلَّا وُسۡعَهَا',
    english:
        'Allah does not burden a soul beyond what it can bear.',
    reference: 'Quran 2:286',
    theme: 'Relief',
    gradient: [Color(0xFF1c3c6e), Color(0xFF2980b9)],
  ),
  _Story(
    arabic: 'إِنَّ مَعَ ٱلۡعُسۡرِ يُسۡرٗا',
    english: 'Indeed, with hardship will be ease.',
    reference: 'Quran 94:6',
    theme: 'Ease',
    gradient: [Color(0xFF6b3c2a), Color(0xFFc0744c)],
  ),
  _Story(
    arabic: 'وَمَا خَلَقۡتُ ٱلۡجِنَّ وَٱلۡإِنسَ إِلَّا لِيَعۡبُدُونِ',
    english:
        'I did not create the jinn and mankind except to worship Me.',
    reference: 'Quran 51:56',
    theme: 'Purpose',
    gradient: [Color(0xFF2c3e50), Color(0xFF3d6b6b)],
  ),
  _Story(
    arabic: 'فَٱذۡكُرُونِيٓ أَذۡكُرۡكُمۡ',
    english: 'Remember Me; I will remember you.',
    reference: 'Quran 2:152',
    theme: 'Dhikr',
    gradient: [Color(0xFF0d3b2e), Color(0xFF1a8a6b)],
  ),
  _Story(
    arabic:
        'قُلۡ يَٰعِبَادِيَ ٱلَّذِينَ أَسۡرَفُواْ لَا تَقۡنَطُواْ مِن رَّحۡمَةِ ٱللَّهِ',
    english:
        'Do not despair of the mercy of Allah.',
    reference: 'Quran 39:53',
    theme: 'Mercy',
    gradient: [Color(0xFF1a0d2e), Color(0xFF6b3fa0)],
  ),
  _Story(
    arabic:
        'وَٱسۡتَعِينُواْ بِٱلصَّبۡرِ وَٱلصَّلَوٰةِ',
    english:
        'Seek help through patience and prayer.',
    reference: 'Quran 2:45',
    theme: 'Strength',
    gradient: [Color(0xFF1a3a1a), Color(0xFF4a7c59)],
  ),
  _Story(
    arabic:
        'وَلَا تَهِنُواْ وَلَا تَحۡزَنُواْ وَأَنتُمُ ٱلۡأَعۡلَوۡنَ',
    english:
        'Do not weaken, do not grieve — you will be superior.',
    reference: 'Quran 3:139',
    theme: 'Courage',
    gradient: [Color(0xFF3d1a00), Color(0xFF8b5e3c)],
  ),
  _Story(
    arabic:
        'لَئِن شَكَرۡتُمۡ لَأَزِيدَنَّكُمۡ',
    english:
        'If you are grateful, I will surely increase you.',
    reference: 'Quran 14:7',
    theme: 'Gratitude',
    gradient: [Color(0xFF1a2a00), Color(0xFF5a8a20)],
  ),
  _Story(
    arabic:
        'حَسۡبُنَا ٱللَّهُ وَنِعۡمَ ٱلۡوَكِيلُ',
    english:
        'Allah is sufficient for us, and He is the best Disposer of affairs.',
    reference: 'Quran 3:173',
    theme: 'Reliance',
    gradient: [Color(0xFF001a3d), Color(0xFF005b8a)],
  ),
  _Story(
    arabic:
        'سَابِقُوٓاْ إِلَىٰ مَغۡفِرَةٖ مِّن رَّبِّكُمۡ',
    english:
        'Race toward forgiveness from your Lord.',
    reference: 'Quran 57:21',
    theme: 'Race',
    gradient: [Color(0xFF2a1a00), Color(0xFF8b6000)],
  ),
  _Story(
    arabic:
        'قُل لَّن يُصِيبَنَآ إِلَّا مَا كَتَبَ ٱللَّهُ لَنَا',
    english:
        'Nothing will befall us except what Allah has decreed for us.',
    reference: 'Quran 9:51',
    theme: 'Qadar',
    gradient: [Color(0xFF1a0d00), Color(0xFF5a3a1a)],
  ),
  _Story(
    arabic:
        'وَبَشِّرِ ٱلصَّـٰبِرِينَ',
    english:
        'Give glad tidings to the patient.',
    reference: 'Quran 2:155',
    theme: 'Patience',
    gradient: [Color(0xFF002a1a), Color(0xFF006b4a)],
  ),
  _Story(
    arabic:
        'رَبَّنَآ ءَاتِنَا مِن لَّدُنكَ رَحۡمَةٗ',
    english:
        'Our Lord, grant us mercy from Yourself.',
    reference: 'Quran 18:10',
    theme: 'Dua',
    gradient: [Color(0xFF1a001a), Color(0xFF6b006b)],
  ),
  _Story(
    arabic:
        'مَنۡ عَمِلَ صَٰلِحٗا مِّن ذَكَرٍ أَوۡ أُنثَىٰ فَلَنُحۡيِيَنَّهُۥ حَيَوٰةٗ طَيِّبَةٗ',
    english:
        'Whoever does good, We will surely give him a good life.',
    reference: 'Quran 16:97',
    theme: 'Good Life',
    gradient: [Color(0xFF00261a), Color(0xFF00704a)],
  ),
  _Story(
    arabic:
        'وَبِٱلۡوَٰلِدَيۡنِ إِحۡسَٰنًا',
    english:
        'And to parents do good.',
    reference: 'Quran 4:36',
    theme: 'Parents',
    gradient: [Color(0xFF261a00), Color(0xFF6b5000)],
  ),
  _Story(
    arabic:
        'ٱصۡبِرُواْ وَصَابِرُواْ وَرَابِطُواْ وَٱتَّقُواْ ٱللَّهَ',
    english:
        'Persevere, endure, remain stationed, and fear Allah.',
    reference: 'Quran 3:200',
    theme: 'Steadfast',
    gradient: [Color(0xFF1a0a00), Color(0xFF5a2a10)],
  ),
];

_Story todaysStory() {
  final d = DateTime.now();
  final idx = (d.year * 365 + d.month * 31 + d.day) % _stories.length;
  return _stories[idx];
}

List<_Story> getStoryReel() {
  final d = DateTime.now();
  final start = (d.year * 365 + d.month * 31 + d.day) % _stories.length;
  final list = <_Story>[];
  for (int i = 0; i < _stories.length; i++) {
    list.add(_stories[(start + i) % _stories.length]);
  }
  return list;
}

// ─── Dashboard Screen ─────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  final PrayerTimes? times;
  final int hijriOffset;

  const DashboardScreen({super.key, this.times, this.hijriOffset = 0});

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
    setState(() { _streak = s; _userName = name; _hadith = hadith; });
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
    final next = widget.times?.nextPrayer(DateTime.now());
    final stories = getStoryReel();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : const Color(0xFFF5F0E8),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── Sticky header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName != null
                                ? 'Assalamu Alaikum,'
                                : 'Assalamu Alaikum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: (isDark
                                      ? AppColors.textOnDarkSecondary
                                      : AppColors.textWarmDark)
                                  .withValues(alpha: 0.55),
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (firstName != null)
                            Text(
                              firstName,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                color: isDark
                                    ? AppColors.textOnDarkPrimary
                                    : AppColors.textWarmDark,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Streak pill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 15)),
                              const SizedBox(width: 5),
                              Text(
                                '$_streak',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                ' days',
                                style: TextStyle(
                                  color: AppColors.gold
                                      .withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Story reel ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(22, 22, 22, 12),
                    child: Row(
                      children: [
                        Text(
                          'Ayah of the Day',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDark
                                ? AppColors.textOnDarkPrimary
                                : AppColors.textWarmDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Swipe →',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gold.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 22, right: 10),
                      itemCount: stories.length,
                      itemBuilder: (ctx, i) => _StoryCard(
                        story: stories[i],
                        isFirst: i == 0,
                        width: size.width * 0.72,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Next prayer ───────────────────────────────────────────────
            if (next != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(22, 20, 22, 0),
                  child: _NextPrayerCard(
                    name: next.key,
                    time: _fmt(next.value),
                    remaining: next.value.difference(DateTime.now()),
                    isDark: isDark,
                  ),
                ),
              ),

            // ── Quick actions ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                child: Row(
                  children: [
                    _QuickTile(
                      emoji: '📖',
                      label: 'Quran',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const QuranScreen())),
                    ),
                    const SizedBox(width: 10),
                    _QuickTile(
                      emoji: '🧭',
                      label: 'Qibla',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const QiblaScreen())),
                    ),
                    const SizedBox(width: 10),
                    _QuickTile(
                      emoji: '📿',
                      label: 'Tasbih',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TasbihScreen())),
                    ),
                    const SizedBox(width: 10),
                    _QuickTile(
                      emoji: '💭',
                      label: 'Feelings',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EmotionsScreen())),
                    ),
                  ],
                ),
              ),
            ),

            // ── Goals ──────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(22, 20, 22, 0),
                child: GoalsCard(),
              ),
            ),

            // ── Daily hadith ───────────────────────────────────────────────
            if (_hadith != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                  child: _HadithCard(
                      hadith: _hadith!, isDark: isDark),
                ),
              ),

            // ── Good deed ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: _GoodDeedCard(isDark: isDark),
              ),
            ),

            // ── Emotions ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(22, 16, 22, 32),
                child: _EmotionsBanner(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EmotionsScreen())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Story Card ───────────────────────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  final _Story story;
  final bool isFirst;
  final double width;

  const _StoryCard({
    required this.story,
    required this.isFirst,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _StoryFullView(story: story),
      ),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: story.gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: story.gradient.last.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle geometric pattern
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.06,
                child: Icon(Icons.star_of_david_rounded,
                    size: 140,
                    color: Colors.white),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      story.theme.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Arabic text
                  Text(
                    story.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.arabicStyle(
                      color: Colors.white,
                      fontSize: 19,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // English
                  Text(
                    story.english,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Footer
                  Row(
                    children: [
                      Text(
                        story.reference,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tap to read →',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Story Full View ──────────────────────────────────────────────────────────

class _StoryFullView extends StatelessWidget {
  final _Story story;
  const _StoryFullView({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: story.gradient,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(28, 32, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Theme pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  story.theme.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Arabic — large, breathing
              Text(
                story.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.9,
                ),
              ),

              const SizedBox(height: 20),

              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),

              const SizedBox(height: 20),

              // English translation
              Text(
                story.english,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 17,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                story.reference,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              // Share button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    final text =
                        '${story.arabic}\n\n"${story.english}"\n\n— ${story.reference}\n\nShared via SalahSync';
                    Share.share(text);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Share this Ayah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Next Prayer Card ─────────────────────────────────────────────────────────

class _NextPrayerCard extends StatelessWidget {
  final String name;
  final String time;
  final Duration remaining;
  final bool isDark;

  const _NextPrayerCard({
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.tealPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.mosque_rounded,
                    color: AppColors.tealPrimaryLight, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT PRAYER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: AppColors.tealPrimaryLight
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark
                            ? AppColors.textOnDarkPrimary
                            : AppColors.textWarmDark,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark
                          ? AppColors.textOnDarkPrimary
                          : AppColors.textWarmDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'in $label',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quick Tile ───────────────────────────────────────────────────────────────

class _QuickTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _QuickTile({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.9),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textOnDarkSecondary
                          : AppColors.textWarmDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hadith Card ──────────────────────────────────────────────────────────────

class _HadithCard extends StatelessWidget {
  final Hadith hadith;
  final bool isDark;
  const _HadithCard({required this.hadith, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'HADITH OF THE DAY',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
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
              const SizedBox(height: 14),
              Text(
                '"${hadith.englishText}"',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.65,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.textOnDarkPrimary
                      : AppColors.textWarmDark,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                '— ${hadith.reference ?? hadith.book}',
                style: const TextStyle(
                  color: AppColors.gold,
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

// ─── Good Deed Card ───────────────────────────────────────────────────────────

class _GoodDeedCard extends StatelessWidget {
  final bool isDark;
  const _GoodDeedCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1D2E1A), const Color(0xFF2A4020)]
              : [const Color(0xFFEEF4E8), const Color(0xFFDCEBD0)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🌿', style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ONE GOOD THING TODAY',
                  style: TextStyle(
                    color: AppColors.success.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  GoodDeeds.todays(),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textOnDarkPrimary
                        : AppColors.textWarmDark,
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

// ─── Emotions Banner ──────────────────────────────────────────────────────────

class _EmotionsBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _EmotionsBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D2B2E), Color(0xFF1B4B4F)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D2B2E).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOW ARE YOU FEELING?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find a verse & hadith\nfor your state of heart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
              child: const Column(
                children: [
                  Text('😔', style: TextStyle(fontSize: 20)),
                  Text('😌', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
