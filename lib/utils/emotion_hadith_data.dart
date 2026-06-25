/// A small, hand-curated set of emotions paired with Sahih hadith that
/// speak to that feeling. There is no API that tags hadith by emotion,
/// so this list is maintained directly in the app.
class EmotionHadith {
  final String emotion;
  final String emoji;
  final String arabicText;
  final String englishText;
  final String source;

  const EmotionHadith({
    required this.emotion,
    required this.emoji,
    required this.arabicText,
    required this.englishText,
    required this.source,
  });
}

class EmotionHadithData {
  EmotionHadithData._();

  static const List<EmotionHadith> entries = [
    EmotionHadith(
      emotion: 'Anxious',
      emoji: '😟',
      arabicText:
          'مَنْ قَالَ حِينَ يُصْبِحُ وَحِينَ يُمْسِي: حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ العَرْشِ العَظِيمِ، سَبْعَ مَرَّاتٍ، كَفَاهُ اللَّهُ مَا أَهَمَّهُ',
      englishText:
          'Whoever says, morning and evening, "Allah is sufficient for me; there is no deity but Him; upon Him I rely, and He is the Lord of the Mighty Throne" seven times, Allah will suffice him in whatever distresses him.',
      source: 'Abu Dawud',
    ),
    EmotionHadith(
      emotion: 'Grieving',
      emoji: '😢',
      arabicText: 'إِنَّ اللَّهَ إِذَا أَحَبَّ قَوْمًا ابْتَلَاهُمْ',
      englishText:
          'When Allah loves a people, He tests them. Whoever is patient, Allah is pleased with him; whoever despairs, Allah is displeased with him.',
      source: 'Tirmidhi',
    ),
    EmotionHadith(
      emotion: 'Grateful',
      emoji: '🙏',
      arabicText: 'مَنْ لَا يَشْكُرُ القَلِيلَ لَا يَشْكُرُ الكَثِيرَ',
      englishText:
          'He who does not thank people for small favors will not thank Allah for big favors.',
      source: 'Ahmad',
    ),
    EmotionHadith(
      emotion: 'Angry',
      emoji: '😠',
      arabicText:
          'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الغَضَبِ',
      englishText:
          'The strong man is not the one who wrestles well; rather, the strong man is the one who controls himself when he is angry.',
      source: 'Sahih Bukhari',
    ),
    EmotionHadith(
      emotion: 'Hopeless',
      emoji: '😞',
      arabicText: 'لَا يَتَمَنَّى أَحَدُكُمْ المَوْتَ لِضُرٍّ أَصَابَهُ',
      englishText:
          'None of you should wish for death because of a calamity that befalls him; if he must, let him say: O Allah, keep me alive as long as life is good for me, and let me die when death is better for me.',
      source: 'Sahih Bukhari',
    ),
    EmotionHadith(
      emotion: 'Fearful',
      emoji: '😨',
      arabicText: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      englishText:
          'Allah is sufficient for us, and He is the best Disposer of affairs — said by the believers when facing fear and overwhelming odds.',
      source: 'Sahih Bukhari (commentary on the verse)',
    ),
    EmotionHadith(
      emotion: 'Lonely',
      emoji: '🥺',
      arabicText: 'المُسْلِمُ أَخُو المُسْلِمِ',
      englishText:
          'A Muslim is the brother of a Muslim; he does not wrong him, nor does he abandon him.',
      source: 'Sahih Bukhari',
    ),
    EmotionHadith(
      emotion: 'Guilty',
      emoji: '😔',
      arabicText: 'كُلُّ ابْنِ آدَمَ خَطَّاءٌ، وَخَيْرُ الخَطَّائِينَ التَّوَّابُونَ',
      englishText:
          'Every son of Adam sins, and the best of those who sin are those who repent often.',
      source: 'Tirmidhi',
    ),
    EmotionHadith(
      emotion: 'Joyful',
      emoji: '😄',
      arabicText: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
      englishText: 'Your smile in the face of your brother is an act of charity.',
      source: 'Tirmidhi',
    ),
    EmotionHadith(
      emotion: 'Overwhelmed',
      emoji: '😫',
      arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      englishText:
          'Allah does not burden a soul with more than it can bear — reflecting the principle the Prophet ﷺ taught about ease in religion.',
      source: 'Principle affirmed across hadith on ease in worship',
    ),
  ];
}
