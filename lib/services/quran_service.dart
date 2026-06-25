import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran.dart';

/// Wraps the Al Quran Cloud API (api.alquran.cloud) for Quran text
/// and translations. No API key required.
class QuranService {
  static const _baseUrl = 'https://api.alquran.cloud/v1';

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

  /// Fetches a single surah's Arabic text plus an optional translation
  /// edition (e.g. 'en.sahih' for Sahih International English).
  static Future<Surah> getSurah(
    int number, {
    String translationEdition = 'en.sahih',
  }) async {
    final arabicUri = Uri.parse('$_baseUrl/surah/$number/quran-uthmani');
    final translationUri =
        Uri.parse('$_baseUrl/surah/$number/$translationEdition');

    final results = await Future.wait([
      http.get(arabicUri),
      http.get(translationUri),
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

    final List arabicAyahs = arabicBody['ayahs'];
    final ayahs = <Ayah>[];
    for (var i = 0; i < arabicAyahs.length; i++) {
      ayahs.add(Ayah(
        numberInSurah: arabicAyahs[i]['numberInSurah'],
        arabicText: arabicAyahs[i]['text'],
        translationText:
            translationAyahs != null ? translationAyahs[i]['text'] : null,
      ));
    }

    return base.withAyahs(ayahs);
  }
}
