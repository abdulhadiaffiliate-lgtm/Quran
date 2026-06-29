/// A combined ayat + hadith pairing for a given emotion. There is no API
/// that tags Quran verses or hadith by emotion, so this list is
/// hand-curated and maintained directly in the app. Ayat text is taken
/// from the app's own verified, bundled Quran data (assets/quran/ar/).
class EmotionGuidance {
  final String emotion;
  final String emoji;

  final String ayahArabic;
  final String ayahTranslation;
  final String ayahReference; // e.g. "Quran 13:28"

  final String hadithArabic;
  final String hadithTranslation;
  final String hadithReference; // e.g. "Sahih Bukhari 6114"
  final String hadithGrade; // "Sahih" or "Hasan"

  const EmotionGuidance({
    required this.emotion,
    required this.emoji,
    required this.ayahArabic,
    required this.ayahTranslation,
    required this.ayahReference,
    required this.hadithArabic,
    required this.hadithTranslation,
    required this.hadithReference,
    required this.hadithGrade,
  });
}

class EmotionGuidanceData {
  EmotionGuidanceData._();

  static const List<EmotionGuidance> entries = [
    EmotionGuidance(
      emotion: 'Anxious',
      emoji: '😟',
      ayahArabic:
          'ٱلَّذِينَ ءَامَنُواْ وَتَطۡمَئِنُّ قُلُوبُهُم بِذِكۡرِ ٱللَّهِۗ أَلَا بِذِكۡرِ ٱللَّهِ تَطۡمَئِنُّ ٱلۡقُلُوبُ',
      ayahTranslation:
          'Those who believe and whose hearts find rest in the remembrance of Allah. Verily, in the remembrance of Allah do hearts find rest.',
      ayahReference: 'Quran 13:28',
      hadithArabic:
          'مَنْ قَالَ حِينَ يُصْبِحُ وَحِينَ يُمْسِي: حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ العَرْشِ العَظِيمِ، سَبْعَ مَرَّاتٍ، كَفَاهُ اللَّهُ مَا أَهَمَّهُ',
      hadithTranslation:
          'Whoever says, morning and evening, "Allah is sufficient for me; there is no deity but Him; upon Him I rely, and He is the Lord of the Mighty Throne" seven times, Allah will suffice him in whatever distresses him.',
      hadithReference: 'Abu Dawud 5081',
      hadithGrade: 'Hasan',
    ),
    EmotionGuidance(
      emotion: 'Grieving',
      emoji: '😢',
      ayahArabic:
          'وَلَنَبۡلُوَنَّكُم بِشَيۡءٖ مِّنَ ٱلۡخَوۡفِ وَٱلۡجُوعِ وَنَقۡصٖ مِّنَ ٱلۡأَمۡوَٰلِ وَٱلۡأَنفُسِ وَٱلثَّمَرَٰتِۗ وَبَشِّرِ ٱلصَّـٰبِرِينَ',
      ayahTranslation:
          'And We will surely test you with something of fear and hunger and loss of wealth, lives, and fruits — but give glad tidings to the patient.',
      ayahReference: 'Quran 2:155',
      hadithArabic: 'إِنَّ اللَّهَ إِذَا أَحَبَّ قَوْمًا ابْتَلَاهُمْ',
      hadithTranslation:
          'When Allah loves a people, He tests them. Whoever is patient, Allah is pleased with him; whoever despairs, Allah is displeased with him.',
      hadithReference: 'Tirmidhi 2396',
      hadithGrade: 'Hasan',
    ),
    EmotionGuidance(
      emotion: 'Grateful',
      emoji: '🙏',
      ayahArabic:
          'وَإِذۡ تَأَذَّنَ رَبُّكُمۡ لَئِن شَكَرۡتُمۡ لَأَزِيدَنَّكُمۡۖ وَلَئِن كَفَرۡتُمۡ إِنَّ عَذَابِي لَشَدِيدٌ',
      ayahTranslation:
          'And when your Lord proclaimed: if you are grateful, I will surely increase you, but if you are ungrateful, indeed My punishment is severe.',
      ayahReference: 'Quran 14:7',
      hadithArabic: 'مَنْ لَا يَشْكُرُ القَلِيلَ لَا يَشْكُرُ الكَثِيرَ',
      hadithTranslation:
          'He who does not thank people for small favors will not thank Allah for big favors.',
      hadithReference: 'Ahmad 7939',
      hadithGrade: 'Hasan',
    ),
    EmotionGuidance(
      emotion: 'Angry',
      emoji: '😠',
      ayahArabic:
          'ٱلَّذِينَ يُنفِقُونَ فِي ٱلسَّرَّآءِ وَٱلضَّرَّآءِ وَٱلۡكَٰظِمِينَ ٱلۡغَيۡظَ وَٱلۡعَافِينَ عَنِ ٱلنَّاسِۗ وَٱللَّهُ يُحِبُّ ٱلۡمُحۡسِنِينَ',
      ayahTranslation:
          'Those who spend in ease and in hardship, who restrain their anger and forgive people — and Allah loves those who do good.',
      ayahReference: 'Quran 3:134',
      hadithArabic:
          'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الغَضَبِ',
      hadithTranslation:
          'The strong man is not the one who wrestles well; rather, the strong man is the one who controls himself when he is angry.',
      hadithReference: 'Sahih Bukhari 6114',
      hadithGrade: 'Sahih',
    ),
    EmotionGuidance(
      emotion: 'Hopeless',
      emoji: '😞',
      ayahArabic:
          'قُلۡ يَٰعِبَادِيَ ٱلَّذِينَ أَسۡرَفُواْ عَلَىٰٓ أَنفُسِهِمۡ لَا تَقۡنَطُواْ مِن رَّحۡمَةِ ٱللَّهِۚ إِنَّ ٱللَّهَ يَغۡفِرُ ٱلذُّنُوبَ جَمِيعًاۚ إِنَّهُۥ هُوَ ٱلۡغَفُورُ ٱلرَّحِيمُ',
      ayahTranslation:
          'Say: O My servants who have transgressed against themselves, do not despair of the mercy of Allah. Indeed, Allah forgives all sins — He is the Forgiving, the Merciful.',
      ayahReference: 'Quran 39:53',
      hadithArabic: 'لَا يَتَمَنَّى أَحَدُكُمْ المَوْتَ لِضُرٍّ أَصَابَهُ',
      hadithTranslation:
          'None of you should wish for death because of a calamity that befalls him; if he must, let him say: O Allah, keep me alive as long as life is good for me, and let me die when death is better for me.',
      hadithReference: 'Sahih Bukhari 5671',
      hadithGrade: 'Sahih',
    ),
    EmotionGuidance(
      emotion: 'Fearful',
      emoji: '😨',
      ayahArabic:
          'ٱلَّذِينَ قَالَ لَهُمُ ٱلنَّاسُ إِنَّ ٱلنَّاسَ قَدۡ جَمَعُواْ لَكُمۡ فَٱخۡشَوۡهُمۡ فَزَادَهُمۡ إِيمَـٰنًا وَقَالُواْ حَسۡبُنَا ٱللَّهُ وَنِعۡمَ ٱلۡوَكِيلُ',
      ayahTranslation:
          'Those who, when people said to them "the people have gathered against you, so fear them," it increased them in faith, and they said: Allah is sufficient for us, and He is the best Disposer of affairs.',
      ayahReference: 'Quran 3:173',
      hadithArabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      hadithTranslation:
          'Allah is sufficient for us, and He is the best Disposer of affairs.',
      hadithReference: 'Sahih Bukhari 4563 (on the occasion of this verse)',
      hadithGrade: 'Sahih',
    ),
    EmotionGuidance(
      emotion: 'Lonely',
      emoji: '🥺',
      ayahArabic:
          'إِلَّا تَنصُرُوهُ فَقَدۡ نَصَرَهُ ٱللَّهُ إِذۡ أَخۡرَجَهُ ٱلَّذِينَ كَفَرُواْ ثَانِيَ ٱثۡنَيۡنِ إِذۡ هُمَا فِي ٱلۡغَارِ إِذۡ يَقُولُ لِصَـٰحِبِهِۦ لَا تَحۡزَنۡ إِنَّ ٱللَّهَ مَعَنَا',
      ayahTranslation:
          'If you do not aid the Prophet, Allah has already aided him when those who disbelieved drove him out, the second of two, when they were in the cave and he said to his companion: do not grieve, indeed Allah is with us.',
      ayahReference: 'Quran 9:40',
      hadithArabic: 'المُسْلِمُ أَخُو المُسْلِمِ',
      hadithTranslation:
          'A Muslim is the brother of a Muslim; he does not wrong him, nor does he abandon him.',
      hadithReference: 'Sahih Bukhari 2442',
      hadithGrade: 'Sahih',
    ),
    EmotionGuidance(
      emotion: 'Guilty',
      emoji: '😔',
      ayahArabic:
          'وَمَن يَعۡمَلۡ سُوٓءًا أَوۡ يَظۡلِمۡ نَفۡسَهُۥ ثُمَّ يَسۡتَغۡفِرِ ٱللَّهَ يَجِدِ ٱللَّهَ غَفُورًا رَّحِيمًا',
      ayahTranslation:
          'And whoever does evil or wrongs himself, then seeks forgiveness from Allah, will find Allah Forgiving and Merciful.',
      ayahReference: 'Quran 4:110',
      hadithArabic:
          'كُلُّ ابْنِ آدَمَ خَطَّاءٌ، وَخَيْرُ الخَطَّائِينَ التَّوَّابُونَ',
      hadithTranslation:
          'Every son of Adam sins, and the best of those who sin are those who repent often.',
      hadithReference: 'Tirmidhi 2499',
      hadithGrade: 'Hasan',
    ),
    EmotionGuidance(
      emotion: 'Joyful',
      emoji: '😄',
      ayahArabic:
          'قُلۡ بِفَضۡلِ ٱللَّهِ وَبِرَحۡمَتِهِۦ فَبِذَٰلِكَ فَلۡيَفۡرَحُواْ هُوَ خَيۡرٞ مِّمَّا يَجۡمَعُونَ',
      ayahTranslation:
          'Say: in the bounty of Allah and His mercy — in that let them rejoice. It is better than what they accumulate.',
      ayahReference: 'Quran 10:58',
      hadithArabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
      hadithTranslation:
          'Your smile in the face of your brother is an act of charity.',
      hadithReference: 'Tirmidhi 1956',
      hadithGrade: 'Hasan',
    ),
    EmotionGuidance(
      emotion: 'Overwhelmed',
      emoji: '😫',
      ayahArabic:
          'لَا يُكَلِّفُ ٱللَّهُ نَفۡسًا إِلَّا وُسۡعَهَاۚ لَهَا مَا كَسَبَتۡ وَعَلَيۡهَا مَا ٱكۡتَسَبَتۡۗ رَبَّنَا لَا تُؤَاخِذۡنَآ إِن نَّسِينَآ أَوۡ أَخۡطَأۡنَا',
      ayahTranslation:
          'Allah does not burden a soul with more than it can bear. It will have what it has earned, and bear what it has done. Our Lord, do not hold us accountable if we forget or err.',
      ayahReference: 'Quran 2:286',
      hadithArabic:
          'يَسِّرُوا وَلَا تُعَسِّرُوا، وَسَكِّنُوا وَلَا تُنَفِّرُوا',
      hadithTranslation:
          'Make things easy and do not make them difficult; make people calm and do not drive them away.',
      hadithReference: 'Sahih Bukhari 69',
      hadithGrade: 'Sahih',
    ),
  ];
}
