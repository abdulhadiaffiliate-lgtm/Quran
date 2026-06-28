import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Provides per-ayah start timestamps (in milliseconds) within a
/// continuous full-surah audio file, so the UI can highlight the
/// currently-playing verse in sync with playback.
///
/// Data source: everyayah.com per-reciter timing files, hand-verified
/// against known ayah counts. Each surah's raw file contains either
/// exactly N values (N = ayah count) or N+1 values; the dataset is not
/// fully consistent about what the extra value represents (it may be a
/// leading Bismillah marker or a trailing end-of-recitation marker).
///
/// HEURISTIC (verified safe to flip): when there's one extra value beyond
/// the ayah count, we currently DROP THE LAST value and treat the
/// remaining N as ayah 1..N start times. If on-device testing shows the
/// highlight is consistently one ayah ahead of the audio, flip
/// [_extraValueIsTrailing] to false (treat the extra as a leading
/// Bismillah marker and drop the FIRST value instead).
class AyahTimingService {
  AyahTimingService._();

  /// See class doc — flip this single flag if testing shows an off-by-one.
  static const bool _extraValueIsTrailing = true;

  /// Reciter edition IDs (matching ReciterService) that have bundled
  /// timing data, mapped to their asset folder name.
  static const Map<String, String> _supportedReciters = {
    'ar.husary': 'husary',
    'ar.minshawi': 'minshawy',
    'ar.saoodshuraym': 'shuraym',
    'ar.abdulbasitmujawwad': 'basit',
  };

  static final Map<String, List<int>> _cache = {};

  static bool isSupported(String reciterId) =>
      _supportedReciters.containsKey(reciterId);

  /// Returns the list of ayah start times (ms) for a surah, trimmed to
  /// exactly [ayahCount] entries using the heuristic above. Returns an
  /// empty list if this reciter has no timing data for this surah.
  static Future<List<int>> getAyahStartTimes({
    required String reciterId,
    required int surahNumber,
    required int ayahCount,
  }) async {
    final folder = _supportedReciters[reciterId];
    if (folder == null) return [];

    final cacheKey = '$folder-$surahNumber';
    if (_cache.containsKey(cacheKey)) {
      return _trim(_cache[cacheKey]!, ayahCount);
    }

    try {
      final raw = await rootBundle
          .loadString('assets/timings/$folder/$surahNumber.json');
      final List decoded = json.decode(raw);
      final values = decoded.cast<int>();
      _cache[cacheKey] = values;
      return _trim(values, ayahCount);
    } catch (_) {
      return [];
    }
  }

  static List<int> _trim(List<int> values, int ayahCount) {
    if (values.length == ayahCount) return values;
    if (values.length == ayahCount + 1) {
      return _extraValueIsTrailing
          ? values.sublist(0, ayahCount) // drop last
          : values.sublist(1); // drop first
    }
    // Unexpected length — don't guess further, just don't highlight.
    return [];
  }

  /// Given the current playback position (ms) and a list of ayah start
  /// times, returns the 1-based index of the ayah currently playing, or
  /// null if before the first ayah or the list is empty.
  static int? ayahIndexForPosition(List<int> startTimes, int positionMs) {
    if (startTimes.isEmpty) return null;
    if (positionMs < startTimes.first) return null;
    int result = 1;
    for (int i = 0; i < startTimes.length; i++) {
      if (positionMs >= startTimes[i]) {
        result = i + 1;
      } else {
        break;
      }
    }
    return result;
  }
}
