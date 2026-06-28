/// A single multiple-choice quiz question, with English and Urdu text.
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String questionUr;
  final List<String> optionsUr;
  final String explanationUr;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.questionUr,
    required this.optionsUr,
    required this.explanationUr,
  });
}

enum QuizLevel { easy, medium, hard }

/// A hand-written bank of Islamic knowledge questions, grounded in correct
/// aqeedah — that Allah alone is worthy of worship and the true source of
/// all help, while means and people are only causes Allah permits.
class QuizData {
  QuizData._();

  static List<QuizQuestion> forLevel(QuizLevel level) {
    switch (level) {
      case QuizLevel.easy:
        return easy;
      case QuizLevel.medium:
        return medium;
      case QuizLevel.hard:
        return hard;
    }
  }

  /// Returns this level's questions reordered deterministically by the
  /// given day, so everyone sees the same order on a given date and it
  /// refreshes the next day, without needing to store any extra state.
  static List<QuizQuestion> forLevelToday(QuizLevel level, DateTime day) {
    final list = List<QuizQuestion>.from(forLevel(level));
    final seed = day.year * 10000 + day.month * 100 + day.day;
    final rng = _DailySeed(seed);
    // Fisher-Yates shuffle driven by the deterministic daily seed.
    for (int i = list.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }

  static const List<QuizQuestion> easy = [
    QuizQuestion(
      question: 'Who alone deserves to be worshipped?',
      options: ['The angels', 'Allah alone', 'The prophets', 'The righteous'],
      correctIndex: 1,
      explanation:
          'Allah alone is worthy of worship. This is the meaning of "La ilaha illallah" — there is no deity worthy of worship except Allah.',
      questionUr: 'صرف کون عبادت کے لائق ہے؟',
      optionsUr: ['فرشتے', 'صرف اللہ', 'انبیاء', 'نیک لوگ'],
      explanationUr:
          'صرف اللہ ہی عبادت کے لائق ہے۔ یہی "لا الٰہ الا اللہ" کا مطلب ہے — اللہ کے سوا کوئی معبود نہیں۔',
    ),
    QuizQuestion(
      question: 'How many daily obligatory (fard) prayers are there?',
      options: ['Three', 'Five', 'Seven', 'Ten'],
      correctIndex: 1,
      explanation:
          'There are five obligatory prayers each day: Fajr, Dhuhr, Asr, Maghrib, and Isha.',
      questionUr: 'روزانہ کتنی فرض نمازیں ہیں؟',
      optionsUr: ['تین', 'پانچ', 'سات', 'دس'],
      explanationUr: 'روزانہ پانچ فرض نمازیں ہیں: فجر، ظہر، عصر، مغرب اور عشاء۔',
    ),
    QuizQuestion(
      question: 'Who is the final Messenger of Allah?',
      options: [
        'Prophet Musa (AS)',
        'Prophet Isa (AS)',
        'Prophet Muhammad ﷺ',
        'Prophet Ibrahim (AS)',
      ],
      correctIndex: 2,
      explanation:
          'Prophet Muhammad ﷺ is the final Messenger; there is no prophet after him.',
      questionUr: 'اللہ کے آخری رسول کون ہیں؟',
      optionsUr: [
        'حضرت موسیٰ علیہ السلام',
        'حضرت عیسیٰ علیہ السلام',
        'حضرت محمد ﷺ',
        'حضرت ابراہیم علیہ السلام',
      ],
      explanationUr: 'حضرت محمد ﷺ آخری رسول ہیں؛ آپ کے بعد کوئی نبی نہیں آئے گا۔',
    ),
    QuizQuestion(
      question: 'What is the holy book revealed to Prophet Muhammad ﷺ?',
      options: ['The Torah', 'The Injil', 'The Zabur', 'The Quran'],
      correctIndex: 3,
      explanation:
          'The Quran is the final revelation from Allah, sent to Prophet Muhammad ﷺ.',
      questionUr: 'حضرت محمد ﷺ پر کونسی کتاب نازل ہوئی؟',
      optionsUr: ['تورات', 'انجیل', 'زبور', 'قرآن'],
      explanationUr: 'قرآن اللہ کی آخری کتاب ہے، جو حضرت محمد ﷺ پر نازل ہوئی۔',
    ),
    QuizQuestion(
      question: 'When we need help, who is the true source of all help?',
      options: [
        'Our own strength',
        'Allah alone',
        'Saints and the dead',
        'Luck',
      ],
      correctIndex: 1,
      explanation:
          'All help ultimately comes from Allah. We may take means, but it is Allah who provides the outcome. "You alone we worship, and You alone we ask for help" (Quran 1:5).',
      questionUr: 'جب ہمیں مدد کی ضرورت ہو تو حقیقی مدد کا سرچشمہ کون ہے؟',
      optionsUr: ['اپنی طاقت', 'صرف اللہ', 'اولیاء اور مردے', 'قسمت'],
      explanationUr:
          'ہر مدد بالآخر اللہ ہی سے آتی ہے۔ ہم ذرائع اختیار کر سکتے ہیں، مگر نتیجہ اللہ ہی دیتا ہے۔ "ہم تیری ہی عبادت کرتے ہیں اور تجھ ہی سے مدد چاہتے ہیں" (سورۃ الفاتحہ 1:5)۔',
    ),
    QuizQuestion(
      question: 'How many pillars of Islam are there?',
      options: ['Three', 'Four', 'Five', 'Six'],
      correctIndex: 2,
      explanation:
          'The five pillars are: Shahadah (testimony of faith), Salah (prayer), Zakah (charity), Sawm (fasting Ramadan), and Hajj (pilgrimage).',
      questionUr: 'اسلام کے کتنے ارکان ہیں؟',
      optionsUr: ['تین', 'چار', 'پانچ', 'چھ'],
      explanationUr: 'پانچ ارکان یہ ہیں: شہادت، نماز، زکوۃ، روزہ اور حج۔',
    ),
    QuizQuestion(
      question: 'In which month do Muslims fast from dawn to sunset?',
      options: ['Rajab', 'Shaban', 'Ramadan', 'Muharram'],
      correctIndex: 2,
      explanation:
          'Fasting the month of Ramadan is one of the five pillars of Islam.',
      questionUr: 'مسلمان کس مہینے میں صبح سے شام تک روزہ رکھتے ہیں؟',
      optionsUr: ['رجب', 'شعبان', 'رمضان', 'محرم'],
      explanationUr: 'رمضان کے روزے اسلام کے پانچ ارکان میں سے ایک ہیں۔',
    ),
    QuizQuestion(
      question: 'What is the first pillar of Islam?',
      options: [
        'Prayer',
        'The testimony of faith (Shahadah)',
        'Charity',
        'Pilgrimage',
      ],
      correctIndex: 1,
      explanation:
          'The Shahadah — bearing witness that there is no god but Allah and Muhammad ﷺ is His Messenger — is the first pillar and the foundation of Islam.',
      questionUr: 'اسلام کا پہلا رکن کیا ہے؟',
      optionsUr: ['نماز', 'شہادت', 'زکوۃ', 'حج'],
      explanationUr:
          'شہادت — یہ گواہی دینا کہ اللہ کے سوا کوئی معبود نہیں اور محمد ﷺ اللہ کے رسول ہیں — اسلام کا پہلا اور بنیادی رکن ہے۔',
    ),
  ];

  static const List<QuizQuestion> medium = [
    QuizQuestion(
      question: 'What does "Tawheed" mean?',
      options: [
        'Praying five times',
        'The oneness of Allah',
        'Giving charity',
        'Fasting',
      ],
      correctIndex: 1,
      explanation:
          'Tawheed is the belief in the absolute oneness of Allah — in His lordship, His worship, and His names and attributes. It is the core of Islam.',
      questionUr: '"توحید" کا مطلب کیا ہے؟',
      optionsUr: ['پانچ وقت نماز پڑھنا', 'اللہ کی وحدانیت', 'صدقہ دینا', 'روزہ رکھنا'],
      explanationUr:
          'توحید اللہ کی مطلق وحدانیت پر یقین ہے — اس کی ربوبیت، عبادت، اور اسمائے و صفات میں۔ یہ اسلام کی بنیاد ہے۔',
    ),
    QuizQuestion(
      question:
          'Calling upon the dead or saints to fulfill needs instead of Allah is an example of what?',
      options: [
        'A recommended act',
        'Shirk (associating partners with Allah)',
        'A minor mistake',
        'A pillar of faith',
      ],
      correctIndex: 1,
      explanation:
          'Directing worship or supplication to anyone besides Allah is shirk, the gravest sin. Allah alone hears and answers; we call upon Him directly.',
      questionUr: 'اللہ کے بجائے مردوں یا اولیاء کو پکارنا کس کی مثال ہے؟',
      optionsUr: ['ایک مستحسن عمل', 'شرک', 'ایک معمولی غلطی', 'ایمان کا رکن'],
      explanationUr:
          'اللہ کے سوا کسی اور کی طرف عبادت یا دعا موڑنا شرک ہے، جو سب سے بڑا گناہ ہے۔ صرف اللہ ہی سنتا اور جواب دیتا ہے؛ ہم اسی کو براہِ راست پکارتے ہیں۔',
    ),
    QuizQuestion(
      question: 'How many chapters (surahs) are in the Quran?',
      options: ['100', '114', '120', '99'],
      correctIndex: 1,
      explanation: 'The Quran contains 114 surahs.',
      questionUr: 'قرآن میں کتنی سورتیں ہیں؟',
      optionsUr: ['100', '114', '120', '99'],
      explanationUr: 'قرآن میں 114 سورتیں ہیں۔',
    ),
    QuizQuestion(
      question: 'Which prayer has the most rak\'ahs of fard (obligatory)?',
      options: [
        'Fajr (2)',
        'Maghrib (3)',
        'Dhuhr, Asr & Isha (4 each)',
        'They are all equal',
      ],
      correctIndex: 2,
      explanation:
          'Dhuhr, Asr, and Isha each have four fard rak\'ahs. Fajr has two and Maghrib has three.',
      questionUr: 'کس نماز میں سب سے زیادہ فرض رکعات ہیں؟',
      optionsUr: [
        'فجر (2)',
        'مغرب (3)',
        'ظہر، عصر اور عشاء (ہر ایک میں 4)',
        'سب برابر ہیں',
      ],
      explanationUr:
          'ظہر، عصر اور عشاء میں ہر ایک کی چار فرض رکعات ہیں۔ فجر میں دو اور مغرب میں تین ہیں۔',
    ),
    QuizQuestion(
      question: 'What is the night journey of the Prophet ﷺ called?',
      options: ['Hijrah', 'Isra and Mi\'raj', 'Laylat al-Qadr', 'Badr'],
      correctIndex: 1,
      explanation:
          'Al-Isra wal-Mi\'raj is the miraculous night journey from Makkah to Jerusalem and the ascension through the heavens, during which the five daily prayers were ordained.',
      questionUr: 'نبی ﷺ کے رات کے سفر کو کیا کہا جاتا ہے؟',
      optionsUr: ['ہجرت', 'اسراء و معراج', 'لیلۃ القدر', 'بدر'],
      explanationUr:
          'اسراء و معراج وہ معجزاتی رات کا سفر ہے جو مکہ سے یروشلم اور پھر آسمانوں کی طرف ہوا، جس میں پانچ وقت کی نماز فرض ہوئی۔',
    ),
    QuizQuestion(
      question: 'What is the first surah of the Quran?',
      options: ['Al-Baqarah', 'Al-Fatihah', 'Al-Ikhlas', 'An-Nas'],
      correctIndex: 1,
      explanation:
          'Surah Al-Fatihah ("The Opening") is the first surah and is recited in every unit of prayer.',
      questionUr: 'قرآن کی پہلی سورت کونسی ہے؟',
      optionsUr: ['البقرہ', 'الفاتحہ', 'الإخلاص', 'الناس'],
      explanationUr: 'سورۃ الفاتحہ پہلی سورت ہے اور ہر رکعت میں تلاوت کی جاتی ہے۔',
    ),
    QuizQuestion(
      question: 'Surah Al-Ikhlas describes which essential subject?',
      options: [
        'The stories of the prophets',
        'The oneness of Allah',
        'The rules of fasting',
        'The Day of Judgement',
      ],
      correctIndex: 1,
      explanation:
          'Surah Al-Ikhlas purely describes the oneness of Allah — that He is One, eternal, begets not nor is begotten, and has no equal.',
      questionUr: 'سورۃ الإخلاص کس اہم موضوع کو بیان کرتی ہے؟',
      optionsUr: ['انبیاء کے قصے', 'اللہ کی وحدانیت', 'روزے کے احکام', 'قیامت کا دن'],
      explanationUr:
          'سورۃ الإخلاص خالصتاً اللہ کی وحدانیت بیان کرتی ہے — کہ وہ ایک ہے، ہمیشہ سے ہے، نہ اس نے کسی کو جنا نہ وہ کسی سے پیدا ہوا، اور اس کا کوئی ثانی نہیں۔',
    ),
    QuizQuestion(
      question: 'Who was the first person to accept Islam among men?',
      options: [
        'Umar ibn al-Khattab (RA)',
        'Abu Bakr as-Siddiq (RA)',
        'Ali ibn Abi Talib (RA)',
        'Uthman ibn Affan (RA)',
      ],
      correctIndex: 1,
      explanation:
          'Abu Bakr as-Siddiq (RA) was the first adult free man to accept Islam and was the closest companion of the Prophet ﷺ.',
      questionUr: 'مردوں میں سب سے پہلے اسلام قبول کرنے والے کون تھے؟',
      optionsUr: [
        'حضرت عمر بن خطاب رضی اللہ عنہ',
        'حضرت ابوبکر صدیق رضی اللہ عنہ',
        'حضرت علی بن ابی طالب رضی اللہ عنہ',
        'حضرت عثمان بن عفان رضی اللہ عنہ',
      ],
      explanationUr:
          'حضرت ابوبکر صدیق رضی اللہ عنہ مردوں میں سب سے پہلے بالغ آزاد شخص تھے جنہوں نے اسلام قبول کیا اور نبی ﷺ کے قریب ترین ساتھی تھے۔',
    ),
  ];

  static const List<QuizQuestion> hard = [
    QuizQuestion(
      question:
          'Which category of Tawheed concerns directing all worship to Allah alone?',
      options: [
        'Tawheed ar-Rububiyyah (Lordship)',
        'Tawheed al-Uluhiyyah (Worship)',
        'Tawheed al-Asma was-Sifat (Names & Attributes)',
        'None of these',
      ],
      correctIndex: 1,
      explanation:
          'Tawheed al-Uluhiyyah means singling out Allah alone for all acts of worship — prayer, supplication, sacrifice, reliance. This is what the messengers primarily called to.',
      questionUr:
          'توحید کی کونسی قسم تمام عبادت کو صرف اللہ کی طرف موڑنے سے متعلق ہے؟',
      optionsUr: [
        'توحید الربوبیت',
        'توحید الالوہیت',
        'توحید الاسماء والصفات',
        'ان میں سے کوئی نہیں',
      ],
      explanationUr:
          'توحید الالوہیت کا مطلب ہے تمام عبادات — نماز، دعا، قربانی، توکل — صرف اللہ کے لیے مخصوص کرنا۔ یہی وہ چیز ہے جس کی طرف انبیاء نے بنیادی طور پر دعوت دی۔',
    ),
    QuizQuestion(
      question:
          'Even the disbelievers of Makkah affirmed which type of Tawheed, yet it did not make them Muslim?',
      options: [
        'Tawheed al-Uluhiyyah',
        'Tawheed ar-Rububiyyah',
        'Tawheed al-Asma was-Sifat',
        'They affirmed none',
      ],
      correctIndex: 1,
      explanation:
          'They affirmed Tawheed ar-Rububiyyah — that Allah is the Creator and Sustainer (Quran 43:87). But affirming He is Creator is not enough; one must also worship Him alone (Uluhiyyah).',
      questionUr:
          'مکہ کے کافر بھی توحید کی کونسی قسم مانتے تھے، مگر اس سے وہ مسلمان نہ ہوئے؟',
      optionsUr: [
        'توحید الالوہیت',
        'توحید الربوبیت',
        'توحید الاسماء والصفات',
        'وہ کوئی نہیں مانتے تھے',
      ],
      explanationUr:
          'وہ توحید الربوبیت مانتے تھے — کہ اللہ ہی خالق اور رازق ہے (سورۃ 43:87)۔ مگر صرف خالق ماننا کافی نہیں؛ اسی کی عبادت بھی ضروری ہے (الالوہیت)۔',
    ),
    QuizQuestion(
      question: 'How many years did the Prophet ﷺ receive revelation?',
      options: ['10 years', '13 years', '23 years', '40 years'],
      correctIndex: 2,
      explanation:
          'Revelation came over approximately 23 years — about 13 in Makkah and 10 in Madinah.',
      questionUr: 'نبی ﷺ پر وحی کتنے سالوں میں نازل ہوئی؟',
      optionsUr: ['10 سال', '13 سال', '23 سال', '40 سال'],
      explanationUr:
          'وحی تقریباً 23 سالوں میں نازل ہوئی — تقریباً 13 سال مکہ میں اور 10 سال مدینہ میں۔',
    ),
    QuizQuestion(
      question:
          'Which companion compiled the Quran into a single written volume during the time of Abu Bakr (RA)?',
      options: [
        'Zayd ibn Thabit (RA)',
        'Abdullah ibn Mas\'ud (RA)',
        'Mu\'adh ibn Jabal (RA)',
        'Bilal (RA)',
      ],
      correctIndex: 0,
      explanation:
          'Zayd ibn Thabit (RA) was entrusted with compiling the Quran into one volume, a task continued and standardised later under Uthman (RA).',
      questionUr:
          'حضرت ابوبکر رضی اللہ عنہ کے دور میں قرآن کو ایک کتاب کی شکل میں کس صحابی نے جمع کیا؟',
      optionsUr: [
        'حضرت زید بن ثابت رضی اللہ عنہ',
        'حضرت عبداللہ بن مسعود رضی اللہ عنہ',
        'حضرت معاذ بن جبل رضی اللہ عنہ',
        'حضرت بلال رضی اللہ عنہ',
      ],
      explanationUr:
          'حضرت زید بن ثابت رضی اللہ عنہ کو قرآن کو ایک جلد میں جمع کرنے کی ذمہ داری دی گئی، جسے بعد میں حضرت عثمان رضی اللہ عنہ کے دور میں مزید معیاری بنایا گیا۔',
    ),
    QuizQuestion(
      question:
          'What is the term for relying upon Allah while still taking the permitted means?',
      options: ['Tawakkul', 'Taqwa', 'Tazkiyah', 'Tawbah'],
      correctIndex: 0,
      explanation:
          'Tawakkul is trust and reliance upon Allah. The Prophet ﷺ taught to "tie your camel and trust in Allah" — take the means, but know the outcome rests with Allah alone.',
      questionUr: 'جائز ذرائع اختیار کرتے ہوئے اللہ پر بھروسہ کرنے کی اصطلاح کیا ہے؟',
      optionsUr: ['توکل', 'تقویٰ', 'تزکیہ', 'توبہ'],
      explanationUr:
          'توکل اللہ پر اعتماد اور بھروسہ ہے۔ نبی ﷺ نے سکھایا "اپنا اونٹ باندھو اور اللہ پر بھروسہ کرو" — ذرائع اختیار کرو، مگر جانو کہ نتیجہ صرف اللہ کے ہاتھ میں ہے۔',
    ),
    QuizQuestion(
      question:
          'The phrase "You alone we worship, and You alone we ask for help" is from which surah?',
      options: ['Al-Baqarah', 'Al-Fatihah', 'Al-Kahf', 'Yasin'],
      correctIndex: 1,
      explanation:
          'This is from Surah Al-Fatihah (1:5) — a direct declaration that both worship and seeking help belong to Allah alone.',
      questionUr:
          '"ہم تیری ہی عبادت کرتے ہیں اور تجھ ہی سے مدد چاہتے ہیں" یہ آیت کس سورت سے ہے؟',
      optionsUr: ['البقرہ', 'الفاتحہ', 'الکہف', 'یٰسین'],
      explanationUr:
          'یہ سورۃ الفاتحہ (1:5) سے ہے — ایک واضح اعلان کہ عبادت اور مدد طلب کرنا دونوں صرف اللہ کے لیے ہیں۔',
    ),
    QuizQuestion(
      question:
          'How many names of Allah are famously mentioned in a well-known hadith about entering Paradise?',
      options: ['Seventy', 'Ninety-nine', 'One hundred', 'Forty'],
      correctIndex: 1,
      explanation:
          'The Prophet ﷺ said Allah has ninety-nine names, and whoever embraces their meanings will enter Paradise (Bukhari & Muslim). Allah\'s names are not limited to these, but these are emphasised.',
      questionUr:
          'جنت میں داخلے سے متعلق ایک مشہور حدیث میں اللہ کے کتنے نام مذکور ہیں؟',
      optionsUr: ['ستر', 'ننانوے', 'سو', 'چالیس'],
      explanationUr:
          'نبی ﷺ نے فرمایا کہ اللہ کے ننانوے نام ہیں، اور جو ان کے معانی کو اپنائے گا وہ جنت میں داخل ہوگا (بخاری و مسلم)۔ اللہ کے نام ان تک محدود نہیں، مگر یہ خاص طور پر بیان کیے گئے ہیں۔',
    ),
    QuizQuestion(
      question:
          'Seeking cure from an illness by medicine, while believing the healing itself comes from Allah, is:',
      options: [
        'Shirk, because one used medicine',
        'Permitted, because means do not contradict reliance on Allah',
        'Forbidden in all cases',
        'Only allowed for minor illness',
      ],
      correctIndex: 1,
      explanation:
          'Taking medicine is a permitted means. The Prophet ﷺ both sought treatment and taught that Allah is the true Healer. Using means while believing the outcome is from Allah is correct tawakkul, not shirk.',
      questionUr:
          'دوا سے علاج کرنا، جبکہ یہ یقین رکھنا کہ شفا اصل میں اللہ کی طرف سے ہے، یہ کیسا ہے؟',
      optionsUr: [
        'شرک، کیونکہ دوا استعمال کی',
        'جائز، کیونکہ ذرائع اللہ پر توکل کے خلاف نہیں',
        'مطلق ممنوع',
        'صرف معمولی بیماری کے لیے جائز',
      ],
      explanationUr:
          'دوا لینا ایک جائز ذریعہ ہے۔ نبی ﷺ نے خود علاج کرایا اور سکھایا کہ اصل شفا دینے والا اللہ ہے۔ ذرائع اختیار کرتے ہوئے یہ یقین رکھنا کہ نتیجہ اللہ سے ہے، یہی درست توکل ہے، شرک نہیں۔',
    ),
  ];
}

/// A tiny deterministic pseudo-random generator (linear congruential),
/// used only to reorder questions identically for a given calendar day.
class _DailySeed {
  int _state;
  _DailySeed(int seed) : _state = seed;

  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7FFFFFFF;
    return _state % max;
  }
}
