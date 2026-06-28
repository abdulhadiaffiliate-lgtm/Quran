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
  // Structured Hijri fields, used to apply a manual ±1 day offset without
  // another network call.
  final int? hijriDay;
  final String? hijriMonthName;
  final int? hijriMonthNumber;
  final int? hijriYear;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.gregorianDate,
    this.hijriDay,
    this.hijriMonthName,
    this.hijriMonthNumber,
    this.hijriYear,
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

    final hijriDay = int.tryParse(hijri['day'].toString());
    final hijriMonthName = hijri['month']['en'] as String?;
    final hijriMonthNumber = int.tryParse(hijri['month']['number'].toString());
    final hijriYear = int.tryParse(hijri['year'].toString());

    return PrayerTimes(
      fajr: parseTime(timings['Fajr']),
      sunrise: parseTime(timings['Sunrise']),
      dhuhr: parseTime(timings['Dhuhr']),
      asr: parseTime(timings['Asr']),
      maghrib: parseTime(timings['Maghrib']),
      isha: parseTime(timings['Isha']),
      hijriDate: '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
      gregorianDate: date['gregorian']['date'] as String,
      hijriDay: hijriDay,
      hijriMonthName: hijriMonthName,
      hijriMonthNumber: hijriMonthNumber,
      hijriYear: hijriYear,
    );
  }

  /// Returns a Hijri date string adjusted by [offsetDays] (-1, 0, or +1),
  /// to account for local moon-sighting differing from the astronomical
  /// calculation. Falls back to the unadjusted [hijriDate] if structured
  /// fields aren't available or offset is 0.
  String hijriDateWithOffset(int offsetDays) {
    if (offsetDays == 0 ||
        hijriDay == null ||
        hijriMonthNumber == null ||
        hijriYear == null) {
      return hijriDate;
    }

    const hijriMonthNames = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Shaban',
      'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah',
    ];
    // Approximate Hijri month lengths (alternating 30/29; not exact for
    // every year, but good enough for a ±1 day manual nudge).
    const monthLengths = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];

    int day = hijriDay! + offsetDays;
    int monthIndex = hijriMonthNumber! - 1; // 0-based
    int year = hijriYear!;

    if (day < 1) {
      monthIndex -= 1;
      if (monthIndex < 0) {
        monthIndex = 11;
        year -= 1;
      }
      day = monthLengths[monthIndex];
    } else if (day > monthLengths[monthIndex]) {
      day = 1;
      monthIndex += 1;
      if (monthIndex > 11) {
        monthIndex = 0;
        year += 1;
      }
    }

    return '$day ${hijriMonthNames[monthIndex]} $year';
  }
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
