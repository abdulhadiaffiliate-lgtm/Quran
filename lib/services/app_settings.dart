import 'package:shared_preferences/shared_preferences.dart';

/// Notification style for prayer alerts.
enum NotifyStyle { azan, notification, silent }

/// Central store for user app settings backed by SharedPreferences.
class AppSettings {
  static const _onboardedKey = 'onboarding_complete';
  static const _notifyStyleKey = 'notify_style';
  static const _translationLangKey = 'translation_language';
  static const _calcMethodKey = 'calc_method';

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  static Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, value);
  }

  static Future<NotifyStyle> getNotifyStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notifyStyleKey) ?? 'notification';
    return NotifyStyle.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => NotifyStyle.notification,
    );
  }

  static Future<void> setNotifyStyle(NotifyStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notifyStyleKey, style.name);
  }

  static Future<String> getTranslationLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_translationLangKey) ?? 'English';
  }

  static Future<void> setTranslationLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_translationLangKey, lang);
  }

  /// AlAdhan calculation method id (default 3 = Muslim World League).
  static Future<int> getCalcMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_calcMethodKey) ?? 3;
  }

  static Future<void> setCalcMethod(int method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_calcMethodKey, method);
  }

  static const _calcAutoDetectedKey = 'calc_method_auto_detected';

  static Future<bool> isCalcMethodAutoDetected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_calcAutoDetectedKey) ?? false;
  }

  static Future<void> setCalcMethodAutoDetected(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_calcAutoDetectedKey, value);
  }

  static const _hijriOffsetKey = 'hijri_date_offset';

  /// Asr juristic school: 'hanafi' or 'shafii'. Affects when Asr begins —
  /// Hanafi uses the later (double-shadow-length) time, which is the
  /// standard followed across Pakistan and South Asia generally; Shafi'i
  /// (and Maliki/Hanbali) use the earlier (equal-shadow-length) time.
  /// Defaults to Hanafi.
  static const _asrSchoolKey = 'asr_school';

  static Future<String> getAsrSchool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_asrSchoolKey) ?? 'hanafi';
  }

  static Future<void> setAsrSchool(String school) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_asrSchoolKey, school);
  }

  /// Manual adjustment to the Hijri date in days (-1, 0, or +1), since
  /// astronomical calculation can differ from local moon-sighting by a day.
  static Future<int> getHijriOffset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_hijriOffsetKey) ?? 0;
  }

  static Future<void> setHijriOffset(int offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hijriOffsetKey, offset);
  }

  static const _hijriOffsetAutoDetectedKey = 'hijri_offset_auto_detected';

  /// True until the user manually changes the Hijri offset themselves —
  /// while true, the app may auto-apply a regional default (e.g. -1 day
  /// for South Asia, where local moon-sighting reliably runs a day behind
  /// the global astronomical calculation).
  static Future<bool> isHijriOffsetAutoDetected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hijriOffsetAutoDetectedKey) ?? true;
  }

  static Future<void> setHijriOffsetAutoDetected(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hijriOffsetAutoDetectedKey, value);
  }
}
