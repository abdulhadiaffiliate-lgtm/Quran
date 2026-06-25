import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles obtaining the device location for prayer times and Qibla,
/// with graceful fallback to a last-known cached location.
class LocationService {
  static const _latKey = 'last_lat';
  static const _lngKey = 'last_lng';

  /// Requests permission if needed and returns the current position.
  /// Throws a [LocationException] with a user-readable message on failure.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location is turned off. Turn it on to get accurate prayer times.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Location permission is needed for prayer times and Qibla.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Enable it in settings.',
      );
    }

    final pos = await Geolocator.getCurrentPosition();
    await _cache(pos.latitude, pos.longitude);
    return pos;
  }

  static Future<void> _cache(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
  }

  /// Returns the last cached (lat, lng) if available, else null.
  static Future<({double lat, double lng})?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
  @override
  String toString() => message;
}
