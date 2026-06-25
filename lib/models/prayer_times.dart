/// Represents the five daily prayer times plus sunrise, parsed from
/// the AlAdhan API's `timings` response object.
class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String hijriDate;
  final String gregorianDate;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.gregorianDate,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;

    DateTime parseTime(String raw) {
      // AlAdhan returns times like "05:32 (EET)" — strip any suffix.
      final cleaned = raw.split(' ').first;
      final parts = cleaned.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    return PrayerTimes(
      fajr: parseTime(timings['Fajr']),
      sunrise: parseTime(timings['Sunrise']),
      dhuhr: parseTime(timings['Dhuhr']),
      asr: parseTime(timings['Asr']),
      maghrib: parseTime(timings['Maghrib']),
      isha: parseTime(timings['Isha']),
      hijriDate:
          '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
      gregorianDate: date['gregorian']['date'] as String,
    );
  }

  /// Returns the list of (name, time) pairs in chronological order.
  List<MapEntry<String, DateTime>> get ordered => [
        MapEntry('Fajr', fajr),
        MapEntry('Sunrise', sunrise),
        MapEntry('Dhuhr', dhuhr),
        MapEntry('Asr', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Isha', isha),
      ];

  /// Returns the next upcoming prayer (excluding Sunrise, which isn't
  /// a prayer) relative to [from], wrapping to tomorrow's Fajr if needed.
  MapEntry<String, DateTime> nextPrayer(DateTime from) {
    final prayerOnly = [
      MapEntry('Fajr', fajr),
      MapEntry('Dhuhr', dhuhr),
      MapEntry('Asr', asr),
      MapEntry('Maghrib', maghrib),
      MapEntry('Isha', isha),
    ];
    for (final p in prayerOnly) {
      if (p.value.isAfter(from)) return p;
    }
    // All passed today; next is tomorrow's Fajr.
    return MapEntry('Fajr', fajr.add(const Duration(days: 1)));
  }
}
