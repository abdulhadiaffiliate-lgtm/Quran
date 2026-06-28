import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the user's last-read surah and a list of bookmarked ayahs.
class QuranProgressService {
  static const _lastSurahKey = 'last_read_surah';
  static const _lastSurahNameKey = 'last_read_surah_name';
  static const _lastAyahKey = 'last_read_ayah';
  static const _bookmarksKey = 'quran_bookmarks';

  /// Saves the last-read position.
  static Future<void> saveLastRead({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSurahKey, surahNumber);
    await prefs.setString(_lastSurahNameKey, surahName);
    await prefs.setInt(_lastAyahKey, ayahNumber);
  }

  /// Returns the last-read position, or null if none saved.
  static Future<({int surah, String name, int ayah})?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_lastSurahKey);
    if (surah == null) return null;
    return (
      surah: surah,
      name: prefs.getString(_lastSurahNameKey) ?? 'Surah $surah',
      ayah: prefs.getInt(_lastAyahKey) ?? 1,
    );
  }

  /// Bookmarks are stored as "surah:ayah:surahName" strings.
  static Future<List<({int surah, int ayah, String name})>>
      getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookmarksKey) ?? [];
    return raw.map((s) {
      final parts = s.split(':');
      return (
        surah: int.tryParse(parts[0]) ?? 0,
        ayah: int.tryParse(parts[1]) ?? 0,
        name: parts.length > 2 ? parts[2] : 'Surah ${parts[0]}',
      );
    }).toList();
  }

  static String _key(int surah, int ayah, String name) =>
      '$surah:$ayah:$name';

  static Future<bool> isBookmarked(int surah, int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookmarksKey) ?? [];
    return raw.any((s) {
      final parts = s.split(':');
      return parts[0] == '$surah' && parts[1] == '$ayah';
    });
  }

  /// Toggles a bookmark. Returns true if now bookmarked, false if removed.
  static Future<bool> toggleBookmark({
    required int surah,
    required int ayah,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookmarksKey) ?? [];
    final existingIndex = raw.indexWhere((s) {
      final parts = s.split(':');
      return parts[0] == '$surah' && parts[1] == '$ayah';
    });
    if (existingIndex >= 0) {
      raw.removeAt(existingIndex);
      await prefs.setStringList(_bookmarksKey, raw);
      return false;
    } else {
      raw.add(_key(surah, ayah, name));
      await prefs.setStringList(_bookmarksKey, raw);
      return true;
    }
  }
}
