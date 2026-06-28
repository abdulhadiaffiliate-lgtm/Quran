/// A single adhkar (remembrance) entry for the morning/evening routine.
class Adhkar {
  final String arabic;
  final String transliteration;
  final String translation;
  final int repeat;
  final String? note;
  final String? fullArabic;

  const Adhkar({
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.repeat,
    this.note,
    this.fullArabic,
  });
}

/// Authentic morning (Sabah) and evening (Masa) adhkar. A concise, widely
/// reported selection. Counts reflect the commonly transmitted repetitions.
class AdhkarData {
  AdhkarData._();

  // Full Quranic text for the long-press expansion, taken from the app's
  // own verified bundled Quran data (assets/quran/ar/2.json, 112-114.json).
  static const String _ayatulKursiFull =
      'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ';

  static const String _threeQulsFull =
      'قُلۡ هُوَ ٱللَّهُ أَحَدٌ\nٱللَّهُ ٱلصَّمَدُ\nلَمۡ يَلِدۡ وَلَمۡ يُولَدۡ\nوَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدُۢ\n\n'
      'قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ\nمِن شَرِّ مَا خَلَقَ\nوَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ\nوَمِن شَرِّ ٱلنَّفَّـٰثَٰتِ فِي ٱلۡعُقَدِ\nوَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ\n\n'
      'قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ\nمَلِكِ ٱلنَّاسِ\nإِلَٰهِ ٱلنَّاسِ\nمِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ\nٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ\nمِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ';

  static const List<Adhkar> morning = [
    Adhkar(
      arabic:
          'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ ۚ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      transliteration:
          'A\'udhu billahi minash-shaytanir-rajim. Allahu la ilaha illa huwal-Hayyul-Qayyum...',
      translation:
          'Ayat al-Kursi (2:255). Whoever recites it in the morning is protected until evening.',
      repeat: 1,
      note: 'Ayat al-Kursi',
      fullArabic: _ayatulKursiFull,
    ),
    Adhkar(
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ ... (الإخلاص، الفلق، الناس)',
      transliteration: 'Qul huwallahu ahad... (Al-Ikhlas, Al-Falaq, An-Nas)',
      translation:
          'Recite Surah Al-Ikhlas, Al-Falaq, and An-Nas three times each — a protection for the day.',
      repeat: 3,
      note: 'The three Quls',
      fullArabic: _threeQulsFull,
    ),
    Adhkar(
      arabic:
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      transliteration:
          'Asbahna wa asbahal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah',
      translation:
          'We have entered the morning and the dominion belongs to Allah. All praise is for Allah. None has the right to be worshipped but Allah alone, with no partner.',
      repeat: 1,
    ),
    Adhkar(
      arabic:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
      transliteration:
          'Allahumma bika asbahna, wa bika amsayna, wa bika nahya, wa bika namutu, wa ilaykan-nushur',
      translation:
          'O Allah, by You we enter the morning and the evening, by You we live and die, and to You is the resurrection.',
      repeat: 1,
    ),
    Adhkar(
      arabic:
          'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      translation:
          'Glory is to Allah and praise is to Him — said 100 times; sins are forgiven though they be like the foam of the sea.',
      repeat: 100,
    ),
    Adhkar(
      arabic:
          'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      transliteration:
          'Hasbiyallahu la ilaha illa huwa, \'alayhi tawakkaltu wa huwa Rabbul-\'arshil-\'azim',
      translation:
          'Allah is sufficient for me. None has the right to be worshipped but Him. Upon Him I rely, and He is the Lord of the Mighty Throne.',
      repeat: 7,
    ),
  ];

  static const List<Adhkar> evening = [
    Adhkar(
      arabic:
          'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ ۚ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      transliteration:
          'A\'udhu billahi minash-shaytanir-rajim. Allahu la ilaha illa huwal-Hayyul-Qayyum...',
      translation:
          'Ayat al-Kursi (2:255). Whoever recites it in the evening is protected until morning.',
      repeat: 1,
      note: 'Ayat al-Kursi',
      fullArabic: _ayatulKursiFull,
    ),
    Adhkar(
      arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ... (الإخلاص، الفلق، الناس)',
      transliteration: 'Qul huwallahu ahad... (Al-Ikhlas, Al-Falaq, An-Nas)',
      translation:
          'Recite Surah Al-Ikhlas, Al-Falaq, and An-Nas three times each — a protection for the night.',
      repeat: 3,
      note: 'The three Quls',
      fullArabic: _threeQulsFull,
    ),
    Adhkar(
      arabic:
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      transliteration:
          'Amsayna wa amsal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah',
      translation:
          'We have entered the evening and the dominion belongs to Allah. All praise is for Allah. None has the right to be worshipped but Allah alone, with no partner.',
      repeat: 1,
    ),
    Adhkar(
      arabic:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
      transliteration:
          'Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika namutu, wa ilaykal-masir',
      translation:
          'O Allah, by You we enter the evening and the morning, by You we live and die, and to You is the final return.',
      repeat: 1,
    ),
    Adhkar(
      arabic:
          'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      transliteration:
          'A\'udhu bikalimatillahit-tammati min sharri ma khalaq',
      translation:
          'I seek refuge in the perfect words of Allah from the evil of what He has created — said three times in the evening.',
      repeat: 3,
    ),
    Adhkar(
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      translation:
          'Glory is to Allah and praise is to Him — said 100 times.',
      repeat: 100,
    ),
  ];
}
