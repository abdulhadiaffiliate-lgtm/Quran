import 'package:flutter/material.dart';
import '../services/qada_service.dart';
import '../theme/app_colors.dart';

class QadaScreen extends StatefulWidget {
  const QadaScreen({super.key});

  @override
  State<QadaScreen> createState() => _QadaScreenState();
}

class _QadaScreenState extends State<QadaScreen> {
  Map<String, int> _counts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final counts = await QadaService.getAll();
    if (!mounted) return;
    setState(() {
      _counts = counts;
      _loading = false;
    });
  }

  Future<void> _inc(String prayer) async {
    await QadaService.increment(prayer);
    _load();
  }

  Future<void> _dec(String prayer) async {
    await QadaService.decrement(prayer);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final total = _counts.values.fold<int>(0, (a, b) => a + b);
    return Scaffold(
      appBar: AppBar(title: const Text('Missed Prayers (Qada)')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.tealPrimary,
                          AppColors.tealPrimaryLight
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text('$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            )),
                        const Text('prayers to make up',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Track prayers you need to make up. Tap + when you miss one, and − each time you complete a make-up prayer.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...QadaService.prayers.map((p) => _row(p)),
                ],
              ),
      ),
    );
  }

  Widget _row(String prayer) {
    final count = _counts[prayer] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(prayer,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          _circleButton(Icons.remove_rounded, () => _dec(prayer),
              enabled: count > 0),
          Container(
            width: 44,
            alignment: Alignment.center,
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          _circleButton(Icons.add_rounded, () => _inc(prayer), enabled: true),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap,
      {required bool enabled}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.gold.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 20,
            color: enabled ? AppColors.gold : Colors.grey),
      ),
    );
  }
}
