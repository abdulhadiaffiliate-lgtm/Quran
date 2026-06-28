import 'package:flutter/material.dart';
import '../models/quran.dart';
import '../services/quran_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../services/quran_progress_service.dart';
import 'surah_reader_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<Surah>? _surahs;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final list = await QuranService.getSurahList();
      if (!mounted) return;
      setState(() => _surahs = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        actions: [
          IconButton(
            tooltip: 'Bookmarks',
            icon: const Icon(Icons.bookmarks_rounded),
            onPressed: _showBookmarks,
          ),
        ],
      ),
      body: SafeArea(
        child: _error != null
            ? _buildError()
            : _surahs == null
                ? const Center(child: CircularProgressIndicator())
                : _buildList(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: _load, child: const Text('Try again')),
        ],
      ),
    );
  }

  Widget _buildList() {
    final filtered = _surahs!.where((s) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return s.nameEnglish.toLowerCase().contains(q) ||
          s.nameTranslation.toLowerCase().contains(q) ||
          s.number.toString() == q;
    }).toList();

    return Column(
      children: [
        _ContinueReadingBanner(onOpen: _openSurahByNumber),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search surah',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final s = filtered[i];
              return ListTile(
                leading: _surahBadge(s.number),
                title: Text(
                  s.nameEnglish,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${s.nameTranslation} · ${s.ayahCount} verses · ${s.revelationType}',
                ),
                trailing: Text(
                  s.nameArabic,
                  style: AppTheme.arabicStyle(
                    color: AppColors.gold,
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahReaderScreen(surahMeta: s),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openSurahByNumber(int number) {
    final surah = _surahs?.firstWhere(
      (s) => s.number == number,
      orElse: () => _surahs!.first,
    );
    if (surah == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahReaderScreen(surahMeta: surah),
      ),
    );
  }

  Future<void> _showBookmarks() async {
    final bookmarks = await QuranProgressService.getBookmarks();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        if (bookmarks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text('No bookmarks yet. Tap the bookmark icon on any ayah.'),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: [
            Text('Bookmarks',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...bookmarks.map((b) => ListTile(
                  leading: const Icon(Icons.bookmark_rounded,
                      color: AppColors.gold),
                  title: Text('${b.name}  ${b.surah}:${b.ayah}'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openSurahByNumber(b.surah);
                  },
                )),
          ],
        );
      },
    );
  }

  Widget _surahBadge(int number) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.tealPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

/// A banner shown at the top of the Quran list offering to resume the
/// last-read surah. Hidden if there's no saved position.
class _ContinueReadingBanner extends StatefulWidget {
  final void Function(int surahNumber) onOpen;
  const _ContinueReadingBanner({required this.onOpen});

  @override
  State<_ContinueReadingBanner> createState() =>
      _ContinueReadingBannerState();
}

class _ContinueReadingBannerState extends State<_ContinueReadingBanner> {
  ({int surah, String name, int ayah})? _last;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final last = await QuranProgressService.getLastRead();
    if (!mounted) return;
    setState(() => _last = last);
  }

  @override
  Widget build(BuildContext context) {
    final last = _last;
    if (last == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: () => widget.onOpen(last.surah),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Continue reading',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      last.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
