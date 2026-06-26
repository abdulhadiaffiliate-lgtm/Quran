import 'package:flutter/material.dart';
import '../services/goals_service.dart';
import '../theme/app_colors.dart';

/// Home-screen card showing today's spiritual goals: Dhikr count,
/// Quran pages read, and which prayers have been marked complete.
class GoalsCard extends StatefulWidget {
  const GoalsCard({super.key});

  @override
  State<GoalsCard> createState() => _GoalsCardState();
}

class _GoalsCardState extends State<GoalsCard> {
  int _dhikrProgress = 0;
  int _dhikrTarget = 100;
  int _quranProgress = 0;
  int _quranTarget = 1;
  Set<String> _prayersDone = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final dp = await GoalsService.getDhikrProgress();
    final dt = await GoalsService.getDhikrTarget();
    final qp = await GoalsService.getQuranProgress();
    final qt = await GoalsService.getQuranTarget();
    final pd = await GoalsService.getPrayersDone();
    if (!mounted) return;
    setState(() {
      _dhikrProgress = dp;
      _dhikrTarget = dt;
      _quranProgress = qp;
      _quranTarget = qt;
      _prayersDone = pd;
    });
  }

  Future<void> _togglePrayer(String name) async {
    await GoalsService.togglePrayerDone(name);
    _refresh();
  }

  Future<void> _addDhikr() async {
    await GoalsService.addDhikr(33);
    _refresh();
  }

  Future<void> _addQuranPage() async {
    await GoalsService.addQuranPages(1);
    _refresh();
  }

  Future<void> _editTargets() async {
    final dhikrController =
        TextEditingController(text: _dhikrTarget.toString());
    final quranController =
        TextEditingController(text: _quranTarget.toString());

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily goals'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dhikrController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Dhikr target'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quranController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Quran pages target'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final d = int.tryParse(dhikrController.text) ?? _dhikrTarget;
              final q = int.tryParse(quranController.text) ?? _quranTarget;
              await GoalsService.setDhikrTarget(d);
              await GoalsService.setQuranTarget(q);
              Navigator.pop(ctx);
              _refresh();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Today\'s goals',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  onPressed: _editTargets,
                  color: AppColors.gold,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _goalRow(
              icon: Icons.radio_button_checked_rounded,
              label: 'Dhikr',
              progress: _dhikrProgress,
              target: _dhikrTarget,
              onTap: _addDhikr,
              actionLabel: '+33',
            ),
            const SizedBox(height: 14),
            _goalRow(
              icon: Icons.menu_book_rounded,
              label: 'Quran pages',
              progress: _quranProgress,
              target: _quranTarget,
              onTap: _addQuranPage,
              actionLabel: '+1 page',
            ),
            const SizedBox(height: 16),
            Text(
              'Prayers today',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: GoalsService.prayerNames.map((name) {
                final done = _prayersDone.contains(name);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _togglePrayer(name),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.success.withValues(alpha: 0.18)
                            : Theme.of(context)
                                .scaffoldBackgroundColor
                                .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: done
                              ? AppColors.success
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            done
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 16,
                            color: done
                                ? AppColors.success
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: done ? AppColors.success : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalRow({
    required IconData icon,
    required String label,
    required int progress,
    required int target,
    required VoidCallback onTap,
    required String actionLabel,
  }) {
    final pct = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.gold),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('$progress / $target',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: AppColors.tealPrimary.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
