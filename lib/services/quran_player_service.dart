import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/quran.dart';
import 'offline_audio_service.dart';
import 'reciter_service.dart';

/// Playback state broadcast to the mini-player and the surah reader.
class QuranPlayerState {
  final bool isPlaying;
  final bool isPaused;
  final int? surahNumber;
  final String? surahName;
  final int? ayahIndex;      // 0-based index in the surah
  final int? totalAyahs;
  final String? reciterId;

  const QuranPlayerState({
    this.isPlaying = false,
    this.isPaused = false,
    this.surahNumber,
    this.surahName,
    this.ayahIndex,
    this.totalAyahs,
    this.reciterId,
  });

  bool get hasTrack => surahNumber != null;

  QuranPlayerState copyWith({
    bool? isPlaying,
    bool? isPaused,
    int? surahNumber,
    String? surahName,
    int? ayahIndex,
    int? totalAyahs,
    String? reciterId,
  }) => QuranPlayerState(
        isPlaying: isPlaying ?? this.isPlaying,
        isPaused: isPaused ?? this.isPaused,
        surahNumber: surahNumber ?? this.surahNumber,
        surahName: surahName ?? this.surahName,
        ayahIndex: ayahIndex ?? this.ayahIndex,
        totalAyahs: totalAyahs ?? this.totalAyahs,
        reciterId: reciterId ?? this.reciterId,
      );

  QuranPlayerState stopped() => const QuranPlayerState();
}

/// Global singleton that owns the AudioPlayer so playback continues when
/// the user navigates away from the Surah reader. All screens and the
/// mini-player listen to [stateStream] and call methods here instead of
/// managing their own AudioPlayer instances.
class QuranPlayerService extends ChangeNotifier {
  QuranPlayerService._();
  static final QuranPlayerService instance = QuranPlayerService._();

  final AudioPlayer _player = AudioPlayer();

  QuranPlayerState _state = const QuranPlayerState();
  QuranPlayerState get state => _state;

  List<Ayah>? _ayahs;
  bool _chainMode = false;
  int _chainIndex = 0;
  StreamSubscription<void>? _completeSub;
  StreamSubscription<Duration>? _positionSub;

  // Streams for ayah highlight tracking (listened to by SurahReaderScreen)
  final StreamController<int?> _ayahHighlightController =
      StreamController.broadcast();
  Stream<int?> get ayahHighlightStream => _ayahHighlightController.stream;

  List<int> _ayahStartTimes = [];

  void _setState(QuranPlayerState s) {
    _state = s;
    notifyListeners();
  }

  /// Start playing the whole surah. Checks for offline/bundled source first,
  /// falls back to per-ayah streaming chain.
  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    required List<Ayah> ayahs,
    required String reciterId,
    List<int> ayahStartTimes = const [],
  }) async {
    await _player.stop();
    _chainMode = false;
    _completeSub?.cancel();
    _positionSub?.cancel();

    _ayahs = ayahs;
    _ayahStartTimes = ayahStartTimes;

    _setState(QuranPlayerState(
      isPlaying: true,
      isPaused: false,
      surahNumber: surahNumber,
      surahName: surahName,
      ayahIndex: 0,
      totalAyahs: ayahs.length,
      reciterId: reciterId,
    ));

    // Try offline first
    final offlinePath = await OfflineAudioService.getOfflineSource(
        surahNumber, reciterId);

    if (offlinePath != null) {
      _chainMode = false;
      _positionSub = _player.onPositionChanged.listen((pos) {
        if (_ayahStartTimes.isNotEmpty) {
          int? idx;
          for (int i = 0; i < _ayahStartTimes.length; i++) {
            if (pos.inMilliseconds >= _ayahStartTimes[i]) idx = i;
          }
          if (idx != null && idx != _state.ayahIndex) {
            _setState(_state.copyWith(ayahIndex: idx));
            _ayahHighlightController.add(idx);
          }
        }
      });
      _completeSub = _player.onPlayerComplete.listen((_) => _onComplete());
      await _player.play(DeviceFileSource(offlinePath));
    } else {
      // Per-ayah streaming chain
      _chainMode = true;
      _chainIndex = 0;
      _completeSub = _player.onPlayerComplete.listen((_) => _onComplete());
      await _playChainAt(0);
    }
  }

  Future<void> _playChainAt(int index) async {
    final ayahs = _ayahs;
    if (!_chainMode || ayahs == null || index >= ayahs.length) return;
    if (ayahs[index].audioUrl == null) {
      await _playChainAt(index + 1);
      return;
    }
    _chainIndex = index;
    _setState(_state.copyWith(
      ayahIndex: index,
      isPlaying: true,
      isPaused: false,
    ));
    _ayahHighlightController.add(index);
    try {
      await _player.play(UrlSource(ayahs[index].audioUrl!));
    } catch (_) {
      if (_chainMode) await _playChainAt(index + 1);
    }
  }

  void _onComplete() {
    if (_chainMode) {
      final ayahs = _ayahs;
      final next = _chainIndex + 1;
      if (ayahs != null && next < ayahs.length) {
        _playChainAt(next);
        return;
      }
    }
    _chainMode = false;
    _ayahHighlightController.add(null);
    _setState(_state.stopped());
  }

  Future<void> pause() async {
    await _player.pause();
    _setState(_state.copyWith(isPlaying: false, isPaused: true));
  }

  Future<void> resume() async {
    await _player.resume();
    _setState(_state.copyWith(isPlaying: true, isPaused: false));
  }

  Future<void> togglePlayPause() async {
    if (_state.isPlaying) {
      await pause();
    } else if (_state.isPaused) {
      await resume();
    }
  }

  Future<void> stop() async {
    _chainMode = false;
    _completeSub?.cancel();
    _positionSub?.cancel();
    await _player.stop();
    _ayahHighlightController.add(null);
    _setState(_state.stopped());
  }

  /// Jump to a specific ayah during chain playback.
  Future<void> playAyah(int index) async {
    await _player.stop();
    _chainMode = true;
    await _playChainAt(index);
  }

  @override
  void dispose() {
    _player.dispose();
    _completeSub?.cancel();
    _positionSub?.cancel();
    _ayahHighlightController.close();
    super.dispose();
  }
}
