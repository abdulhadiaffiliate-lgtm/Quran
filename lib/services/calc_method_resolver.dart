/// Maps coordinates to the AlAdhan calculation method most commonly used
/// in that region, using rough geographic bounding boxes. This is a pure
/// Dart approach with no native dependencies (no geocoding plugin needed).
///
/// AlAdhan method IDs: see https://aladhan.com/calculation-methods
/// 1 = University of Islamic Sciences, Karachi
/// 2 = ISNA (North America)
/// 3 = Muslim World League (default fallback)
/// 4 = Umm al-Qura (Makkah)
/// 5 = Egyptian General Authority
/// 8 = Gulf Region
/// 12 = Union des organisations islamiques de France
/// 13 = Diyanet, Turkey
class CalcMethodResolver {
  CalcMethodResolver._();

  /// Human-readable names for the calculation methods this app supports
  /// choosing from, for display in Settings.
  static const Map<int, String> methodNames = {
    3: 'Muslim World League',
    2: 'ISNA (North America)',
    4: 'Umm al-Qura (Makkah)',
    1: 'University of Karachi',
    5: 'Egyptian General Authority',
    8: 'Gulf Region',
    13: 'Diyanet (Turkey)',
    12: 'UOIF (France)',
  };

  /// Returns a method id for the given coordinates. Never throws; falls
  /// back to Muslim World League (3) for anywhere not specifically mapped.
  static int resolveFromCoordinates(double lat, double lng) {
    // Saudi Arabia (Umm al-Qura)
    if (_inBox(lat, lng, 16.0, 32.5, 34.0, 56.0)) return 4;

    // Gulf states (UAE, Qatar, Bahrain, Kuwait, Oman) -> Gulf Region
    if (_inBox(lat, lng, 16.0, 30.0, 47.0, 60.0)) return 8;

    // Egypt -> Egyptian General Authority
    if (_inBox(lat, lng, 22.0, 32.0, 24.0, 37.0)) return 5;

    // Turkey -> Diyanet
    if (_inBox(lat, lng, 36.0, 42.5, 25.0, 45.0)) return 13;

    // South Asia (Pakistan, India, Bangladesh, Afghanistan) -> Karachi
    if (_inBox(lat, lng, 5.0, 38.0, 60.0, 93.0)) return 1;

    // North America (USA, Canada) -> ISNA
    if (_inBox(lat, lng, 14.0, 72.0, -170.0, -52.0)) return 2;

    // France -> UOIF
    if (_inBox(lat, lng, 41.0, 51.5, -5.5, 9.5)) return 12;

    // Southeast Asia (Indonesia, Malaysia, Singapore) -> MWL works well;
    // kept as fallback below rather than a distinct id here.

    // Default: Muslim World League
    return 3;
  }

  /// True if the coordinates fall within South Asia (Pakistan, India,
  /// Bangladesh, Afghanistan) — the same region used for the Karachi
  /// calculation method above. Reused to auto-default the Hijri date
  /// offset, since local moon-sighting in this region is reliably about
  /// a day behind the global astronomical calculation.
  static bool isSouthAsia(double lat, double lng) {
    return _inBox(lat, lng, 5.0, 38.0, 60.0, 93.0);
  }

  static bool _inBox(
    double lat,
    double lng,
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) {
    return lat >= minLat &&
        lat <= maxLat &&
        lng >= minLng &&
        lng <= maxLng;
  }
}
