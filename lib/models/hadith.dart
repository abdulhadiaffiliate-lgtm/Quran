/// Represents a single Hadith entry from the fawazahmed0/hadith-api dataset.
class Hadith {
  final int number;
  final String arabicText;
  final String englishText;
  final String book;
  final String? grade;

  Hadith({
    required this.number,
    required this.arabicText,
    required this.englishText,
    required this.book,
    this.grade,
  });

  factory Hadith.fromJson(Map<String, dynamic> json, {required String book}) {
    return Hadith(
      number: json['hadithnumber'] ?? json['number'] ?? 0,
      arabicText: json['arabic'] ?? '',
      englishText: json['text'] ?? json['english'] ?? '',
      book: book,
      grade: json['grades'] != null && (json['grades'] as List).isNotEmpty
          ? (json['grades'][0]['grade'] as String?)
          : null,
    );
  }
}
