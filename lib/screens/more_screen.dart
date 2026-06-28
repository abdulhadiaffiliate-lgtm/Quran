import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'tasbih_screen.dart';
import 'purification_screen.dart';
import 'rakat_screen.dart';
import 'dua_screen.dart';
import 'quiz_screen.dart';
import 'adhkar_screen.dart';
import 'qada_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tile(
              context,
              icon: Icons.auto_stories_rounded,
              title: 'Dua',
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
            const SizedBox(height: 24),
            _tile(
              context,
              icon: Icons.settings_rounded,
              title: 'Settings',
              subtitle: 'Notifications, calendar, reciter & more',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
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
}
