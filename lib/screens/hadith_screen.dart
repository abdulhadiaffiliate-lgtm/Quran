import 'package:flutter/material.dart';
import '../models/hadith.dart';
import '../services/hadith_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  Hadith? _daily;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDaily();
  }

  Future<void> _loadDaily() async {
    setState(() => _error = null);
    try {
      final h = await HadithService.getDailyHadith();
      if (!mounted) return;
      setState(() => _daily = h);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hadith')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDaily,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Hadith of the day',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (_error != null)
                _buildError()
              else if (_daily == null)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _buildHadithCard(_daily!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: _loadDaily, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithCard(Hadith h) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 18, color: AppColors.gold),
                const SizedBox(width: 8),
                Text(
                  '${h.book} · #${h.number}',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (h.arabicText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  h.arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabicStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                    fontSize: 22,
                    height: 1.9,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              h.englishText,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(height: 1.5),
            ),
            if (h.grade != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  h.grade!,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
