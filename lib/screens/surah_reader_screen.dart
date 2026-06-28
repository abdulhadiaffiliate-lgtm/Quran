import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/quran.dart';
import '../services/quran_service.dart';
import '../services/app_settings.dart';
import '../services/quran_progress_service.dart';
import '../services/reciter_service.dart';
import '../services/ayah_timing_service.dart';
import '../services/offline_audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'learn_ayah_screen.dart';
import 'share_verse_screen.dart';

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
  String _reciterId = 'ar.alafasy';
  List<int> _ayahStartTimes = []; // ms, only populated when supported
  StreamSubscription<Duration>? _positionSub;

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
    _reciterId = await ReciterService.getSelectedId();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _full = null;
    });
    try {
      // Text loads instantly from bundled offline assets — no network
      // wait at all, so the surah displays immediately even with no
      // internet connection.
      final textOnly = await QuranService.getSurahText(
          widget.surahMeta.number,
          language: _language);
      if (!mounted) return;
      setState(() => _full = textOnly);
      QuranProgressService.saveLastRead(
        surahNumber: widget.surahMeta.number,
        surahName: widget.surahMeta.nameEnglish,
        ayahNumber: 1,
      );

      // Audio is attached afterward, in the background. If there's no
      // internet this simply fails quietly and play buttons stay hidden
      // for ayahs without an audio URL — the text remains fully readable.
      QuranService.attachAudio(textOnly, reciterId: _reciterId).then((withAudio) {
        if (!mounted || withAudio == null) return;
        setState(() => _full = withAudio);
      });

      _checkDownloadStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _checkDownloadStatus() async {
    final downloaded = await OfflineAudioService.isDownloaded(
        widget.surahMeta.number, _reciterId);
    if (!mounted) return;
    setState(() => _isDownloaded = downloaded);
  }

  Future<void> _downloadForOffline() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });
    final success = await OfflineAudioService.downloadSurah(
      widget.surahMeta.number,
      _reciterId,
      onProgress: (p) {
        if (mounted) setState(() => _downloadProgress = p);
      },
    );
    if (!mounted) return;
    setState(() {
      _isDownloading = false;
      _isDownloaded = success;
      _downloadProgress = null;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not download — check your connection')),
      );
    }
  }

  Future<void> _pickReciter() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              Text('Choose reciter',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...ReciterService.all.map((r) {
                final isSelected = r.id == _reciterId;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: AppColors.gold,
                  ),
                  title: Text(r.name),
                  onTap: () => Navigator.pop(ctx, r.id),
                );
              }),
            ],
          ),
        );
      },
    );
    if (selected != null && selected != _reciterId) {
      await ReciterService.setSelectedId(selected);
      setState(() => _reciterId = selected);
      await _player.stop();
      setState(() {
        _playingAll = false;
        _playingAyah = null;
      });
      _load(); // Reload to fetch per-ayah audio from the new reciter.
    }
  }

  Future<void> _toggleLanguage() async {
    final newLang = _language == 'English' ? 'Urdu' : 'English';
    setState(() => _language = newLang);
    await AppSettings.setTranslationLanguage(newLang);
    _load();
  }

  /// Strips Arabic diacritics (tashkeel) and normalizes Alef/Yeh variants
  /// so text comparisons aren't broken by minor Unicode differences
  /// between sources.
  static String _normalizeArabic(String input) {
    return input
        // Remove combining diacritical marks (fatha, kasra, damma, etc.)
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        // Normalize different forms of Alef to a plain Alef.
        .replaceAll(RegExp(r'[\u0622\u0623\u0625\u0671]'), '\u0627')
        // Normalize Alef Wasla (ٱ) too.
        .replaceAll('\u0671', '\u0627')
        .trim();
  }

  /// Strips a leading Bismillah from an ayah's Arabic text, since the
  /// Bismillah is shown separately in the surah header. Applies to the
  /// first ayah of every surah except Al-Fatihah (1), where Bismillah is
  /// itself a numbered verse, and At-Tawbah (9), which has no Bismillah.
  ///
  /// Matching is diacritic-insensitive so minor Unicode variations between
  /// data sources don't cause the duplicate to slip through.
  String _cleanFirstAyah(String text, int surahNumber, int ayahNumber) {
    if (ayahNumber != 1) return text;
    if (surahNumber == 1 || surahNumber == 9) return text;

    final normalizedText = _normalizeArabic(text);
    final normalizedBismillah = _normalizeArabic(_bismillah);

    if (normalizedText.startsWith(normalizedBismillah)) {
      // Walk the original text forward by the same number of "real"
      // characters as matched, skipping diacritics, so we cut at the
      // right point in the un-normalized string.
      int matched = 0;
      int cut = 0;
      final n = text.length;
      while (cut < n && matched < normalizedBismillah.length) {
        final normalizedChar = _normalizeArabic(text[cut]);
        if (normalizedChar.isNotEmpty) matched++;
        cut++;
      }
      // Consume any trailing diacritics that belong to the last matched
      // letter, plus any following space, so we don't leave a stray
      // combining mark or leading space on the remaining text.
      while (cut < n && RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]')
          .hasMatch(text[cut])) {
        cut++;
      }
      while (cut < n && text[cut] == ' ') {
        cut++;
      }
      final stripped = text.substring(cut).trim();
      return stripped.isEmpty ? text : stripped;
    }

    // Fallback: try removing a known-good literal variant directly.
    final stripped = text
        .replaceFirst(_bismillah, '')
        .replaceFirst('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '')
        .trim();
    return stripped.isEmpty ? text : stripped;
  }

  Future<void> _playAyah(Ayah ayah) async {
    if (ayah.audioUrl == null) return;
    _chainMode = false; // cancel any whole-surah streaming chain
    if (_playingAyah == ayah.numberInSurah) {
      await _player.stop();
      setState(() {
        _playingAyah = null;
        _playingAll = false;
      });
    } else {
      await _player.stop();
      await _player.play(UrlSource(ayah.audioUrl!));
      setState(() {
        _playingAyah = ayah.numberInSurah;
        _playingAll = false;
      });
    }
  }

  bool _bufferingFullSurah = false;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  double? _downloadProgress;

  // Index into the surah's ayahs while chain-playing for streaming.
  int _chainIndex = 0;
  bool _chainMode = false; // true when streaming verse-by-verse

  Future<void> _playWholeSurah() async {
    if (_playingAll) {
      // Stop play-all.
      _chainMode = false;
      await _player.stop();
      _positionSub?.cancel();
      setState(() {
        _playingAll = false;
        _playingAyah = null;
        _bufferingFullSurah = false;
      });
      return;
    }

    await _player.stop();

    // Prefer an offline source (bundled short surah, or previously
    // downloaded) — a single continuous file that's already local, so it
    // starts instantly.
    final offlinePath = await OfflineAudioService.getOfflineSource(
        widget.surahMeta.number, _reciterId);

    // Load timing data (for highlighting) regardless of playback method.
    _ayahStartTimes = await AyahTimingService.getAyahStartTimes(
      reciterId: _reciterId,
      surahNumber: widget.surahMeta.number,
      ayahCount: _full?.ayahs.length ?? widget.surahMeta.ayahCount,
    );

    setState(() {
      _playingAll = true;
      _playingAyah = null;
    });

    if (offlinePath != null) {
      // OFFLINE: one continuous local file, highlight via position timing.
      _chainMode = false;
      _positionSub?.cancel();
      _positionSub = _player.onPositionChanged.listen((pos) {
        if (!mounted || !_playingAll) return;
        if (_ayahStartTimes.isNotEmpty) {
          final index = AyahTimingService.ayahIndexForPosition(
              _ayahStartTimes, pos.inMilliseconds);
          if (index != null && index != _playingAyah) {
            setState(() => _playingAyah = index);
          }
        }
      });
      await _player.play(DeviceFileSource(offlinePath));
      return;
    }

    // STREAMING: chain the small per-ayah audio files instead of waiting
    // for one big continuous file to fully download. Each verse starts
    // playing within a second, and we advance to the next on completion.
    final ayahs = _full?.ayahs;
    if (ayahs == null || ayahs.isEmpty || ayahs.first.audioUrl == null) {
      // No per-ayah audio available (e.g. offline with no download) —
      // can't stream. Let the user know rather than sit silent.
      setState(() {
        _playingAll = false;
        _playingAyah = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Audio needs an internet connection, or download this surah for offline use.')),
      );
      return;
    }

    _positionSub?.cancel();
    _chainMode = true;
    _chainIndex = 0;
    _playChainAt(0);
  }

  Future<void> _playChainAt(int index) async {
    final ayahs = _full?.ayahs;
    if (!_chainMode || ayahs == null || index >= ayahs.length) {
      if (index >= (ayahs?.length ?? 0)) {
        // Finished the whole surah.
        _onTrackComplete();
      }
      return;
    }
    final ayah = ayahs[index];
    if (ayah.audioUrl == null) {
      _playChainAt(index + 1);
      return;
    }
    _chainIndex = index;
    setState(() => _playingAyah = ayah.numberInSurah);
    try {
      await _player.play(UrlSource(ayah.audioUrl!));
    } catch (_) {
      if (mounted && _chainMode) _playChainAt(index + 1);
    }
  }

  void _onTrackComplete() {
    if (!mounted) return;
    // In chain (streaming) mode, completion of one ayah means advance to
    // the next rather than stopping.
    if (_chainMode) {
      final next = _chainIndex + 1;
      final ayahs = _full?.ayahs;
      if (ayahs != null && next < ayahs.length) {
        _playChainAt(next);
        return;
      }
    }
    _chainMode = false;
    _positionSub?.cancel();
    setState(() {
      _playingAll = false;
      _playingAyah = null;
      _bufferingFullSurah = false;
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
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
          IconButton(
            tooltip: 'Choose reciter',
            icon: const Icon(Icons.record_voice_over_rounded),
            onPressed: _pickReciter,
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
            onPressed: _bufferingFullSurah ? null : _playWholeSurah,
            icon: _bufferingFullSurah
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.darkBg,
                    ),
                  )
                : Icon(_playingAll
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded),
            label: Text(_bufferingFullSurah
                ? 'Loading…'
                : (_playingAll ? 'Stop' : 'Play whole surah')),
          ),
          if (!OfflineAudioService.isBundled(
              widget.surahMeta.number, _reciterId)) ...[
            const SizedBox(height: 10),
            if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor:
                        AppColors.tealPrimary.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _downloadProgress != null
                        ? 'Downloading… ${(_downloadProgress! * 100).toStringAsFixed(0)}%'
                        : 'Downloading…',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.gold),
                  ),
                ],
              )
            else if (_isDownloaded)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.offline_pin_rounded,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  const Text('Available offline',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.success)),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _downloadForOffline,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download for offline'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
          ],
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
              Expanded(
                child: Text(
                  '${widget.surahMeta.nameEnglish} $surahNumber:${ayah.numberInSurah}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _BookmarkButton(
                surah: surahNumber,
                ayah: ayah.numberInSurah,
                surahName: widget.surahMeta.nameEnglish,
              ),
              _compactIconButton(
                tooltip: 'Learn this ayah',
                icon: Icons.school_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LearnAyahScreen(
                      surahNumber: surahNumber,
                      surahName: widget.surahMeta.nameEnglish,
                      ayahNumber: ayah.numberInSurah,
                      arabicText: arabic,
                    ),
                  ),
                ),
              ),
              if (ayah.audioUrl != null)
                _compactIconButton(
                  tooltip: isPlaying ? 'Pause' : 'Play this verse',
                  icon: isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_outline_rounded,
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
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShareVerseScreen(
                    arabicText: arabic,
                    translationText: ayah.translationText ?? '',
                    reference:
                        '${widget.surahMeta.nameEnglish} $surahNumber:${ayah.numberInSurah}',
                  ),
                ),
              ),
              icon: const Icon(Icons.ios_share_rounded,
                  size: 16, color: AppColors.gold),
              label: const Text(
                'Share',
                style: TextStyle(color: AppColors.gold, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 32),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A smaller, tighter icon button used in the ayah action row so four
  /// of them (share, bookmark, learn, play) fit comfortably without
  /// overflowing on narrower screens.
  static Widget _compactIconButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: AppColors.gold, size: 20),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

/// A small stateful bookmark toggle for an individual ayah.
class _BookmarkButton extends StatefulWidget {
  final int surah;
  final int ayah;
  final String surahName;
  const _BookmarkButton({
    required this.surah,
    required this.ayah,
    required this.surahName,
  });

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final b =
        await QuranProgressService.isBookmarked(widget.surah, widget.ayah);
    if (!mounted) return;
    setState(() => _bookmarked = b);
  }

  Future<void> _toggle() async {
    final now = await QuranProgressService.toggleBookmark(
      surah: widget.surah,
      ayah: widget.ayah,
      name: widget.surahName,
    );
    if (!mounted) return;
    setState(() => _bookmarked = now);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _bookmarked ? 'Remove bookmark' : 'Bookmark this ayah',
      icon: Icon(
        _bookmarked
            ? Icons.bookmark_rounded
            : Icons.bookmark_border_rounded,
        color: AppColors.gold,
      ),
      onPressed: _toggle,
    );
  }
}
