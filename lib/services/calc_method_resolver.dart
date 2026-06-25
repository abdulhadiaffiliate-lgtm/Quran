import 'package:geocoding/geocoding.dart';

/// Maps a country to the AlAdhan calculation method most commonly used
/// there. Falls back to Muslim World League (3) when unknown.
class CalcMethodResolver {
  CalcMethodResolver._();

  // AlAdhan method IDs: see https://aladhan.com/calculation-methods
  static const Map<String, int> _byCountryCode = {
    'SA': 4, // Umm al-Qura, Saudi Arabia
    'US': 2, // ISNA, North America
    'CA': 2,
    'EG': 5, // Egyptian General Authority
    'PK': 1, // University of Karachi
    'IN': 1,
    'BD': 1,
    'TR': 13, // Diyanet, Turkey
    'AE': 8, // Gulf Region
    'KW': 9,
    'QA': 10,
    'SG': 11, // Singapore
    'MY': 11,
    'ID': 11,
    'FR': 12, // Union Organization Islamic de France
    'MA': 21, // Morocco
    'JO': 23, // Jordan
  };

  /// Attempts to resolve a calculation method from coordinates by
  /// reverse-geocoding to a country code. Returns null on any failure,
  /// so the caller can fall back to a default.
  static Future<int?> resolveFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      final code = placemarks.first.isoCountryCode;
      if (code == null) return null;
      return _byCountryCode[code.toUpperCase()];
    } catch (_) {
      return null;
    }
  }
}
