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
  bool _playingAll = false;
  int _playAllIndex = 0;

  // The standard Bismillah text as it appears prefixed on first ayahs.
  static const _bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  @override
  void initState() {
    super.initState();
    _init();
    _player.onPlayerComplete.listen((_) => _onTrackComplete());
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
      final full = await QuranService.getSurah(widget.surahMeta.number,
          language: _language);
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

  /// Strips a leading Bismillah from an ayah's Arabic text, since the
  /// Bismillah is shown separately in the surah header. Applies to the
  /// first ayah of every surah except Al-Fatihah (1), where Bismillah is
  /// itself a numbered verse, and At-Tawbah (9), which has no Bismillah.
  String _cleanFirstAyah(String text, int surahNumber, int ayahNumber) {
    if (ayahNumber != 1) return text;
    if (surahNumber == 1 || surahNumber == 9) return text;
    // Remove the bismillah prefix (with or without small variations).
    final stripped = text
        .replaceFirst(_bismillah, '')
        .replaceFirst('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '')
        .trim();
    return stripped.isEmpty ? text : stripped;
  }

  Future<void> _playAyah(Ayah ayah) async {
    if (ayah.audioUrl == null) return;
    _playingAll = false;
    if (_playingAyah == ayah.numberInSurah) {
      await _player.stop();
      setState(() => _playingAyah = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(ayah.audioUrl!));
      setState(() => _playingAyah = ayah.numberInSurah);
    }
  }

  Future<void> _playWholeSurah() async {
    final ayahs = _full?.ayahs;
    if (ayahs == null || ayahs.isEmpty) return;

    if (_playingAll) {
      // Stop play-all.
      await _player.stop();
      setState(() {
        _playingAll = false;
        _playingAyah = null;
      });
      return;
    }

    setState(() {
      _playingAll = true;
      _playAllIndex = 0;
    });
    await _playAt(0);
  }

  Future<void> _playAt(int index) async {
    final ayahs = _full!.ayahs;
    if (index >= ayahs.length) {
      setState(() {
        _playingAll = false;
        _playingAyah = null;
      });
      return;
    }
    final ayah = ayahs[index];
    if (ayah.audioUrl == null) {
      _onTrackComplete();
      return;
    }
    await _player.play(UrlSource(ayah.audioUrl!));
    setState(() {
      _playAllIndex = index;
      _playingAyah = ayah.numberInSurah;
    });
  }

  void _onTrackComplete() {
    if (!mounted) return;
    if (_playingAll) {
      final next = _playAllIndex + 1;
      _playAt(next);
    } else {
      setState(() => _playingAyah = null);
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
        return _buildAyah(ayah, surah.number);
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
          // Bismillah shown in gold for every surah except At-Tawbah (9).
          if (surah.number != 9) ...[
            const SizedBox(height: 16),
            Text(
              _bismillah,
              textAlign: TextAlign.center,
              style: AppTheme.arabicStyle(
                color: AppColors.goldLight,
                fontSize: 24,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Play whole surah button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.darkBg,
            ),
            onPressed: _playWholeSurah,
            icon: Icon(_playingAll
                ? Icons.stop_rounded
                : Icons.play_arrow_rounded),
            label: Text(_playingAll ? 'Stop' : 'Play whole surah'),
          ),
        ],
      ),
    );
  }

  Widget _buildAyah(Ayah ayah, int surahNumber) {
    final isPlaying = _playingAyah == ayah.numberInSurah;
    final arabic =
        _cleanFirstAyah(ayah.arabicText, surahNumber, ayah.numberInSurah);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border:
            isPlaying ? Border.all(color: AppColors.gold, width: 1.5) : null,
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
              const SizedBox(width: 8),
              Text(
                '${widget.surahMeta.nameEnglish} $surahNumber:${ayah.numberInSurah}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
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
              arabic,
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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}
