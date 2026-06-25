import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'tasbih_screen.dart';

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
              subtitle: 'Adhan and reminder settings',
              onTap: () => _comingSoon(context),
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

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming in a future update')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SalahSync',
      applicationVersion: '1.0.0',
      children: [
        const Text(
          'Prayer times, Qibla, Quran, Hadith, Tasbih, and daily reminders. '
          'Prayer data from AlAdhan; Quran from Al Quran Cloud; Hadith from the '
          'open hadith-api project.',
        ),
      ],
    );
  }
}
