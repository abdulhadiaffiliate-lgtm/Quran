import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the number of missed (qada) prayers the user still needs to make
/// up, per prayer type. Counts persist until changed.
class QadaService {
  static const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Witr'];

  static String _key(String prayer) => 'qada_$prayer';

  static Future<Map<String, int>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, int>{};
    for (final p in prayers) {
      result[p] = prefs.getInt(_key(p)) ?? 0;
    }
    return result;
  }

  static Future<void> increment(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key(prayer)) ?? 0;
    await prefs.setInt(_key(prayer), current + 1);
  }

  /// Decrements (when a make-up prayer is completed), not going below zero.
  static Future<void> decrement(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key(prayer)) ?? 0;
    if (current > 0) {
      await prefs.setInt(_key(prayer), current - 1);
    }
  }

  static Future<void> setCount(String prayer, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(prayer), count < 0 ? 0 : count);
  }
}
