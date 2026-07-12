import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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
  final String urdu;
  final String reference;
  final List<Color> gradient;
  final String theme;

  const _Story({
    required this.arabic,
    required this.english,
    required this.urdu,
    required this.reference,
    required this.gradient,
    required this.theme,
  });
}

const _stories = [
  _Story(
    arabic: 'فَإِنَّ مَعَ ٱلۡعُسۡرِ يُسۡرًا',
    english: 'For indeed, with hardship will be ease.',
    urdu: 'پس حقیقت یہ ہے کہ تنگی کے ساتھ فراخی بھی ہے۔',
    reference: 'Quran 94:5',
    theme: 'Hope',
    gradient: [Color(0xFF1a3a5c), Color(0xFF0d6e6e)],
  ),
  _Story(
    arabic: 'وَلَسَوۡفَ يُعۡطِيكَ رَبُّكَ فَتَرۡضَىٰٓ',
    english: 'Your Lord will give you, and you will be satisfied.',
    urdu: 'اور عنقریب تمہارا رب تم کو اتنا دے گا کہ تم خوش ہو جاؤ گے۔',
    reference: 'Quran 93:5',
    theme: 'Promise',
    gradient: [Color(0xFF2d1b69), Color(0xFF11998e)],
  ),
  _Story(
    arabic: 'أَلَا بِذِكۡرِ ٱللَّهِ تَطۡمَئِنُّ ٱلۡقُلُوبُ',
    english: 'Verily, in the remembrance of Allah do hearts find rest.',
    urdu: 'سن لو! اللہ کے ذکر سے ہی دلوں کو اطمینان نصیب ہوتا ہے۔',
    reference: 'Quran 13:28',
    theme: 'Peace',
    gradient: [Color(0xFF0d2b1a), Color(0xFF1a6b3c)],
  ),
  _Story(
    arabic: 'وَيَرۡزُقۡهُ مِنۡ حَيۡثُ لَا يَحۡتَسِبُ',
    english: 'Allah will provide for him from where he does not expect.',
    urdu: 'اور اسے ایسے راستے سے رزق دے گا جدھر اس کا گمان بھی نہ جاتا ہو۔',
    reference: 'Quran 65:3',
    theme: 'Trust',
    gradient: [Color(0xFF4a1942), Color(0xFF8b0000)],
  ),
  _Story(
    arabic: 'لَا يُكَلِّفُ ٱللَّهُ نَفۡسًا إِلَّا وُسۡعَهَا',
    english: 'Allah does not burden a soul beyond what it can bear.',
    urdu: 'اللہ کسی متنفس پر اُس کی مقدرت سے بڑھ کر ذمہ داری کا بوجھ نہیں ڈالتا۔',
    reference: 'Quran 2:286',
    theme: 'Relief',
    gradient: [Color(0xFF1c3c6e), Color(0xFF2980b9)],
  ),
  _Story(
    arabic: 'إِنَّ مَعَ ٱلۡعُسۡرِ يُسۡرٗا',
    english: 'Indeed, with hardship will be ease.',
    urdu: 'بے شک تنگی کے ساتھ فراخی بھی ہے۔',
    reference: 'Quran 94:6',
    theme: 'Ease',
    gradient: [Color(0xFF6b3c2a), Color(0xFFc0744c)],
  ),
  _Story(
    arabic: 'وَمَا خَلَقۡتُ ٱلۡجِنَّ وَٱلۡإِنسَ إِلَّا لِيَعۡبُدُونِ',
    english: 'I did not create jinn and mankind except to worship Me.',
    urdu: 'میں نے جن اور انسانوں کو اِس کے سوا کسی کام کے لیے پیدا نہیں کیا کہ وہ میری بندگی کریں۔',
    reference: 'Quran 51:56',
    theme: 'Purpose',
    gradient: [Color(0xFF2c3e50), Color(0xFF3d6b6b)],
  ),
  _Story(
    arabic: 'فَٱذۡكُرُونِيٓ أَذۡكُرۡكُمۡ',
    english: 'Remember Me; I will remember you.',
    urdu: 'لہٰذا تم مجھے یاد رکھو، میں تمہیں یاد رکھوں گا۔',
    reference: 'Quran 2:152',
    theme: 'Dhikr',
    gradient: [Color(0xFF0d3b2e), Color(0xFF1a8a6b)],
  ),
  _Story(
    arabic: 'لَا تَقۡنَطُواْ مِن رَّحۡمَةِ ٱللَّهِ',
    english: 'Do not despair of the mercy of Allah.',
    urdu: 'اللہ کی رحمت سے مایوس نہ ہو۔',
    reference: 'Quran 39:53',
    theme: 'Mercy',
    gradient: [Color(0xFF1a0d2e), Color(0xFF6b3fa0)],
  ),
  _Story(
    arabic: 'وَٱسۡتَعِينُواْ بِٱلصَّبۡرِ وَٱلصَّلَوٰةِ',
    english: 'Seek help through patience and prayer.',
    urdu: 'صبر اور نماز سے مدد لو۔',
    reference: 'Quran 2:45',
    theme: 'Strength',
    gradient: [Color(0xFF1a3a1a), Color(0xFF4a7c59)],
  ),
  _Story(
    arabic: 'وَلَا تَهِنُواْ وَلَا تَحۡزَنُواْ وَأَنتُمُ ٱلۡأَعۡلَوۡنَ',
    english: 'Do not weaken, do not grieve — you will be superior.',
    urdu: 'دل شکستہ نہ ہو، غم نہ کرو، تم ہی غالب رہو گے اگر تم مومن ہو۔',
    reference: 'Quran 3:139',
    theme: 'Courage',
    gradient: [Color(0xFF3d1a00), Color(0xFF8b5e3c)],
  ),
  _Story(
    arabic: 'لَئِن شَكَرۡتُمۡ لَأَزِيدَنَّكُمۡ',
    english: 'If you are grateful, I will surely increase you.',
    urdu: 'اگر شکر گزار بنو گے تو میں تم کو اور زیادہ دوں گا۔',
    reference: 'Quran 14:7',
    theme: 'Gratitude',
    gradient: [Color(0xFF1a2a00), Color(0xFF5a8a20)],
  ),
  _Story(
    arabic: 'حَسۡبُنَا ٱللَّهُ وَنِعۡمَ ٱلۡوَكِيلُ',
    english: 'Allah is sufficient for us, and He is the best Disposer of affairs.',
    urdu: 'ہمارے لیے اللہ کافی ہے اور وہ بہترین کارساز ہے۔',
    reference: 'Quran 3:173',
    theme: 'Reliance',
    gradient: [Color(0xFF001a3d), Color(0xFF005b8a)],
  ),
  _Story(
    arabic: 'سَابِقُوٓاْ إِلَىٰ مَغۡفِرَةٖ مِّن رَّبِّكُمۡ',
    english: 'Race toward forgiveness from your Lord.',
    urdu: 'اپنے رب کی مغفرت اور جنت کی طرف دوڑو۔',
    reference: 'Quran 57:21',
    theme: 'Race',
    gradient: [Color(0xFF2a1a00), Color(0xFF8b6000)],
  ),
  _Story(
    arabic: 'لَّن يُصِيبَنَآ إِلَّا مَا كَتَبَ ٱللَّهُ لَنَا',
    english: 'Nothing will befall us except what Allah has decreed for us.',
    urdu: 'ہمیں ہرگز کوئی (برائی یا بھلائی) نہیں پہنچتی مگر وہ جو اللہ نے ہمارے لیے لکھ دی ہے۔',
    reference: 'Quran 9:51',
    theme: 'Qadar',
    gradient: [Color(0xFF1a0d00), Color(0xFF5a3a1a)],
  ),
  _Story(
    arabic: 'وَبَشِّرِ ٱلصَّـٰبِرِينَ',
    english: 'Give glad tidings to the patient.',
    urdu: 'اور صبر کرنے والوں کو خوشخبری دے دو۔',
    reference: 'Quran 2:155',
    theme: 'Patience',
    gradient: [Color(0xFF002a1a), Color(0xFF006b4a)],
  ),
  _Story(
    arabic: 'رَبَّنَآ ءَاتِنَا مِن لَّدُنكَ رَحۡمَةٗ',
    english: 'Our Lord, grant us mercy from Yourself.',
    urdu: 'اے پروردگار، ہم کو اپنے پاس سے رحمت عطا فرما۔',
    reference: 'Quran 18:10',
    theme: 'Dua',
    gradient: [Color(0xFF1a001a), Color(0xFF6b006b)],
  ),
  _Story(
    arabic: 'فَلَنُحۡيِيَنَّهُۥ حَيَوٰةٗ طَيِّبَةٗ',
    english: 'We will surely give him a good, pure life.',
    urdu: 'اسے ہم دنیا میں پاکیزہ زندگی بسر کرائیں گے۔',
    reference: 'Quran 16:97',
    theme: 'Good Life',
    gradient: [Color(0xFF00261a), Color(0xFF00704a)],
  ),
  _Story(
    arabic: 'وَبِٱلۡوَٰلِدَيۡنِ إِحۡسَٰنًا',
    english: 'And to parents do good.',
    urdu: 'اور ماں باپ کے ساتھ نیک سلوک کرو۔',
    reference: 'Quran 4:36',
    theme: 'Parents',
    gradient: [Color(0xFF261a00), Color(0xFF6b5000)],
  ),
  _Story(
    arabic: 'ٱصۡبِرُواْ وَصَابِرُواْ وَرَابِطُواْ وَٱتَّقُواْ ٱللَّهَ',
    english: 'Persevere, endure, remain stationed, and fear Allah.',
    urdu: 'صبر سے کام لو، باطل پرستوں کے مقابلہ میں پامردی دکھاؤ اور اللہ سے ڈرتے رہو۔',
    reference: 'Quran 3:200',
    theme: 'Steadfast',
    gradient: [Color(0xFF1a0a00), Color(0xFF5a2a10)],
  ),
];

