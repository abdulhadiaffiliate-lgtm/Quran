import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'tasbih_screen.dart';
import 'notification_settings_screen.dart';
import 'purification_screen.dart';
import 'rakat_screen.dart';
import 'dua_screen.dart';
import 'quiz_screen.dart';
import 'adhkar_screen.dart';
import 'qada_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tile(
              context,
              icon: Icons.auto_stories_rounded,
              title: 'Dua & Azkar',
              subtitle: 'Daily supplications & remembrance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DuaScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              icon: Icons.wb_twilight_rounded,
              title: 'Morning & Evening Adhkar',
              subtitle: 'Daily protection & remembrance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdhkarScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              icon: Icons.event_busy_rounded,
              title: 'Missed Prayers (Qada)',
              subtitle: 'Track prayers to make up',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QadaScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              icon: Icons.water_drop_rounded,
              title: 'Wudu & Ghusl',
              subtitle: 'Step-by-step guide (English / Urdu)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PurificationScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              icon: Icons.format_list_numbered_rounded,
              title: 'Rakats per prayer',
              subtitle: 'Sunnah, Fard & Witr (Hanafi / Shafi\'i)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RakatScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              icon: Icons.quiz_rounded,
              title: 'Islamic Quiz',
              subtitle: 'Test your knowledge — easy to hard',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              icon: Icons.radio_button_checked_rounded,
              title: 'Tasbih',
              subtitle: 'Digital dhikr counter',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasbihScreen()),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  themeProvider.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: AppColors.gold,
                ),
                title: const Text('Dark mode'),
                subtitle: Text(themeProvider.isDark ? 'On' : 'Off'),
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggle(),
              ),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              icon: Icons.notifications_active_rounded,
              title: 'Prayer notifications',
              subtitle: 'Choose how you are notified',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'SalahSync v1.0',
              onTap: () => _showAbout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.gold),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SalahSync',
      applicationVersion: '1.0.0',
      children: [
        const Text(
          'SalahSync is here to make it a little easier to stay on top of '
          'your prayers and keep some good in every day — your salah times, '
          'the Quran, a hadith, a tasbih, all close at hand. May it be a '
          'help to you, and a reason for good to reach whoever made it.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),
        const Text(
          'Data sources, with thanks: prayer times & Qibla from AlAdhan; '
          'Quran text, translations & recitation from Al Quran Cloud; '
          'hadith from the fawazahmed0 open hadith-api (CC BY-NC); '
          'tafseer from spa5k tafsir_api (Ibn Kathir & Dr. Israr Ahmad); '
          'word-by-word data from the open holy-quran-word-by-word dataset. '
          'SalahSync is free and non-commercial.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 20),
        Opacity(
          opacity: 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Developed by Abdulhadi',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Team: Rahim Nawaz, Hassan Qureshi',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
