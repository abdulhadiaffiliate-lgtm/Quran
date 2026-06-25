import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_times.dart';

/// Wraps the AlAdhan API (api.aladhan.com) for prayer times and Qibla
/// direction lookups. No API key required.
class PrayerService {
  static const _baseUrl = 'https://api.aladhan.com/v1';

  /// Fetches today's prayer times for the given coordinates.
  /// [method] is the calculation method ID (2 = ISNA, 4 = Umm al-Qura,
  /// 3 = Muslim World League, etc.) — defaults to MWL.
  static Future<PrayerTimes> getTodayTimings({
    required double latitude,
    required double longitude,
    int method = 3,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/timings?latitude=$latitude&longitude=$longitude&method=$method',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load prayer times (${response.statusCode})');
    }
    final body = json.decode(response.body);
    return PrayerTimes.fromJson(body['data']);
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
