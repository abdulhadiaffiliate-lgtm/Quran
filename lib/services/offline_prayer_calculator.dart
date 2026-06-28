import 'dart:math' as math;
import '../models/prayer_times.dart';

/// Computes prayer times locally using standard astronomical formulas,
/// so the app works with no internet. Implements the same calculation
/// methods (by fajr/isha twilight angles) used by the AlAdhan API.
///
/// Based on the well-documented PrayTimes algorithm (praytimes.org),
/// reimplemented in Dart. No external dependencies.
class OfflinePrayerCalculator {
  OfflinePrayerCalculator._();

  // Twilight angles per calculation method id (matching AlAdhan ids).
  // Each entry: (fajrAngle, ishaAngle, ishaIsInterval, ishaIntervalMins)
  static ({double fajr, double isha, bool ishaInterval, int ishaMins})
      _params(int method) {
    switch (method) {
      case 2: // ISNA
        return (fajr: 15.0, isha: 15.0, ishaInterval: false, ishaMins: 0);
      case 4: // Umm al-Qura
        return (fajr: 18.5, isha: 0.0, ishaInterval: true, ishaMins: 90);
      case 1: // University of Islamic Sciences, Karachi
        return (fajr: 18.0, isha: 18.0, ishaInterval: false, ishaMins: 0);
      case 5: // Egyptian General Authority
        return (fajr: 19.5, isha: 17.5, ishaInterval: false, ishaMins: 0);
      case 8: // Gulf Region
        return (fajr: 19.5, isha: 0.0, ishaInterval: true, ishaMins: 90);
      case 13: // Diyanet (close to MWL angles)
        return (fajr: 18.0, isha: 17.0, ishaInterval: false, ishaMins: 0);
      case 3: // Muslim World League
      default:
        return (fajr: 18.0, isha: 17.0, ishaInterval: false, ishaMins: 0);
    }
  }

  static double _dtr(double d) => d * math.pi / 180.0;
  static double _rtd(double r) => r * 180.0 / math.pi;

  static double _fixAngle(double a) {
    a = a - 360.0 * (a / 360.0).floorToDouble();
    return a < 0 ? a + 360.0 : a;
  }

  static double _fixHour(double h) {
    h = h - 24.0 * (h / 24.0).floorToDouble();
    return h < 0 ? h + 24.0 : h;
  }

  // Julian date for a given calendar date.
  static double _julian(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  // Sun declination and equation of time for a Julian date.
  static ({double declination, double equation}) _sunPosition(double jd) {
    final d = jd - 2451545.0;
    final g = _fixAngle(357.529 + 0.98560028 * d);
    final q = _fixAngle(280.459 + 0.98564736 * d);
    final l = _fixAngle(
        q + 1.915 * math.sin(_dtr(g)) + 0.020 * math.sin(_dtr(2 * g)));
    final e = 23.439 - 0.00000036 * d;
    final declination = _rtd(math.asin(math.sin(_dtr(e)) * math.sin(_dtr(l))));
    final ra = _rtd(math.atan2(
            math.cos(_dtr(e)) * math.sin(_dtr(l)), math.cos(_dtr(l)))) /
        15.0;
    final equation = q / 15.0 - _fixHour(ra);
    return (declination: declination, equation: equation);
  }

  // Compute the time (in hours) for a given sun altitude angle.
  static double _timeForAngle(
    double angle,
    double jd,
    double latitude,
    double baseTime,
  ) {
    final decl = _sunPosition(jd + baseTime / 24.0).declination;
    final t = (1 / 15.0) *
        _rtd(math.acos((-math.sin(_dtr(angle)) -
                math.sin(_dtr(decl)) * math.sin(_dtr(latitude))) /
            (math.cos(_dtr(decl)) * math.cos(_dtr(latitude)))));
    return t;
  }

  // Asr time factor (1 = Shafi'i/Maliki/Hanbali, 2 = Hanafi).
  static double _asrTime(
    double factor,
    double jd,
    double latitude,
    double baseTime,
  ) {
    final decl = _sunPosition(jd + baseTime / 24.0).declination;
    final angle = -_rtd(math.atan(
        1 / (factor + math.tan(_dtr((latitude - decl).abs())))));
    return _timeForAngle(angle, jd, latitude, baseTime);
  }

  /// Computes today's prayer times for the given coordinates and method.
  /// [asrFactor] 1 = standard, 2 = Hanafi.
  static PrayerTimes computeToday({
    required double latitude,
    required double longitude,
    int method = 3,
    double asrFactor = 1,
  }) {
    final now = DateTime.now();
    final tzOffsetHours = now.timeZoneOffset.inMinutes / 60.0;
    final jd = _julian(now.year, now.month, now.day) - longitude / (15.0 * 24.0);

    final p = _params(method);

    // Base noon (Dhuhr) calculation.
    final eqt = _sunPosition(jd + 0.5).equation;
    final noon = _fixHour(12 - eqt) - longitude / 15.0 + tzOffsetHours;

    final sunriseAngle = 0.833;
    final sunriseT = _timeForAngle(sunriseAngle, jd, latitude, 6.0 / 24.0);
    final sunrise = noon - sunriseT;
    final maghribT = _timeForAngle(sunriseAngle, jd, latitude, 18.0 / 24.0);
    final maghrib = noon + maghribT;

    final fajrT = _timeForAngle(p.fajr, jd, latitude, 5.0 / 24.0);
    final fajr = noon - fajrT;

    final asrT = _asrTime(asrFactor, jd, latitude, 13.0 / 24.0);
    final asr = noon + asrT;

    double isha;
    if (p.ishaInterval) {
      isha = maghrib + p.ishaMins / 60.0;
    } else {
      final ishaT = _timeForAngle(p.isha, jd, latitude, 18.0 / 24.0);
      isha = noon + ishaT;
    }

    DateTime toDateTime(double hours) {
      final h = _fixHour(hours);
      final hour = h.floor();
      final minute = ((h - hour) * 60).round();
      // Handle minute rounding to 60.
      var dt = DateTime(now.year, now.month, now.day, hour, 0)
          .add(Duration(minutes: minute));
      return dt;
    }

    return PrayerTimes(
      fajr: toDateTime(fajr),
      sunrise: toDateTime(sunrise),
      dhuhr: toDateTime(noon),
      asr: toDateTime(asr),
      maghrib: toDateTime(maghrib),
      isha: toDateTime(isha),
      hijriDate: '', // Filled in by caller via HijriDate helper if needed.
      gregorianDate:
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}',
    );
  }
}
