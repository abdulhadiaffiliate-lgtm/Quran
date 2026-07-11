import 'package:shared_preferences/shared_preferences.dart';

/// Tracks a daily login streak — consecutive calendar days the user opens
/// the app. Updated once per day on launch.
class StreakService {
  static const _lastOpenKey = 'streak_last_open'; // yyyy-mm-dd
  static const _currentKey = 'streak_current';
  static const _bestKey = 'streak_best';
  static const _popupShownKey = 'streak_popup_shown'; // yyyy-mm-dd

  /// Call once per app open. Updates the streak and returns the result.
  static Future<({int current, int best, bool isNewDay})> recordOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastOpen = prefs.getString(_lastOpenKey);
    int current = prefs.getInt(_currentKey) ?? 0;
    int best = prefs.getInt(_bestKey) ?? 0;

    bool isNewDay = false;

    if (lastOpen == null) {
      current = 1;
      isNewDay = true;
    } else if (lastOpen == today) {
      isNewDay = false;
    } else {
      final yesterday = _dateKey(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      current = (lastOpen == yesterday) ? current + 1 : 1;
      isNewDay = true;
    }

    if (current > best) best = current;

    if (isNewDay) {
      await prefs.setString(_lastOpenKey, today);
      await prefs.setInt(_currentKey, current);
      await prefs.setInt(_bestKey, best);
    }

    return (current: current, best: best, isNewDay: isNewDay);
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentKey) ?? 0;
  }

  /// Returns true the FIRST time it is called today — for showing the daily
  /// popup exactly once regardless of how many times the app is opened.
  static Future<bool> shouldShowPopupToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    if (prefs.getString(_popupShownKey) == today) return false;
    await prefs.setString(_popupShownKey, today);
    return true;
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
