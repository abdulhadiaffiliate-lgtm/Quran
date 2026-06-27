import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// A single word's breakdown: transliteration and English meaning.
class WordBreakdown {
  final String transliteration;
  final String meaning;

  const WordBreakdown({
    required this.transliteration,
    required this.meaning,
  });
}

/// Loads word-by-word data from bundled assets (assets/wbw/{surah}.json).
/// Data is offline, so no network is needed. Files are cached after first
/// read per surah.
class WordByWordService {
  static final Map<int, Map<String, List<WordBreakdown>>> _cache = {};

  /// Returns the list of word breakdowns for a given surah and ayah.
  /// Returns an empty list if not available.
  static Future<List<WordBreakdown>> getWords({
    required int surah,
    required int ayah,
  }) async {
    final surahData = await _loadSurah(surah);
    return surahData['$ayah'] ?? const [];
  }

  static Future<Map<String, List<WordBreakdown>>> _loadSurah(
      int surah) async {
    if (_cache.containsKey(surah)) return _cache[surah]!;
    try {
      final raw = await rootBundle.loadString('assets/wbw/$surah.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final result = <String, List<WordBreakdown>>{};
      decoded.forEach((ayahKey, words) {
        result[ayahKey] = (words as List)
            .map((w) => WordBreakdown(
                  transliteration: w['r'] ?? '',
                  meaning: w['t'] ?? '',
                ))
            .toList();
      });
      _cache[surah] = result;
      return result;
    } catch (_) {
      _cache[surah] = {};
      return {};
    }
  }
}
