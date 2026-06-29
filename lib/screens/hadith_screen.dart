import 'package:flutter/material.dart';
import '../models/hadith.dart';
import '../services/hadith_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'hadith_books_screen.dart';

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
              // Browse books (tabbed search) entry point
              Card(
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.library_books_rounded,
                        color: AppColors.gold),
                  ),
                  title: const Text('Browse hadith books',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      'Bukhari · Muslim · Abu Dawud · Tirmidhi'),
                  trailing: const Icon(Icons.search_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HadithBooksScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  h.reference ?? '${h.book} · #${h.number}',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GradeLabel(grade: h.grade),
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
          ],
        ),
      ),
    );
  }
}
