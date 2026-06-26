/// A single supplication entry with full multilingual content.
class Dua {
  final String title;
  final String arabic;
  final String transliteration;
  final String english;
  final String urdu;
  final String? reference;

  const Dua({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.english,
    required this.urdu,
    this.reference,
  });
}

/// A named category grouping related duas.
class DuaCategory {
  final String name;
  final String icon; // key mapped to an icon in the UI
  final List<Dua> duas;

  const DuaCategory({
    required this.name,
    required this.icon,
    required this.duas,
  });
}

/// A hand-curated starter set of well-known duas and azkar. Designed to be
/// expanded over time. Content focuses on widely-authenticated supplications.
class DuaData {
  DuaData._();

  static const List<DuaCategory> categories = [
    DuaCategory(
      name: 'Sleeping',
      icon: 'sleep',
      duas: [
        Dua(
          title: 'Before sleeping',
          arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
          transliteration: 'Bismika Allahumma amutu wa ahya',
          english: 'In Your name, O Allah, I die and I live.',
          urdu: 'اے اللہ! تیرے نام کے ساتھ میں مرتا اور جیتا ہوں۔',
          reference: 'Sahih al-Bukhari',
        ),
        Dua(
          title: 'On waking up',
          arabic:
              'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
          transliteration:
              'Alhamdu lillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur',
          english:
              'All praise is for Allah who gave us life after death, and to Him is the return.',
          urdu:
              'تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں موت کے بعد زندگی دی، اور اسی کی طرف لوٹنا ہے۔',
          reference: 'Sahih al-Bukhari',
        ),
      ],
    ),
    DuaCategory(
      name: 'Toilet',
      icon: 'toilet',
      duas: [
        Dua(
          title: 'Before entering',
          arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
          transliteration: 'Allahumma inni a\'udhu bika minal-khubuthi wal-khaba\'ith',
          english:
              'O Allah, I seek refuge in You from male and female evil (devils).',
          urdu:
              'اے اللہ! میں ناپاک جنوں اور ناپاک جنیوں سے تیری پناہ مانگتا ہوں۔',
          reference: 'Sahih al-Bukhari & Muslim',
        ),
        Dua(
          title: 'After leaving',
          arabic: 'غُفْرَانَكَ',
          transliteration: 'Ghufranak',
          english: 'I seek Your forgiveness.',
          urdu: 'اے اللہ! میں تیری بخشش چاہتا ہوں۔',
          reference: 'Abu Dawud, Tirmidhi',
        ),
      ],
    ),
    DuaCategory(
      name: 'Ablution (Wudu)',
      icon: 'wudu',
      duas: [
        Dua(
          title: 'After completing wudu',
          arabic:
              'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
          transliteration:
              'Ash-hadu an la ilaha illallahu wahdahu la sharika lah, wa ash-hadu anna Muhammadan \'abduhu wa rasuluh',
          english:
              'I bear witness that none is worthy of worship but Allah alone, with no partner, and that Muhammad is His servant and Messenger.',
          urdu:
              'میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے اس کا کوئی شریک نہیں، اور محمد ﷺ اس کے بندے اور رسول ہیں۔',
          reference: 'Sahih Muslim',
        ),
      ],
    ),
    DuaCategory(
      name: 'Mosque (Masjid)',
      icon: 'mosque',
      duas: [
        Dua(
          title: 'Entering the mosque',
          arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
          transliteration: 'Allahumma-ftah li abwaba rahmatik',
          english: 'O Allah, open for me the doors of Your mercy.',
          urdu: 'اے اللہ! میرے لیے اپنی رحمت کے دروازے کھول دے۔',
          reference: 'Sahih Muslim',
        ),
        Dua(
          title: 'Leaving the mosque',
          arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
          transliteration: 'Allahumma inni as\'aluka min fadlik',
          english: 'O Allah, I ask You from Your bounty.',
          urdu: 'اے اللہ! میں تجھ سے تیرا فضل مانگتا ہوں۔',
          reference: 'Sahih Muslim',
        ),
      ],
    ),
    DuaCategory(
      name: 'After Prayer',
      icon: 'prayer',
      duas: [
        Dua(
          title: 'Seeking forgiveness after salah',
          arabic: 'أَسْتَغْفِرُ اللَّهَ (ثلاثًا) اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ',
          transliteration:
              'Astaghfirullah (3x). Allahumma antas-salamu wa minkas-salam',
          english:
              'I seek Allah\'s forgiveness (3 times). O Allah, You are Peace and from You comes peace.',
          urdu:
              'میں اللہ سے بخشش مانگتا ہوں (تین بار)۔ اے اللہ! تو ہی سلامتی والا ہے اور تجھ ہی سے سلامتی ہے۔',
          reference: 'Sahih Muslim',
        ),
      ],
    ),
    DuaCategory(
      name: 'Home',
      icon: 'home',
      duas: [
        Dua(
          title: 'Entering the home',
          arabic:
              'بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا وَعَلَى رَبِّنَا تَوَكَّلْنَا',
          transliteration:
              'Bismillahi walajna, wa bismillahi kharajna, wa \'ala Rabbina tawakkalna',
          english:
              'In the name of Allah we enter, in the name of Allah we leave, and upon our Lord we rely.',
          urdu:
              'اللہ کے نام سے ہم داخل ہوئے، اللہ کے نام سے ہم نکلے، اور اپنے رب پر ہم نے بھروسہ کیا۔',
          reference: 'Abu Dawud',
        ),
      ],
    ),
    DuaCategory(
      name: 'Food',
      icon: 'food',
      duas: [
        Dua(
          title: 'Before eating',
          arabic: 'بِسْمِ اللَّهِ',
          transliteration: 'Bismillah',
          english: 'In the name of Allah.',
          urdu: 'اللہ کے نام سے۔',
          reference: 'Sahih al-Bukhari & Muslim',
        ),
        Dua(
          title: 'After eating',
          arabic:
              'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
          transliteration:
              'Alhamdu lillahil-ladhi at\'amani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah',
          english:
              'All praise is for Allah who fed me this and provided it for me without any might or power on my part.',
          urdu:
              'تمام تعریفیں اللہ کے لیے ہیں جس نے مجھے یہ کھلایا اور میری طاقت و قوت کے بغیر مجھے عطا کیا۔',
          reference: 'Abu Dawud, Tirmidhi',
        ),
      ],
    ),
    DuaCategory(
      name: 'Forgiveness',
      icon: 'forgiveness',
      duas: [
        Dua(
          title: 'Master of seeking forgiveness (Sayyidul Istighfar)',
          arabic:
              'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ',
          transliteration:
              'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana \'abduk',
          english:
              'O Allah, You are my Lord, there is none worthy of worship but You. You created me and I am Your servant.',
          urdu:
              'اے اللہ! تو میرا رب ہے، تیرے سوا کوئی معبود نہیں، تو نے مجھے پیدا کیا اور میں تیرا بندہ ہوں۔',
          reference: 'Sahih al-Bukhari',
        ),
        Dua(
          title: 'Simple istighfar',
          arabic: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ',
          transliteration: 'Astaghfirullahal-\'Azim alladhi la ilaha illa huwa',
          english:
              'I seek the forgiveness of Allah the Mighty, whom there is none worthy of worship except Him.',
          urdu:
              'میں اللہ عظیم سے بخشش مانگتا ہوں جس کے سوا کوئی معبود نہیں۔',
          reference: 'Abu Dawud, Tirmidhi',
        ),
      ],
    ),
    DuaCategory(
      name: 'Family & Parents',
      icon: 'family',
      duas: [
        Dua(
          title: 'For one\'s parents',
          arabic: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
          transliteration: 'Rabbi-rhamhuma kama rabbayani saghira',
          english:
              'My Lord, have mercy upon them as they raised me when I was small.',
          urdu:
              'اے میرے رب! ان دونوں پر رحم فرما جیسے انہوں نے بچپن میں مجھے پالا۔',
          reference: 'Quran 17:24',
        ),
        Dua(
          title: 'For righteous family',
          arabic:
              'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
          transliteration:
              'Rabbana hab lana min azwajina wa dhurriyyatina qurrata a\'yunin waj\'alna lil-muttaqina imama',
          english:
              'Our Lord, grant us from our spouses and offspring comfort to our eyes, and make us a leader for the righteous.',
          urdu:
              'اے ہمارے رب! ہمیں ہماری بیویوں اور اولاد سے آنکھوں کی ٹھنڈک عطا فرما اور ہمیں پرہیزگاروں کا امام بنا۔',
          reference: 'Quran 25:74',
        ),
      ],
    ),
    DuaCategory(
      name: 'Distress & Anxiety',
      icon: 'distress',
      duas: [
        Dua(
          title: 'Relief from worry and grief',
          arabic:
              'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ',
          transliteration:
              'Allahumma inni a\'udhu bika minal-hammi wal-hazani wal-\'ajzi wal-kasal',
          english:
              'O Allah, I seek refuge in You from worry and grief, from helplessness and laziness.',
          urdu:
              'اے اللہ! میں غم و فکر، عاجزی اور سستی سے تیری پناہ مانگتا ہوں۔',
          reference: 'Sahih al-Bukhari',
        ),
      ],
    ),
  ];
}
