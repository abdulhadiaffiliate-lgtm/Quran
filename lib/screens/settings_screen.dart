import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_settings.dart';
import '../services/reciter_service.dart';
import '../services/calc_method_resolver.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'notification_settings_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _translationLang = 'English';
  String _reciterId = 'ar.alafasy';
  int _calcMethod = 3;
  int _hijriOffset = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lang = await AppSettings.getTranslationLanguage();
    final reciter = await ReciterService.getSelectedId();
    final method = await AppSettings.getCalcMethod();
    final offset = await AppSettings.getHijriOffset();
    if (!mounted) return;
    setState(() {
      _translationLang = lang;
      _reciterId = reciter;
      _calcMethod = method;
      _hijriOffset = offset;
      _loading = false;
    });
  }

  Future<void> _pickTranslationLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Translation language',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final lang in ['English', 'Urdu'])
              ListTile(
                leading: Icon(
                  lang == _translationLang
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: AppColors.gold,
                ),
                title: Text(lang),
                onTap: () => Navigator.pop(ctx, lang),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await AppSettings.setTranslationLanguage(selected);
      setState(() => _translationLang = selected);
    }
  }

  Future<void> _pickReciter() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Quran reciter',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...ReciterService.all.map((r) => ListTile(
                  leading: Icon(
                    r.id == _reciterId
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: AppColors.gold,
                  ),
                  title: Text(r.name),
                  onTap: () => Navigator.pop(ctx, r.id),
                )),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ReciterService.setSelectedId(selected);
      setState(() => _reciterId = selected);
    }
  }

  Future<void> _pickCalcMethod() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Prayer calculation method',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Detected automatically from your location. Change it here if your region uses a different method.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ...CalcMethodResolver.methodNames.entries.map((e) => ListTile(
                  leading: Icon(
                    e.key == _calcMethod
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: AppColors.gold,
                  ),
                  title: Text(e.value),
                  onTap: () => Navigator.pop(ctx, e.key),
                )),
          ],
        ),
      ),
    );
    if (selected != null) {
      await AppSettings.setCalcMethod(selected);
      // Mark as no longer auto-managed since the user chose manually.
      await AppSettings.setCalcMethodAutoDetected(true);
      setState(() => _calcMethod = selected);
    }
  }

  Future<void> _setHijriOffset(int value) async {
    await AppSettings.setHijriOffset(value);
    setState(() => _hijriOffset = value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionLabel('Prayer'),
                  _tile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Prayer notifications',
                    subtitle: 'Choose how you are notified',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const NotificationSettingsScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _tile(
                    icon: Icons.calculate_rounded,
                    title: 'Calculation method',
                    subtitle: CalcMethodResolver
                            .methodNames[_calcMethod] ??
                        'Muslim World League',
                    onTap: _pickCalcMethod,
                  ),
                  const SizedBox(height: 10),
                  _hijriOffsetTile(),
                  const SizedBox(height: 24),
                  _sectionLabel('Quran'),
                  _tile(
                    icon: Icons.translate_rounded,
                    title: 'Translation language',
                    subtitle: _translationLang,
                    onTap: _pickTranslationLanguage,
                  ),
                  const SizedBox(height: 10),
                  _tile(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Reciter',
                    subtitle: ReciterService.getById(_reciterId).name,
                    onTap: _pickReciter,
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('Appearance'),
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
                  const SizedBox(height: 24),
                  _sectionLabel('About'),
                  _tile(
                    icon: Icons.info_outline_rounded,
                    title: 'About SalahSync',
                    subtitle: 'Version, credits, and sources',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.gold),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  Widget _hijriOffsetTile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded,
                    color: AppColors.gold),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Hijri date adjustment',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Use this if your local mosque announces a date that\'s a day ahead or behind this app.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _offsetChip('-1 day', -1),
                const SizedBox(width: 10),
                _offsetChip('Today', 0),
                const SizedBox(width: 10),
                _offsetChip('+1 day', 1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _offsetChip(String label, int value) {
    final selected = _hijriOffset == value;
    return GestureDetector(
      onTap: () => _setHijriOffset(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold
              : AppColors.tealPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.darkBg : AppColors.gold,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
