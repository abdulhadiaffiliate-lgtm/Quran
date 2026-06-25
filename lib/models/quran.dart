/// A single verse (ayah) of the Quran.
class Ayah {
  final int numberInSurah;
  final String arabicText;
  final String? translationText;

  Ayah({
    required this.numberInSurah,
    required this.arabicText,
    this.translationText,
  });
}

/// A chapter (surah) of the Quran, with metadata and its verses.
class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTranslation;
  final String revelationType;
  final int ayahCount;
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTranslation,
    required this.revelationType,
    required this.ayahCount,
    this.ayahs = const [],
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      nameArabic: json['name'],
      nameEnglish: json['englishName'],
      nameTranslation: json['englishNameTranslation'],
      revelationType: json['revelationType'],
      ayahCount: json['numberOfAyahs'],
    );
  }

  Surah withAyahs(List<Ayah> ayahs) {
    return Surah(
      number: number,
      nameArabic: nameArabic,
      nameEnglish: nameEnglish,
      nameTranslation: nameTranslation,
      revelationType: revelationType,
      ayahCount: ayahCount,
      ayahs: ayahs,
    );
  }
}
