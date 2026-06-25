import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/app_settings.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  NotifyStyle _selectedStyle = NotifyStyle.notification;
  int _selectedCalc = 3;

  static const _calcMethods = {
    3: 'Muslim World League',
    2: 'ISNA (North America)',
    4: 'Umm al-Qura (Makkah)',
    1: 'University of Karachi',
    5: 'Egyptian General Authority',
  };

  void _next() {
    if (_page < 5) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _requestLocation() async {
    await Permission.locationWhenInUse.request();
    _next();
  }

  Future<void> _requestNotifications() async {
    await Permission.notification.request();
    _next();
  }

  Future<void> _finish() async {
    await AppSettings.setNotifyStyle(_selectedStyle);
    await AppSettings.setCalcMethod(_selectedCalc);
    await AppSettings.setOnboarded(true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _welcomePage(),
                  _locationPage(),
                  _notificationPage(),
                  _stylePage(),
                  _calcPage(),
                  _donePage(),
                ],
              ),
            ),
            _dots(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.gold : AppColors.tealPrimaryLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _pageScaffold({
    required IconData icon,
    required String title,
    required String body,
    required Widget action,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
              ),
            ),
            child: Icon(icon, size: 52, color: AppColors.goldLight),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textOnDarkPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textOnDarkSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          action,
        ],
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.darkBg,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _welcomePage() {
    return _pageScaffold(
      icon: Icons.mosque_rounded,
      title: 'Welcome to SalahSync',
      body:
          'Your daily companion for prayer times, Qibla, Quran, Hadith, and dhikr — all in one calm, focused place.',
      action: _primaryButton('Get started', _next),
    );
  }

  Widget _locationPage() {
    return _pageScaffold(
      icon: Icons.location_on_rounded,
      title: 'Enable location',
      body:
          'SalahSync uses your location to calculate accurate prayer times and the correct Qibla direction for where you are. Your location stays on your device.',
      action: Column(
        children: [
          _primaryButton('Allow location', _requestLocation),
          TextButton(
            onPressed: _next,
            child: const Text('Skip for now',
                style: TextStyle(color: AppColors.textOnDarkSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _notificationPage() {
    return _pageScaffold(
      icon: Icons.notifications_active_rounded,
      title: 'Prayer notifications',
      body:
          'Allow notifications so SalahSync can remind you when each prayer time arrives.',
      action: Column(
        children: [
          _primaryButton('Allow notifications', _requestNotifications),
          TextButton(
            onPressed: _next,
            child: const Text('Skip for now',
                style: TextStyle(color: AppColors.textOnDarkSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _stylePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.volume_up_rounded,
              size: 56, color: AppColors.gold),
          const SizedBox(height: 20),
          const Text(
            'How would you like to be notified?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnDarkPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can change this anytime in Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textOnDarkSecondary),
          ),
          const SizedBox(height: 28),
          _styleOption(
            NotifyStyle.azan,
            'Full Azan',
            'Play the call to prayer (adhan) aloud',
            Icons.campaign_rounded,
          ),
          const SizedBox(height: 12),
          _styleOption(
            NotifyStyle.notification,
            'Notification',
            'A standard notification with sound',
            Icons.notifications_rounded,
          ),
          const SizedBox(height: 12),
          _styleOption(
            NotifyStyle.silent,
            'Silent',
            'A quiet banner only, no sound',
            Icons.notifications_off_rounded,
          ),
          const SizedBox(height: 28),
          _primaryButton('Continue', _next),
        ],
      ),
    );
  }

  Widget _styleOption(
      NotifyStyle style, String title, String subtitle, IconData icon) {
    final selected = _selectedStyle == style;
    return GestureDetector(
      onTap: () => setState(() => _selectedStyle = style),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.gold : AppColors.textOnDarkSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: AppColors.textOnDarkPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                        color: AppColors.textOnDarkSecondary,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  Widget _calcPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.calculate_rounded, size: 56, color: AppColors.gold),
          const SizedBox(height: 20),
          const Text(
            'Prayer calculation method',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnDarkPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pick the method used in your region. You can change it later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textOnDarkSecondary),
          ),
          const SizedBox(height: 24),
          ..._calcMethods.entries.map((e) {
            final selected = _selectedCalc == e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCalc = e.key),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.gold : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.value,
                            style: const TextStyle(
                              color: AppColors.textOnDarkPrimary,
                              fontSize: 15,
                            )),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.gold, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          _primaryButton('Continue', _next),
        ],
      ),
    );
  }

  Widget _donePage() {
    return _pageScaffold(
      icon: Icons.check_circle_rounded,
      title: 'You\'re all set',
      body:
          'May SalahSync help you stay consistent and connected. Tap below to begin.',
      action: _primaryButton('Enter SalahSync', _finish),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
