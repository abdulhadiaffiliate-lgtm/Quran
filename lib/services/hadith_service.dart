import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadith.dart';

/// Wraps the fawazahmed0/hadith-api served via the jsDelivr CDN.
/// No API key required; data is static JSON.
class HadithService {
  static const _base =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';

  /// A small curated set of editions we expose in the UI.
  /// Each entry maps a friendly book name to its English + Arabic edition slugs.
  static const Map<String, ({String eng, String ara, int count})> books = {
    'Sahih Bukhari': (eng: 'eng-bukhari', ara: 'ara-bukhari', count: 7563),
    'Sahih Muslim': (eng: 'eng-muslim', ara: 'ara-muslim', count: 7563),
    'Abu Dawud': (eng: 'eng-abudawud', ara: 'ara-abudawud', count: 5274),
    'Tirmidhi': (eng: 'eng-tirmidhi', ara: 'ara-tirmidhi', count: 3956),
    'Ibn Majah': (eng: 'eng-ibnmajah', ara: 'ara-ibnmajah', count: 4341),
    'Nasai': (eng: 'eng-nasai', ara: 'ara-nasai', count: 5662),
  };

  /// Fetches a single hadith by number from a given book, combining the
  /// English and Arabic editions.
  static Future<Hadith> getHadith({
    required String bookName,
    required int number,
  }) async {
    final edition = books[bookName];
    if (edition == null) {
      throw Exception('Unknown book: $bookName');
    }

    final engUri = Uri.parse('$_base/editions/${edition.eng}/$number.min.json');
    final araUri = Uri.parse('$_base/editions/${edition.ara}/$number.min.json');

    final results = await Future.wait([http.get(engUri), http.get(araUri)]);

    if (results[0].statusCode != 200) {
      throw Exception('Failed to load hadith (${results[0].statusCode})');
    }

    final engData = json.decode(results[0].body);
    final engHadith = (engData['hadiths'] as List).first;

    String arabicText = '';
    if (results[1].statusCode == 200) {
      final araData = json.decode(results[1].body);
      final araHadith = (araData['hadiths'] as List).first;
      arabicText = araHadith['text'] ?? '';
    }

    return Hadith(
      number: engHadith['hadithnumber'] ?? number,
      arabicText: arabicText,
      englishText: engHadith['text'] ?? '',
      book: bookName,
      grade: (engHadith['grades'] != null &&
              (engHadith['grades'] as List).isNotEmpty)
          ? engHadith['grades'][0]['grade']
          : null,
    );
  }

  /// Returns a deterministic "hadith of the day" — same hadith for everyone
  /// on a given calendar day, rotating daily.
  static Future<Hadith> getDailyHadith() async {
    // Use day-of-year to pick a book and a number deterministically.
    final now = DateTime.now();
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays + 1;

    final bookNames = books.keys.toList();
    final bookName = bookNames[dayOfYear % bookNames.length];
    final maxCount = books[bookName]!.count;
    // Keep number in a safe lower range to avoid gaps in sparse editions.
    final number = (dayOfYear * 7) % (maxCount > 2000 ? 2000 : maxCount) + 1;

    return getHadith(bookName: bookName, number: number);
  }
}
