import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  NotifyStyle? _style;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await AppSettings.getNotifyStyle();
    if (!mounted) return;
    setState(() => _style = s);
  }

  Future<void> _select(NotifyStyle style) async {
    setState(() => _style = style);
    await AppSettings.setNotifyStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer notifications')),
      body: SafeArea(
        child: _style == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'How would you like to be notified at prayer times?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _option(
                    NotifyStyle.azan,
                    'Full Azan',
                    'Play the call to prayer (adhan) aloud',
                    Icons.campaign_rounded,
                  ),
                  const SizedBox(height: 12),
                  _option(
                    NotifyStyle.notification,
                    'Notification',
                    'A standard notification with sound',
                    Icons.notifications_rounded,
                  ),
                  const SizedBox(height: 12),
                  _option(
                    NotifyStyle.silent,
                    'Silent',
                    'A quiet banner only, no sound',
                    Icons.notifications_off_rounded,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 18, color: AppColors.gold),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Scheduled prayer reminders are coming in a future update. Your preference is saved and will apply then.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _option(
      NotifyStyle style, String title, String subtitle, IconData icon) {
    final selected = _style == style;
    return GestureDetector(
      onTap: () => _select(style),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.15)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? AppColors.gold
                    : Theme.of(context).textTheme.bodyMedium?.color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
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
}
