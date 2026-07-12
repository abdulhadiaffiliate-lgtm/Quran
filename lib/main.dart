import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'theme/theme_provider.dart';
import 'services/app_settings.dart';
import 'services/streak_service.dart';
import 'services/notification_service.dart';
import 'services/prayer_service.dart';
import 'services/location_service.dart';
import 'services/calc_method_resolver.dart';
import 'services/quran_player_service.dart';
import 'models/prayer_times.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/more_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/daily_popup.dart';
import 'widgets/mini_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: QuranPlayerService.instance),
      ],
      child: const SalahSyncApp(),
    ),
  );
}

class SalahSyncApp extends StatelessWidget {
  const SalahSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'SalahSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool? _onboarded;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final done = await AppSettings.isOnboarded();
    setState(() => _onboarded = done);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboarded == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_onboarded == false) {
      return OnboardingScreen(
        onComplete: () => setState(() => _onboarded = true),
      );
    }
    return const RootShell();
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 2; // Default to Home tab
  PrayerTimes? _times;
  int _hijriOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startup());
    _fetchTimes();
  }

  Future<void> _fetchTimes() async {
    try {
      double lat, lng;
      try {
        final pos = await LocationService.getCurrentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
      } on LocationException {
        final cached = await LocationService.getCachedLocation();
        if (cached == null) return;
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
      }
      final offset = await AppSettings.getHijriOffset();
      final method = await AppSettings.getCalcMethod();
      final times = await PrayerService.getTodayTimings(
        latitude: lat,
        longitude: lng,
        method: method,
      );
      if (!mounted) return;
      setState(() {
        _times = times;
        _hijriOffset = offset;
      });
      NotificationService.schedulePrayers(times);
      NotificationService.scheduleDailyReminders();
    } catch (_) {}
  }

  Future<void> _startup() async {
    await NotificationService.requestPermissions();
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    if (!batteryStatus.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
    final shouldShow = await StreakService.shouldShowPopupToday();
    if (shouldShow && mounted) {
      final streak = await StreakService.getCurrentStreak();
      await DailyPopup.show(context, streak);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(sharedTimes: _times, hijriOffset: _hijriOffset),
      const QuranScreen(),
      DashboardScreen(times: _times, hijriOffset: _hijriOffset),
      const HadithScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(
            onTap: () => setState(() => _index = 1),
          ),
          _PremiumNavBar(
            selectedIndex: _index,
            onTap: (i) => setState(() => _index = i),
          ),
        ],
      ),
    );
  }
}

// ─── Premium Nav Bar ──────────────────────────────────────────────────────────

class _PremiumNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _PremiumNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── The unified pill container ────────────────────────────────
              Container(
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D2B1A), // very dark emerald
                      Color(0xFF1A4428), // mid emerald
                      Color(0xFF0F3020), // dark emerald
                      Color(0xFF1D4D30), // lighter emerald
                    ],
                    stops: [0.0, 0.3, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D2B1A).withValues(alpha: 0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFFC9A461).withValues(alpha: 0.15),
                      blurRadius: 1,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: const Color(0xFFC9A461).withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                ),
                // Marble veining overlay
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: CustomPaint(
                    painter: _MarblePainter(),
                    child: Row(
                      children: [
                        _PremiumNavItem(
                          icon: Icons.access_time_rounded,
                          label: 'Prayer',
                          selected: selectedIndex == 0,
                          onTap: () => onTap(0),
                        ),
                        _PremiumNavItem(
                          icon: Icons.menu_book_rounded,
                          label: 'Quran',
                          selected: selectedIndex == 1,
                          onTap: () => onTap(1),
                        ),
                        const SizedBox(width: 72), // space for center button
                        _PremiumNavItem(
                          icon: Icons.format_quote_rounded,
                          label: 'Hadith',
                          selected: selectedIndex == 3,
                          onTap: () => onTap(3),
                        ),
                        _PremiumNavItem(
                          icon: Icons.grid_view_rounded,
                          label: 'More',
                          selected: selectedIndex == 4,
                          onTap: () => onTap(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Elevated center Home button ───────────────────────────────
              Positioned(
                top: -14,
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Outer gold bezel ring
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFE8C97A), // bright gold top
                              Color(0xFFC9A461), // mid gold
                              Color(0xFF8B6F47), // dark gold bottom
                              Color(0xFFDDBB78), // bright gold edge
                            ],
                            stops: [0.0, 0.4, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC9A461)
                                  .withValues(alpha: 0.6),
                              blurRadius: 18,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3.5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A4428),
                                Color(0xFF0D2B1A),
                                Color(0xFF1D4D30),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.mosque_rounded,
                              color: selectedIndex == 2
                                  ? const Color(0xFFE8C97A)
                                  : const Color(0xFFC9A461),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HOME',
                        style: TextStyle(
                          color: selectedIndex == 2
                              ? const Color(0xFFE8C97A)
                              : const Color(0xFFC9A461),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
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

/// Paints subtle marble-like veining over the nav bar background.
class _MarblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.028)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // A few gentle diagonal veins — soft, not obvious
    final path1 = Path()
      ..moveTo(size.width * 0.1, 0)
      ..quadraticBezierTo(
          size.width * 0.3, size.height * 0.6,
          size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(
          size.width * 0.65, size.height * 0.0,
          size.width * 0.85, size.height * 0.7);

    final path2 = Path()
      ..moveTo(size.width * 0.6, 0)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.5,
          size.width * 0.9, size.height * 0.2);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint..color = const Color(0xFFFFFFFF).withValues(alpha: 0.018));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PremiumNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PremiumNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? const Color(0xFFE8C97A)  // bright gold when selected
        : const Color(0xFFC9A461).withValues(alpha: 0.55);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
