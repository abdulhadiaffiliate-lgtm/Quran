import 'package:shared_preferences/shared_preferences.dart';

/// Tracks daily spiritual goals: Dhikr count, Quran pages read, and which
/// of the 5 prayers have been marked complete. All progress resets each
/// new calendar day; targets persist across days until changed.
class GoalsService {
  static const _dateKey = 'goals_date';
  static const _dhikrProgressKey = 'goals_dhikr_progress';
  static const _dhikrTargetKey = 'goals_dhikr_target';
  static const _quranProgressKey = 'goals_quran_progress';
  static const _quranTargetKey = 'goals_quran_target';
  static const _prayersDoneKey = 'goals_prayers_done'; // comma list

  static const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// Resets daily progress (not targets) if the stored date isn't today.
  static Future<void> _rolloverIfNewDay(SharedPreferences prefs) async {
    final storedDate = prefs.getString(_dateKey);
    final today = _today();
    if (storedDate != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_dhikrProgressKey, 0);
      await prefs.setInt(_quranProgressKey, 0);
      await prefs.setStringList(_prayersDoneKey, []);
    }
  }

  static Future<int> getDhikrTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dhikrTargetKey) ?? 100;
  }

  static Future<void> setDhikrTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dhikrTargetKey, target);
  }

  static Future<int> getDhikrProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNewDay(prefs);
    return prefs.getInt(_dhikrProgressKey) ?? 0;
  }

  static Future<void> addDhikr(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNewDay(prefs);
    final current = prefs.getInt(_dhikrProgressKey) ?? 0;
    await prefs.setInt(_dhikrProgressKey, current + count);
  }

  static Future<int> getQuranTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quranTargetKey) ?? 1;
  }

  static Future<void> setQuranTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_quranTargetKey, target);
  }

  static Future<int> getQuranProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNewDay(prefs);
    return prefs.getInt(_quranProgressKey) ?? 0;
  }

  static Future<void> addQuranPages(int pages) async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNewDay(prefs);
    final current = prefs.getInt(_quranProgressKey) ?? 0;
    await prefs.setInt(_quranProgressKey, current + pages);
  }

  static Future<Set<String>> getPrayersDone() async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNewDay(prefs);
    return (prefs.getStringList(_prayersDoneKey) ?? []).toSet();
  }

  static Future<void> togglePrayerDone(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNewDay(prefs);
    final done = (prefs.getStringList(_prayersDoneKey) ?? []).toSet();
    if (done.contains(prayerName)) {
      done.remove(prayerName);
    } else {
      done.add(prayerName);
    }
    await prefs.setStringList(_prayersDoneKey, done.toList());
  }
}
