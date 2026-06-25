import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quran.dart';
import '../services/quran_service.dart';
import '../services/app_settings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SurahReaderScreen extends StatefulWidget {
  final Surah surahMeta;
  const SurahReaderScreen({super.key, required this.surahMeta});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  Surah? _full;
  String? _error;
  bool _showTranslation = true;
  String _language = 'English';

  final AudioPlayer _player = AudioPlayer();
  int? _playingAyah; // numberInSurah currently playing

  @override
  void initState() {
    super.initState();
    _init();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingAyah = null);
    });
  }

  Future<void> _init() async {
    _language = await AppSettings.getTranslationLanguage();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _full = null;
    });
    try {
      final full =
          await QuranService.getSurah(widget.surahMeta.number, language: _language);
      if (!mounted) return;
      setState(() => _full = full);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _toggleLanguage() async {
    final newLang = _language == 'English' ? 'Urdu' : 'English';
    setState(() => _language = newLang);
    await AppSettings.setTranslationLanguage(newLang);
    _load();
  }

  Future<void> _playAyah(Ayah ayah) async {
    if (ayah.audioUrl == null) return;
    if (_playingAyah == ayah.numberInSurah) {
      await _player.stop();
      setState(() => _playingAyah = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(ayah.audioUrl!));
      setState(() => _playingAyah = ayah.numberInSurah);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahMeta.nameEnglish),
        actions: [
          TextButton(
            onPressed: _toggleLanguage,
            child: Text(
              _language == 'English' ? 'EN' : 'اردو',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Toggle translation',
            icon: Icon(_showTranslation
                ? Icons.translate_rounded
                : Icons.translate_outlined),
            onPressed: () =>
                setState(() => _showTranslation = !_showTranslation),
          ),
        ],
      ),
      body: SafeArea(
        child: _error != null
            ? _buildError()
            : _full == null
                ? const Center(child: CircularProgressIndicator())
                : _buildReader(_full!),
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

  Widget _buildReader(Surah surah) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surah.ayahs.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return _buildHeader(surah);
        final ayah = surah.ayahs[i - 1];
        return _buildAyah(ayah);
      },
    );
  }

  Widget _buildHeader(Surah surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            surah.nameArabic,
            style: AppTheme.arabicStyle(
              color: Colors.white,
              fontSize: 34,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${surah.nameEnglish} · ${surah.nameTranslation}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '${surah.ayahCount} verses · ${surah.revelationType}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
          if (surah.number != 1 && surah.number != 9) ...[
            const SizedBox(height: 16),
            Text(
              'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              style: AppTheme.arabicStyle(
                color: AppColors.goldLight,
                fontSize: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAyah(Ayah ayah) {
    final isPlaying = _playingAyah == ayah.numberInSurah;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isPlaying
            ? Border.all(color: AppColors.gold, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${ayah.numberInSurah}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const Spacer(),
              if (ayah.audioUrl != null)
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_outline_rounded,
                    color: AppColors.gold,
                  ),
                  onPressed: () => _playAyah(ayah),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              ayah.arabicText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color!,
                fontSize: 26,
                height: 2.0,
              ),
            ),
          ),
          if (_showTranslation && ayah.translationText != null) ...[
            const SizedBox(height: 12),
            Text(
              ayah.translationText!,
              textAlign:
                  _language == 'Urdu' ? TextAlign.right : TextAlign.left,
              textDirection:
                  _language == 'Urdu' ? TextDirection.rtl : TextDirection.ltr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
