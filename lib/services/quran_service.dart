import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran.dart';

/// Wraps the Al Quran Cloud API (api.alquran.cloud) for Quran text,
/// translations, and audio recitation. No API key required.
class QuranService {
  static const _baseUrl = 'https://api.alquran.cloud/v1';

  /// Available translation editions the UI can switch between.
  static const Map<String, String> translationEditions = {
    'English': 'en.sahih',
    'Urdu': 'ur.jalandhry',
  };

  /// Default reciter edition (Mishary Rashid Alafasy).
  static const String audioEdition = 'ar.alafasy';

  /// Fetches the list of all 114 surahs with metadata (no ayah text yet).
  static Future<List<Surah>> getSurahList() async {
    final uri = Uri.parse('$_baseUrl/surah');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load surah list (${response.statusCode})');
    }
    final body = json.decode(response.body);
    final List data = body['data'];
    return data.map((s) => Surah.fromJson(s)).toList();
  }

  /// Fetches a single surah's Arabic text, a translation in the chosen
  /// language, and per-ayah audio URLs from the default reciter.
  static Future<Surah> getSurah(
    int number, {
    String language = 'English',
  }) async {
    final translationEdition =
        translationEditions[language] ?? 'en.sahih';

    final arabicUri = Uri.parse('$_baseUrl/surah/$number/quran-uthmani');
    final translationUri =
        Uri.parse('$_baseUrl/surah/$number/$translationEdition');
    final audioUri = Uri.parse('$_baseUrl/surah/$number/$audioEdition');

    final results = await Future.wait([
      http.get(arabicUri),
      http.get(translationUri),
      http.get(audioUri),
    ]);

    if (results[0].statusCode != 200) {
      throw Exception('Failed to load surah text (${results[0].statusCode})');
    }

    final arabicBody = json.decode(results[0].body)['data'];
    final base = Surah.fromJson(arabicBody);

    List? translationAyahs;
    if (results[1].statusCode == 200) {
      translationAyahs = json.decode(results[1].body)['data']['ayahs'];
    }

    List? audioAyahs;
    if (results[2].statusCode == 200) {
      audioAyahs = json.decode(results[2].body)['data']['ayahs'];
    }

    final List arabicAyahs = arabicBody['ayahs'];
    final ayahs = <Ayah>[];
    for (var i = 0; i < arabicAyahs.length; i++) {
      ayahs.add(Ayah(
        numberInSurah: arabicAyahs[i]['numberInSurah'],
        arabicText: arabicAyahs[i]['text'],
        translationText:
            translationAyahs != null ? translationAyahs[i]['text'] : null,
        audioUrl: audioAyahs != null ? audioAyahs[i]['audio'] : null,
      ));
    }

    return base.withAyahs(ayahs);
  }
}
