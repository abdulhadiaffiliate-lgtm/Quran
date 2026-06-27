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
  /// on a given calendar day, rotating daily. Restricted to the two Sahih
  /// collections (Bukhari & Muslim) so only authentic hadith are shown.
  static Future<Hadith> getDailyHadith() async {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;

    // Only authentic (Sahih) collections for the daily hadith.
    const authenticBooks = ['Sahih Bukhari', 'Sahih Muslim'];
    final bookName = authenticBooks[dayOfYear % authenticBooks.length];
    final maxCount = books[bookName]!.count;
    // Keep number in a safe lower range to avoid gaps in sparse editions.
    final number = (dayOfYear * 7) % (maxCount > 2000 ? 2000 : maxCount) + 1;

    return getHadith(bookName: bookName, number: number);
  }

  // The four collections exposed in the tabbed books view.
  static const List<String> tabbedBooks = [
    'Sahih Bukhari',
    'Sahih Muslim',
    'Abu Dawud',
    'Tirmidhi',
  ];

  // In-memory cache of downloaded books (English + Arabic merged), keyed
  // by book name, so a book is only downloaded once per app session.
  static final Map<String, List<Hadith>> _bookCache = {};

  /// Downloads an entire book (English text + grades, merged with Arabic
  /// text) and caches it. Subsequent calls return the cached list.
  static Future<List<Hadith>> loadWholeBook(String bookName) async {
    if (_bookCache.containsKey(bookName)) {
      return _bookCache[bookName]!;
    }
    final edition = books[bookName];
    if (edition == null) throw Exception('Unknown book: $bookName');

    final engUri = Uri.parse('$_base/editions/${edition.eng}.min.json');
    final araUri = Uri.parse('$_base/editions/${edition.ara}.min.json');

    final results = await Future.wait([http.get(engUri), http.get(araUri)]);
    if (results[0].statusCode != 200) {
      throw Exception('Failed to load book (${results[0].statusCode})');
    }

    final engHadiths = json.decode(results[0].body)['hadiths'] as List;

    // Build a map of number -> arabic text for quick merge.
    final Map<int, String> arabicByNumber = {};
    if (results[1].statusCode == 200) {
      final araHadiths = json.decode(results[1].body)['hadiths'] as List;
      for (final h in araHadiths) {
        final n = h['hadithnumber'];
        if (n is int) arabicByNumber[n] = h['text'] ?? '';
      }
    }

    final list = <Hadith>[];
    for (final h in engHadiths) {
      final number = h['hadithnumber'];
      if (number is! int) continue;
      list.add(Hadith(
        number: number,
        arabicText: arabicByNumber[number] ?? '',
        englishText: h['text'] ?? '',
        book: bookName,
        grade: (h['grades'] != null && (h['grades'] as List).isNotEmpty)
            ? h['grades'][0]['grade']
            : null,
      ));
    }

    _bookCache[bookName] = list;
    return list;
  }

  /// Searches a book's hadith for a keyword (case-insensitive) in the
  /// English text. Downloads the book first if not cached.
  static Future<List<Hadith>> searchBook(
    String bookName,
    String query,
  ) async {
    final all = await loadWholeBook(bookName);
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all
        .where((h) => h.englishText.toLowerCase().contains(q))
        .toList();
  }
}
