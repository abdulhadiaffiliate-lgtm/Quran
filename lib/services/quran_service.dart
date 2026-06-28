import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/quran.dart';

/// Provides Quran text (Arabic + translations) from bundled offline
/// assets, so reading the Quran works instantly with no internet and no
/// lag. Audio recitation still streams from the Al Quran Cloud API/CDN,
/// since thousands of audio files can't reasonably be bundled.
class QuranService {
  static const _baseUrl = 'https://api.alquran.cloud/v1';

  /// Available translation languages the UI can switch between, mapped to
  /// the bundled asset folder name.
  static const Map<String, String> translationEditions = {
    'English': 'en',
    'Urdu': 'ur',
  };

  /// Default reciter edition (Mishary Rashid Alafasy). Used as a fallback;
  /// the actual reciter is chosen via ReciterService.
  static const String audioEdition = 'ar.alafasy';

  static List<Surah>? _cachedList;
  static final Map<String, Surah> _cachedSurahs = {}; // key: "$number-$lang"

  /// Loads the list of all 114 surahs with metadata, from a bundled
  /// offline asset. Instant, no network needed.
  static Future<List<Surah>> getSurahList() async {
    if (_cachedList != null) return _cachedList!;
    final raw = await rootBundle.loadString('assets/quran/index.json');
    final List data = json.decode(raw);
    final list = data.map((s) => Surah.fromJson(s)).toList();
    _cachedList = list;
    return list;
  }

  /// Loads a single surah's Arabic text and translation from bundled
  /// offline assets (instant, no network), then fetches per-ayah audio
  /// URLs from the given reciter over the network (audio still needs a
  /// connection to stream).
  static Future<Surah> getSurah(
    int number, {
    String language = 'English',
    String? reciterId,
  }) async {
    final cacheKey = '$number-$language';
    Surah? base = _cachedSurahs[cacheKey];

    if (base == null) {
      final langFolder = translationEditions[language] ?? 'en';
      final arabicRaw =
          await rootBundle.loadString('assets/quran/ar/$number.json');
      final translationRaw = await rootBundle
          .loadString('assets/quran/$langFolder/$number.json');

      final arabicData = json.decode(arabicRaw);
      final translationData = json.decode(translationRaw);

      final List arabicVerses = arabicData['verses'];
      final List translationVerses = translationData['verses'];

      final ayahs = <Ayah>[];
      for (var i = 0; i < arabicVerses.length; i++) {
        ayahs.add(Ayah(
          numberInSurah: arabicVerses[i]['id'],
          arabicText: arabicVerses[i]['text'],
          translationText:
              i < translationVerses.length ? translationVerses[i]['translation'] : null,
        ));
      }

      base = Surah(
        number: number,
        nameArabic: arabicData['name'],
        nameEnglish: arabicData['transliteration'],
        nameTranslation: translationData['translation'] ?? '',
        revelationType: arabicData['type'],
        ayahCount: arabicData['total_verses'],
        ayahs: ayahs,
      );
      _cachedSurahs[cacheKey] = base;
    }

    // Fetch audio URLs over the network (can fail gracefully — text still
    // displays and plays buttons simply won't have audio).
    final edition = reciterId ?? audioEdition;
    try {
      final audioUri = Uri.parse('$_baseUrl/surah/$number/$edition');
      final audioRes = await http.get(audioUri).timeout(
            const Duration(seconds: 10),
          );
      if (audioRes.statusCode == 200) {
        final List audioAyahs = json.decode(audioRes.body)['data']['ayahs'];
        final ayahsWithAudio = <Ayah>[];
        for (var i = 0; i < base.ayahs.length; i++) {
          final a = base.ayahs[i];
          ayahsWithAudio.add(Ayah(
            numberInSurah: a.numberInSurah,
            arabicText: a.arabicText,
            translationText: a.translationText,
            audioUrl: i < audioAyahs.length ? audioAyahs[i]['audio'] : null,
          ));
        }
        return base.withAyahs(ayahsWithAudio);
      }
    } catch (_) {
      // No internet or audio fetch failed — return text-only surah.
    }
    return base;
  }
}