List<_Story> getStoryReel() {
  final d = DateTime.now();
  final start = (d.year * 365 + d.month * 31 + d.day) % _stories.length;
  return [
    for (int i = 0; i < _stories.length; i++)
      _stories[(start + i) % _stories.length]
  ];
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
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F0E8),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName != null ? 'Assalamu Alaikum,' : 'Assalamu Alaikum',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: (isDark ? AppColors.textOnDarkSecondary : AppColors.textWarmDark)
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                          if (firstName != null)
                            Text(firstName,
                              style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                color: isDark ? AppColors.textOnDarkPrimary : AppColors.textWarmDark,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25), width: 0.8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('🔥', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 5),
                        Text('$_streak', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 15)),
                        Text(' days', style: TextStyle(color: AppColors.gold.withValues(alpha: 0.7), fontWeight: FontWeight.w500, fontSize: 12)),
                      ]),
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
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
                    child: Row(children: [
                      Text('Ayah of the Day',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.textOnDarkPrimary : AppColors.textWarmDark)),
                      const Spacer(),
                      Text('Swipe →', style: TextStyle(fontSize: 12,
                          color: AppColors.gold.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                    ]),
                  ),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 22, right: 10),
                      itemCount: stories.length,
                      itemBuilder: (ctx, i) =>
                          _StoryCard(story: stories[i], width: sw * 0.72),
                    ),
                  ),
                ],
              ),
            ),

            // ── Next prayer ───────────────────────────────────────────────
            if (next != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                  child: _NextPrayerBanner(
                    name: next.key,
                    time: _fmt(next.value),
                    remaining: next.value.difference(DateTime.now()),
                    isDark: isDark,
                  ),
                ),
              ),

            // ── Quick actions ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: Row(children: [
                  _QuickTile(emoji: '📖', label: 'Quran',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen()))),
                  const SizedBox(width: 10),
                  _QuickTile(emoji: '🧭', label: 'Qibla',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()))),
                  const SizedBox(width: 10),
                  _QuickTile(emoji: '📿', label: 'Tasbih',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen()))),
                  const SizedBox(width: 10),
                  _QuickTile(emoji: '💭', label: 'Feelings',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionsScreen()))),
                ]),
              ),
            ),

            // ── Goals ─────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(22, 16, 22, 0), child: GoalsCard()),
            ),

            // ── Daily hadith ──────────────────────────────────────────────
            if (_hadith != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                  child: _HadithCard(hadith: _hadith!, isDark: isDark),
                ),
              ),

            // ── Good deed ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: _GoodDeedCard(isDark: isDark),
              ),
            ),

            // ── Emotions ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
                child: _EmotionsBanner(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EmotionsScreen())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Story Card (scrollable reel) ────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  final _Story story;
  final double width;
  const _StoryCard({required this.story, required this.width});

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
            BoxShadow(color: story.gradient.last.withValues(alpha: 0.4),
                blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(right: -16, top: -16,
              child: Opacity(opacity: 0.06,
                child: const Icon(Icons.auto_awesome_rounded, size: 130, color: Colors.white))),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(story.theme.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 9,
                          fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  ),
                  const Spacer(),
                  Text(story.arabic,
                    textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: AppTheme.arabicStyle(color: Colors.white, fontSize: 19, height: 1.7)),
                  const SizedBox(height: 8),
                  Text(story.english,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12, height: 1.45, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text(story.reference,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('Tap →', style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Story Full View (bottom sheet) ──────────────────────────────────────────

class _StoryFullView extends StatefulWidget {
  final _Story story;
  const _StoryFullView({required this.story});

  @override
  State<_StoryFullView> createState() => _StoryFullViewState();
}

class _StoryFullViewState extends State<_StoryFullView> {
  bool _urdu = false;
  bool _sharing = false;
  final GlobalKey _cardKey = GlobalKey();

  Future<void> _shareAsImage() async {
    setState(() => _sharing = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ayah_${widget.story.reference.replaceAll(' ', '_')}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: '${widget.story.reference} — Shared via SalahSync');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: s.gradient,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2))),

                // EN / UR toggle
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _LangToggle(label: 'EN', active: !_urdu,
                    onTap: () => setState(() => _urdu = false)),
                  const SizedBox(width: 8),
                  _LangToggle(label: 'اردو', active: _urdu,
                    onTap: () => setState(() => _urdu = true)),
                ]),

                const SizedBox(height: 24),

                // ── Shareable card (captured for image share) ──────────────
                RepaintBoundary(
                  key: _cardKey,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: s.gradient,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        // Theme
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
                          ),
                          child: Text(s.theme.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 11,
                                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                        ),
                        const SizedBox(height: 24),
                        // Arabic
                        Text(s.arabic,
                          textAlign: TextAlign.center, textDirection: TextDirection.rtl,
                          style: AppTheme.arabicStyle(color: Colors.white, fontSize: 24, height: 1.9)),
                        const SizedBox(height: 18),
                        Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 18),
                        // Translation
                        Text(
                          _urdu ? s.urdu : s.english,
                          textAlign: TextAlign.center,
                          textDirection: _urdu ? TextDirection.rtl : TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: _urdu ? 16 : 15,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(s.reference,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('SalahSync',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Share button
                GestureDetector(
                  onTap: _sharing ? null : _shareAsImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: _sharing ? 0.08 : 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      if (_sharing)
                        const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      else
                        const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(_sharing ? 'Preparing…' : 'Share as Image',
                        style: const TextStyle(color: Colors.white, fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _LangToggle({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: active ? 0.4 : 0.2), width: 0.8),
        ),
        child: Text(label,
          style: TextStyle(color: Colors.white,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400, fontSize: 13)),
      ),
    );
  }
}

// ─── Next Prayer Banner (compact, on-theme) ───────────────────────────────────

class _NextPrayerBanner extends StatelessWidget {
  final String name;
  final String time;
  final Duration remaining;
  final bool isDark;
  const _NextPrayerBanner({required this.name, required this.time,
      required this.remaining, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final label = h > 0 ? '${h}h ${m}m' : '${m}m';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.mosque_rounded,
                color: AppColors.tealPrimaryLight, size: 18),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NEXT PRAYER',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.tealPrimaryLight.withValues(alpha: 0.65))),
            Text(name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textOnDarkPrimary : AppColors.textWarmDark)),
          ]),
          const Spacer(),
          Text(time,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textOnDarkPrimary : AppColors.textWarmDark)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('in $label',
              style: const TextStyle(color: AppColors.gold,
                  fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Tile ───────────────────────────────────────────────────────────────

class _QuickTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _QuickTile({required this.emoji, required this.label, required this.onTap});

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
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
              blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textOnDarkSecondary : AppColors.textWarmDark)),
          ]),
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
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 0.8),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
            child: const Text('HADITH OF THE DAY',
              style: TextStyle(color: AppColors.gold, fontSize: 9,
                  fontWeight: FontWeight.w800, letterSpacing: 1.2))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
            child: const Text('Sahih',
              style: TextStyle(color: AppColors.success, fontSize: 10,
                  fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 12),
        Text('"${hadith.englishText}"',
          style: TextStyle(fontSize: 14, height: 1.65,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w400,
            color: isDark ? AppColors.textOnDarkPrimary : AppColors.textWarmDark),
          maxLines: 4, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Text('— ${hadith.reference ?? hadith.book}',
          style: const TextStyle(color: AppColors.gold, fontSize: 11,
              fontWeight: FontWeight.w600)),
      ]),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1D2E1A), const Color(0xFF2A4020)]
              : [const Color(0xFFEEF4E8), const Color(0xFFDCEBD0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.18), width: 0.8),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🌿', style: TextStyle(fontSize: 26)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ONE GOOD THING TODAY',
            style: TextStyle(color: AppColors.success.withValues(alpha: 0.8),
                fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(GoodDeeds.todays(),
            style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textOnDarkPrimary : AppColors.textWarmDark)),
        ])),
      ]),
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
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0D2B2E), Color(0xFF1B4B4F)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(
            color: const Color(0xFF0D2B2E).withValues(alpha: 0.35),
            blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HOW ARE YOU FEELING?',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            const Text('Find a verse & hadith\nfor your state of heart',
              style: TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w700, height: 1.35)),
          ])),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8)),
            child: const Column(children: [
              Text('😔', style: TextStyle(fontSize: 18)),
              Text('😌', style: TextStyle(fontSize: 18)),
            ]),
          ),
        ]),
      ),
    );
  }
}
