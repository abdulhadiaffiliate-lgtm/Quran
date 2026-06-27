import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches tafseer (Quranic commentary) per ayah from the spa5k/tafsir_api,
/// served via the jsDelivr CDN. No API key required.
///
/// Editions used (both mainstream, sound aqeedah):
///   English — Tafsir Ibn Kathir (abridged): en-tafisr-ibn-kathir
///   Urdu    — Tafsir Bayan ul Quran, Dr. Israr Ahmad: ur-tafsir-bayan-ul-quran
class TafseerService {
  static const _base = 'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir';

  static const englishEdition = 'en-tafisr-ibn-kathir';
  static const urduEdition = 'ur-tafsir-bayan-ul-quran';

  // Simple in-memory cache keyed by "edition/surah/ayah".
  static final Map<String, String> _cache = {};

  /// Fetches the tafseer text for a given ayah in the requested language.
  /// [language] should be 'English' or 'Urdu'.
  static Future<String> getTafseer({
    required int surah,
    required int ayah,
    required String language,
  }) async {
    final edition = language == 'Urdu' ? urduEdition : englishEdition;
    final key = '$edition/$surah/$ayah';
    if (_cache.containsKey(key)) return _cache[key]!;

    final uri = Uri.parse('$_base/$edition/$surah/$ayah.json');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Could not load tafseer (${res.statusCode})');
    }

    final data = json.decode(res.body);
    final text = (data['text'] ?? '').toString().trim();
    final cleaned = _stripHtml(text);
    _cache[key] = cleaned;
    return cleaned;
  }

  /// Removes basic HTML tags that sometimes appear in tafseer text.
  static String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .trim();
  }
}
