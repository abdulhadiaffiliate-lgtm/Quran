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
          // Mini-player floats above the nav when audio is playing
          MiniPlayer(
            onTap: () {
              // Navigate to Quran tab so user can access the reader
              setState(() => _index = 1);
            },
          ),
          Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.access_time_rounded,
                  label: 'Prayer',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Quran',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _HomeNavButton(
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _NavItem(
                  icon: Icons.format_quote_rounded,
                  label: 'Hadith',
                  selected: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'More',
                  selected: _index == 4,
                  onTap: () => setState(() => _index = 4),
                ),
              ],
            ),
          ),
        ),
      ),  // end Container (nav bar)
        ],  // end Column children
      ),  // end Column (bottomNavigationBar)
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? AppColors.gold
        : (isDark
            ? AppColors.textOnDarkSecondary
            : AppColors.textWarmDark.withValues(alpha: 0.45));

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeNavButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _HomeNavButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tealPrimary.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.home_rounded,
                color: selected ? AppColors.gold : Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Home',
              style: TextStyle(
                color: selected ? AppColors.gold : AppColors.tealPrimaryLight,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
