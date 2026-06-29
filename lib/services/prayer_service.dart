import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times.dart';
import 'offline_prayer_calculator.dart';
import 'app_settings.dart';

/// Wraps the AlAdhan API (api.aladhan.com) for prayer times and Qibla
/// direction lookups. No API key required. Falls back to offline
/// calculation when there's no internet.
class PrayerService {
  static const _baseUrl = 'https://api.aladhan.com/v1';

  /// Fetches today's prayer times for the given coordinates. Tries the
  /// online API first; on failure, computes them offline so the app still
  /// works without internet. [method] is the calculation method ID.
  /// Asr timing follows the user's chosen juristic school (Hanafi by
  /// default), since this notably changes when Asr begins.
  static Future<PrayerTimes> getTodayTimings({
    required double latitude,
    required double longitude,
    int method = 3,
  }) async {
    final asrSchool = await AppSettings.getAsrSchool();
    final schoolParam = asrSchool == 'hanafi' ? 1 : 0;
    final asrFactor = asrSchool == 'hanafi' ? 2.0 : 1.0;

    try {
      final uri = Uri.parse(
        '$_baseUrl/timings?latitude=$latitude&longitude=$longitude&method=$method&school=$schoolParam',
      );
      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode != 200) {
        throw Exception('Failed to load prayer times (${response.statusCode})');
      }
      final body = json.decode(response.body);
      final times = PrayerTimes.fromJson(body['data']);
      await _cacheHijri(times.hijriDate);
      return times;
    } catch (_) {
      // Offline fallback: compute locally. Reuse last known Hijri date if any.
      final computed = OfflinePrayerCalculator.computeToday(
        latitude: latitude,
        longitude: longitude,
        method: method,
        asrFactor: asrFactor,
      );
      final hijri = await _cachedHijri();
      return PrayerTimes(
        fajr: computed.fajr,
        sunrise: computed.sunrise,
        dhuhr: computed.dhuhr,
        asr: computed.asr,
        maghrib: computed.maghrib,
        isha: computed.isha,
        hijriDate: hijri ?? '',
        gregorianDate: computed.gregorianDate,
      );
    }
  }

  static Future<void> _cacheHijri(String hijri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_hijri_date', hijri);
  }

  static Future<String?> _cachedHijri() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_hijri_date');
  }

  /// Returns the Qibla bearing in degrees from true north, for the
  /// given coordinates.
  static Future<double> getQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$_baseUrl/qibla/$latitude/$longitude');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load Qibla direction (${response.statusCode})');
    }
    final body = json.decode(response.body);
    return (body['data']['direction'] as num).toDouble();
  }
}
