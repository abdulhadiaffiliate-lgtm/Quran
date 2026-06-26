import 'package:flutter/material.dart';
import '../utils/rakat_guide.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class RakatScreen extends StatefulWidget {
  const RakatScreen({super.key});

  @override
  State<RakatScreen> createState() => _RakatScreenState();
}

class _RakatScreenState extends State<RakatScreen> {
  bool _shafii = false; // false = Hanafi, true = Shafi'i

  @override
  Widget build(BuildContext context) {
    final data = _shafii ? RakatGuide.shafii : RakatGuide.hanafi;

    return Scaffold(
      appBar: AppBar(title: const Text('Rakats per prayer')),
      body: SafeArea(
        child: Column(
          children: [
            // Madhab toggle
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _toggleHalf('Hanafi', !_shafii,
                      () => setState(() => _shafii = false)),
                  _toggleHalf('Shafi\'i', _shafii,
                      () => setState(() => _shafii = true)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: data.length,
                itemBuilder: (context, i) => _rakatCard(data[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleHalf(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: active ? AppColors.darkBg : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rakatCard(RakatData r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r.prayer,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                r.arabicName,
                style: AppTheme.arabicStyle(
                  color: AppColors.gold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (r.sunnahBefore != '—')
            _row('Sunnah (before)', r.sunnahBefore),
          _row('Fard', r.fard, highlight: true),
          if (r.sunnahAfter != '—') _row('Sunnah (after)', r.sunnahAfter),
          if (r.extra != '—') _row('Other', r.extra),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.gold : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
