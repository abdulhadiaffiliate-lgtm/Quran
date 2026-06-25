import 'package:flutter/material.dart';
import '../models/quran.dart';
import '../services/quran_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
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
      appBar: AppBar(title: const Text('Quran')),
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
