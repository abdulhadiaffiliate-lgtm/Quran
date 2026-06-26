import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'tasbih_screen.dart';
import 'notification_settings_screen.dart';
import 'purification_screen.dart';
import 'rakat_screen.dart';
import 'dua_screen.dart';

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
          'SalahSync was made to be a quiet companion on your journey — '
          'to help you keep your prayers, stay close to the Quran, and '
          'carry a little remembrance through your day. May it be of '
          'benefit to you, and a means of good.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),
        const Text(
          'Prayer times from AlAdhan · Quran from Al Quran Cloud · '
          'Hadith from the open hadith-api project.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 20),
        Opacity(
          opacity: 0.4,
          child: Text(
            'Developed by Abdulhadi',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}
