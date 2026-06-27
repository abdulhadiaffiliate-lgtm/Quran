import 'package:flutter/material.dart';
import '../services/tafseer_service.dart';
import '../services/word_by_word_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Per-ayah study screen: shows the ayah, its word-by-word breakdown, and
/// tafseer with an English/Urdu toggle. Opened from the surah reader.
class LearnAyahScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabicText;

  const LearnAyahScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabicText,
  });

  @override
  State<LearnAyahScreen> createState() => _LearnAyahScreenState();
}

class _LearnAyahScreenState extends State<LearnAyahScreen> {
  List<WordBreakdown> _words = [];
  String? _tafseer;
  bool _loadingTafseer = true;
  String? _tafseerError;
  String _tafseerLang = 'English';

  @override
  void initState() {
    super.initState();
    _loadWords();
    _loadTafseer();
  }

  Future<void> _loadWords() async {
    final words = await WordByWordService.getWords(
      surah: widget.surahNumber,
      ayah: widget.ayahNumber,
    );
    if (!mounted) return;
    setState(() => _words = words);
  }

  Future<void> _loadTafseer() async {
    setState(() {
      _loadingTafseer = true;
      _tafseerError = null;
    });
    try {
      final text = await TafseerService.getTafseer(
        surah: widget.surahNumber,
        ayah: widget.ayahNumber,
        language: _tafseerLang,
      );
      if (!mounted) return;
      setState(() {
        _tafseer = text;
        _loadingTafseer = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tafseerError = e.toString();
        _loadingTafseer = false;
      });
    }
  }

  void _toggleLang() {
    setState(() {
      _tafseerLang = _tafseerLang == 'English' ? 'Urdu' : 'English';
    });
    _loadTafseer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.surahName} ${widget.surahNumber}:${widget.ayahNumber}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // The ayah itself
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                widget.arabicText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Word by word
            Text('Word by word',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (_words.isEmpty)
              Text(
                'Word-by-word breakdown isn\'t available for this ayah.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _words.map(_wordChip).toList(),
              ),
            const SizedBox(height: 28),

            // Tafseer
            Row(
              children: [
                Text('Tafseer',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleLang,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _tafseerLang == 'English' ? 'English' : 'اردو',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _tafseerLang == 'English'
                  ? 'Tafsir Ibn Kathir (abridged)'
                  : 'تفسیر بیان القرآن — ڈاکٹر اسرار احمد',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (_loadingTafseer)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_tafseerError != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Could not load tafseer for this ayah.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  FilledButton(
                      onPressed: _loadTafseer,
                      child: const Text('Try again')),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _tafseer ?? '',
                  textAlign:
                      _tafseerLang == 'Urdu' ? TextAlign.right : TextAlign.left,
                  textDirection: _tafseerLang == 'Urdu'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: _tafseerLang == 'Urdu'
                      ? AppTheme.arabicStyle(
                          color:
                              Theme.of(context).textTheme.bodyLarge!.color!,
                          fontSize: 18,
                          height: 2.0,
                        )
                      : Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(height: 1.6),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _wordChip(WordBreakdown w) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            w.transliteration,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            w.meaning,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
