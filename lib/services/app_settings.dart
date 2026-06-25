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
}
