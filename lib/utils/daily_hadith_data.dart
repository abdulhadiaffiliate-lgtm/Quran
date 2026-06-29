/// A single curated hadith entry: hand-picked for being genuinely
/// instructive — either a clear command, or a clear, actionable benefit —
/// rather than narration-only or context-only content. All entries here
/// are Sahih (authentic), drawn only from Bukhari and Muslim.
class DailyHadithEntry {
  final String arabicText;
  final String englishText;
  final String source; // "Sahih Bukhari" or "Sahih Muslim"
  final String reference; // e.g. "Bukhari 1"

  const DailyHadithEntry({
    required this.arabicText,
    required this.englishText,
    required this.source,
    required this.reference,
  });
}

/// A hand-curated, rotating set of beneficial Sahih hadith, used for the
/// "Hadith of the Day" feature. Chosen deliberately for clear, practical
/// value — a command to act on, or a benefit to take to heart — rather
/// than picked at random by hadith number (which can land on narration
/// chains or context-only content with little standalone value).
///
/// Restricted strictly to Sahih Bukhari and Sahih Muslim, since both
/// collections are authentic by scholarly consensus.
class DailyHadithData {
  DailyHadithData._();

  static const List<DailyHadithEntry> entries = [
    DailyHadithEntry(
      arabicText:
          'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      englishText:
          'Actions are judged by intentions, and each person will be rewarded according to what he intended.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 1',
    ),
    DailyHadithEntry(
      arabicText:
          'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      englishText:
          'Whoever believes in Allah and the Last Day should speak good or remain silent.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 6018',
    ),
    DailyHadithEntry(
      arabicText:
          'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      englishText:
          'None of you truly believes until he loves for his brother what he loves for himself.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 13',
    ),
    DailyHadithEntry(
      arabicText: 'الطُّهُورُ شَطْرُ الْإِيمَانِ',
      englishText: 'Cleanliness is half of faith.',
      source: 'Sahih Muslim',
      reference: 'Muslim 223',
    ),
    DailyHadithEntry(
      arabicText:
          'مَنْ كَانَ فِي حَاجَةِ أَخِيهِ كَانَ اللَّهُ فِي حَاجَتِهِ',
      englishText:
          'Whoever is engaged in helping his brother, Allah will be engaged in helping him.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 2442',
    ),
    DailyHadithEntry(
      arabicText:
          'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      englishText:
          'A Muslim is the one from whose tongue and hands other Muslims are safe.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 10',
    ),
    DailyHadithEntry(
      arabicText:
          'إِنَّ اللَّهَ رَفِيقٌ يُحِبُّ الرِّفْقَ، وَيُعْطِي عَلَى الرِّفْقِ مَا لَا يُعْطِي عَلَى الْعُنْفِ',
      englishText:
          'Allah is Gentle and loves gentleness, and He grants due to gentleness what He does not grant due to harshness.',
      source: 'Sahih Muslim',
      reference: 'Muslim 2593',
    ),
    DailyHadithEntry(
      arabicText:
          'لَا تَحَاسَدُوا، وَلَا تَنَاجَشُوا، وَلَا تَبَاغَضُوا، وَلَا تَدَابَرُوا، وَكُونُوا عِبَادَ اللَّهِ إِخْوَانًا',
      englishText:
          'Do not envy one another, do not outbid one another to raise prices, do not hate one another, do not turn away from one another, and be brothers, servants of Allah.',
      source: 'Sahih Muslim',
      reference: 'Muslim 2563',
    ),
    DailyHadithEntry(
      arabicText: 'مَنْ لَا يَرْحَمُ لَا يُرْحَمُ',
      englishText: 'He who does not show mercy will not be shown mercy.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 5997',
    ),
    DailyHadithEntry(
      arabicText: 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
      englishText: 'A good word is an act of charity.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 2989',
    ),
    DailyHadithEntry(
      arabicText: 'مَنْ يُرِدِ اللَّهُ بِهِ خَيْرًا يُصِبْ مِنْهُ',
      englishText: 'Whoever Allah wishes good for, He afflicts with trials.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 5645',
    ),
    DailyHadithEntry(
      arabicText:
          'مَنْ سَلَكَ طَرِيقًا يَطْلُبُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ طَرِيقًا إِلَى الْجَنَّةِ',
      englishText:
          'Whoever follows a path in pursuit of knowledge, Allah makes easy for him a path to Paradise.',
      source: 'Sahih Muslim',
      reference: 'Muslim 2699',
    ),
    DailyHadithEntry(
      arabicText:
          'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
      englishText:
          'The strong is not the one who overcomes people through his strength, but the strong is the one who controls himself at the time of anger.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 6114',
    ),
    DailyHadithEntry(
      arabicText:
          'إِذَا اسْتَيْقَظَ أَحَدُكُمْ مِنْ نَوْمِهِ فَلَا يَغْمِسْ يَدَهُ فِي الْوَضُوءِ حَتَّى يَغْسِلَهَا',
      englishText:
          'When one of you wakes from sleep, he should not put his hand into the water for ablution before washing it.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 162',
    ),
    DailyHadithEntry(
      arabicText:
          'لَا يَدْخُلُ الْجَنَّةَ مَنْ كَانَ فِي قَلْبِهِ مِثْقَالُ ذَرَّةٍ مِنْ كِبْرٍ',
      englishText:
          'He will not enter Paradise who has even an atom\'s weight of arrogance in his heart.',
      source: 'Sahih Muslim',
      reference: 'Muslim 91',
    ),
    DailyHadithEntry(
      arabicText:
          'مَنْ نَفَّسَ عَنْ مُؤْمِنٍ كُرْبَةً مِنْ كُرَبِ الدُّنْيَا نَفَّسَ اللَّهُ عَنْهُ كُرْبَةً مِنْ كُرَبِ يَوْمِ الْقِيَامَةِ',
      englishText:
          'Whoever relieves a believer\'s hardship in this world, Allah will relieve his hardship on the Day of Judgement.',
      source: 'Sahih Muslim',
      reference: 'Muslim 2699',
    ),
    DailyHadithEntry(
      arabicText: 'مَنْ غَشَّنَا فَلَيْسَ مِنَّا',
      englishText: 'Whoever deceives us is not one of us.',
      source: 'Sahih Muslim',
      reference: 'Muslim 102',
    ),
    DailyHadithEntry(
      arabicText:
          'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلَا يُؤْذِ جَارَهُ',
      englishText:
          'Whoever believes in Allah and the Last Day should not harm his neighbor.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 6019',
    ),
    DailyHadithEntry(
      arabicText:
          'أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
      englishText:
          'The deeds most beloved to Allah are those done consistently, even if small.',
      source: 'Sahih Bukhari',
      reference: 'Bukhari 6465',
    ),
  ];
}
