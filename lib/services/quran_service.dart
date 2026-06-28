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
  /// offline assets ONLY — instant, no network call, works fully offline.
  /// Audio is attached separately via [attachAudio] so the reader can
  /// display text immediately without waiting on the network at all.
  static Future<Surah> getSurahText(
    int number, {
    String language = 'English',
  }) async {
    final cacheKey = '$number-$language';
    final cached = _cachedSurahs[cacheKey];
    if (cached != null) return cached;

    final langFolder = translationEditions[language] ?? 'en';
    final arabicRaw =
        await rootBundle.loadString('assets/quran/ar/$number.json');
    final translationRaw =
        await rootBundle.loadString('assets/quran/$langFolder/$number.json');

    final arabicData = json.decode(arabicRaw);
    final translationData = json.decode(translationRaw);

    final List arabicVerses = arabicData['verses'];
    final List translationVerses = translationData['verses'];

    final ayahs = <Ayah>[];
    for (var i = 0; i < arabicVerses.length; i++) {
      ayahs.add(Ayah(
        numberInSurah: arabicVerses[i]['id'],
        arabicText: arabicVerses[i]['text'],
        translationText: i < translationVerses.length
            ? translationVerses[i]['translation']
            : null,
      ));
    }

    final surah = Surah(
      number: number,
      nameArabic: arabicData['name'],
      nameEnglish: arabicData['transliteration'],
      nameTranslation: translationData['translation'] ?? '',
      revelationType: arabicData['type'],
      ayahCount: arabicData['total_verses'],
      ayahs: ayahs,
    );
    _cachedSurahs[cacheKey] = surah;
    return surah;
  }

  /// Attempts to fetch per-ayah audio URLs for [base] over the network and
  /// returns a new Surah with audio attached. Returns null (rather than
  /// throwing) if there's no internet or the request fails/times out, so
  /// callers can simply keep showing the text-only surah.
  static Future<Surah?> attachAudio(
    Surah base, {
    String? reciterId,
  }) async {
    final edition = reciterId ?? audioEdition;
    try {
      final audioUri =
          Uri.parse('$_baseUrl/surah/${base.number}/$edition');
      final audioRes = await http
          .get(audioUri)
          .timeout(const Duration(seconds: 6));
      if (audioRes.statusCode != 200) return null;

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
    } catch (_) {
      return null;
    }
  }

  /// Convenience wrapper kept for compatibility: loads text instantly from
  /// offline assets, then tries (briefly) to attach audio before
  /// returning. Prefer calling [getSurahText] + [attachAudio] separately
  /// in UI code so text can render before audio arrives.
  static Future<Surah> getSurah(
    int number, {
    String language = 'English',
    String? reciterId,
  }) async {
    final base = await getSurahText(number, language: language);
    final withAudio = await attachAudio(base, reciterId: reciterId);
    return withAudio ?? base;
  }
}
