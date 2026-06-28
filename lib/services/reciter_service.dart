import 'package:shared_preferences/shared_preferences.dart';

/// A curated list of well-known Quran reciters, mapped to their AlQuran
/// Cloud / islamic.network audio edition identifiers. These identifiers
/// work both for per-ayah audio (via the API) and full-surah continuous
/// audio (via the CDN's audio-surah path).
class Reciter {
  final String id; // edition identifier, e.g. "ar.alafasy"
  final String name;

  const Reciter({required this.id, required this.name});
}

class ReciterService {
  ReciterService._();

  static const List<Reciter> all = [
    Reciter(id: 'ar.alafasy', name: 'Mishary Rashid Alafasy'),
    Reciter(id: 'ar.abdulbasitmurattal', name: 'Abdul Basit (Murattal)'),
    Reciter(id: 'ar.abdulbasitmujawwad', name: 'Abdul Basit (Mujawwad)'),
    Reciter(id: 'ar.husary', name: 'Mahmoud Al-Husary'),
    Reciter(id: 'ar.minshawi', name: 'Mohamed Al-Minshawi'),
    Reciter(id: 'ar.muhammadayyoub', name: 'Muhammad Ayyub'),
    Reciter(id: 'ar.mahermuaiqly', name: 'Maher Al-Muaiqly'),
    Reciter(id: 'ar.saoodshuraym', name: 'Saud Al-Shuraim'),
  ];

  static const _key = 'selected_reciter';
  static const _defaultId = 'ar.alafasy';

  static Future<String> getSelectedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? _defaultId;
  }

  static Future<void> setSelectedId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
  }

  static Reciter getById(String id) {
    return all.firstWhere((r) => r.id == id, orElse: () => all.first);
  }

  /// Builds the URL for a single continuous full-surah audio file (no
  /// per-ayah gaps), served from the islamic.network CDN.
  static String fullSurahUrl(String reciterId, int surahNumber,
      {int bitrate = 128}) {
    return 'https://cdn.islamic.network/quran/audio-surah/$bitrate/$reciterId/$surahNumber.mp3';
  }
}
