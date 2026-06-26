/// Rakat breakdown for the five daily prayers plus Jumu'ah, with separate
/// counts for the Hanafi and Shafi'i schools. Values represent the commonly
/// taught structure in each school.
class RakatData {
  final String prayer;
  final String arabicName;
  final String sunnahBefore;
  final String fard;
  final String sunnahAfter;
  final String extra; // Witr / Nafl / notes

  const RakatData({
    required this.prayer,
    required this.arabicName,
    required this.sunnahBefore,
    required this.fard,
    required this.sunnahAfter,
    required this.extra,
  });
}

class RakatGuide {
  RakatGuide._();

  static const List<RakatData> hanafi = [
    RakatData(
      prayer: 'Fajr',
      arabicName: 'الفجر',
      sunnahBefore: '2 (Sunnah Mu\'akkadah)',
      fard: '2',
      sunnahAfter: '—',
      extra: '—',
    ),
    RakatData(
      prayer: 'Dhuhr',
      arabicName: 'الظهر',
      sunnahBefore: '4 (Sunnah Mu\'akkadah)',
      fard: '4',
      sunnahAfter: '2 (Sunnah) + 2 (Nafl)',
      extra: '—',
    ),
    RakatData(
      prayer: 'Asr',
      arabicName: 'العصر',
      sunnahBefore: '4 (Sunnah Ghayr Mu\'akkadah)',
      fard: '4',
      sunnahAfter: '—',
      extra: '—',
    ),
    RakatData(
      prayer: 'Maghrib',
      arabicName: 'المغرب',
      sunnahBefore: '—',
      fard: '3',
      sunnahAfter: '2 (Sunnah) + 2 (Nafl)',
      extra: '—',
    ),
    RakatData(
      prayer: 'Isha',
      arabicName: 'العشاء',
      sunnahBefore: '4 (Sunnah Ghayr Mu\'akkadah)',
      fard: '4',
      sunnahAfter: '2 (Sunnah) + 2 (Nafl)',
      extra: '3 Witr (Wajib) + 2 Nafl',
    ),
    RakatData(
      prayer: 'Jumu\'ah',
      arabicName: 'الجمعة',
      sunnahBefore: '4 (Sunnah)',
      fard: '2 (with khutbah)',
      sunnahAfter: '4 + 2 (Sunnah) + 2 (Nafl)',
      extra: 'Replaces Dhuhr on Friday',
    ),
  ];

  static const List<RakatData> shafii = [
    RakatData(
      prayer: 'Fajr',
      arabicName: 'الفجر',
      sunnahBefore: '2 (Sunnah Mu\'akkadah)',
      fard: '2',
      sunnahAfter: '—',
      extra: '—',
    ),
    RakatData(
      prayer: 'Dhuhr',
      arabicName: 'الظهر',
      sunnahBefore: '2 or 4 (Sunnah Mu\'akkadah)',
      fard: '4',
      sunnahAfter: '2 (Sunnah Mu\'akkadah)',
      extra: '—',
    ),
    RakatData(
      prayer: 'Asr',
      arabicName: 'العصر',
      sunnahBefore: '4 (Sunnah, optional)',
      fard: '4',
      sunnahAfter: '—',
      extra: '—',
    ),
    RakatData(
      prayer: 'Maghrib',
      arabicName: 'المغرب',
      sunnahBefore: '—',
      fard: '3',
      sunnahAfter: '2 (Sunnah Mu\'akkadah)',
      extra: '—',
    ),
    RakatData(
      prayer: 'Isha',
      arabicName: 'العشاء',
      sunnahBefore: '—',
      fard: '4',
      sunnahAfter: '2 (Sunnah Mu\'akkadah)',
      extra: 'Witr 1–11 (Sunnah Mu\'akkadah), commonly 3',
    ),
    RakatData(
      prayer: 'Jumu\'ah',
      arabicName: 'الجمعة',
      sunnahBefore: '—',
      fard: '2 (with khutbah)',
      sunnahAfter: '2 or 4 (Sunnah)',
      extra: 'Replaces Dhuhr on Friday',
    ),
  ];
}
