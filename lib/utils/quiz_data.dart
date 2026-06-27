/// A single multiple-choice quiz question.
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
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

  static const List<QuizQuestion> easy = [
    QuizQuestion(
      question: 'Who alone deserves to be worshipped?',
      options: ['The angels', 'Allah alone', 'The prophets', 'The righteous'],
      correctIndex: 1,
      explanation:
          'Allah alone is worthy of worship. This is the meaning of "La ilaha illallah" — there is no deity worthy of worship except Allah.',
    ),
    QuizQuestion(
      question: 'How many daily obligatory (fard) prayers are there?',
      options: ['Three', 'Five', 'Seven', 'Ten'],
      correctIndex: 1,
      explanation:
          'There are five obligatory prayers each day: Fajr, Dhuhr, Asr, Maghrib, and Isha.',
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
    ),
    QuizQuestion(
      question: 'What is the holy book revealed to Prophet Muhammad ﷺ?',
      options: ['The Torah', 'The Injil', 'The Zabur', 'The Quran'],
      correctIndex: 3,
      explanation:
          'The Quran is the final revelation from Allah, sent to Prophet Muhammad ﷺ.',
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
    ),
    QuizQuestion(
      question: 'How many pillars of Islam are there?',
      options: ['Three', 'Four', 'Five', 'Six'],
      correctIndex: 2,
      explanation:
          'The five pillars are: Shahadah (testimony of faith), Salah (prayer), Zakah (charity), Sawm (fasting Ramadan), and Hajj (pilgrimage).',
    ),
    QuizQuestion(
      question: 'In which month do Muslims fast from dawn to sunset?',
      options: ['Rajab', 'Shaban', 'Ramadan', 'Muharram'],
      correctIndex: 2,
      explanation:
          'Fasting the month of Ramadan is one of the five pillars of Islam.',
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
    ),
    QuizQuestion(
      question: 'How many chapters (surahs) are in the Quran?',
      options: ['100', '114', '120', '99'],
      correctIndex: 1,
      explanation: 'The Quran contains 114 surahs.',
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
    ),
    QuizQuestion(
      question: 'What is the night journey of the Prophet ﷺ called?',
      options: ['Hijrah', 'Isra and Mi\'raj', 'Laylat al-Qadr', 'Badr'],
      correctIndex: 1,
      explanation:
          'Al-Isra wal-Mi\'raj is the miraculous night journey from Makkah to Jerusalem and the ascension through the heavens, during which the five daily prayers were ordained.',
    ),
    QuizQuestion(
      question: 'What is the first surah of the Quran?',
      options: ['Al-Baqarah', 'Al-Fatihah', 'Al-Ikhlas', 'An-Nas'],
      correctIndex: 1,
      explanation:
          'Surah Al-Fatihah ("The Opening") is the first surah and is recited in every unit of prayer.',
    ),
    QuizQuestion(
      question:
          'Surah Al-Ikhlas describes which essential subject?',
      options: [
        'The stories of the prophets',
        'The oneness of Allah',
        'The rules of fasting',
        'The Day of Judgement',
      ],
      correctIndex: 1,
      explanation:
          'Surah Al-Ikhlas purely describes the oneness of Allah — that He is One, eternal, begets not nor is begotten, and has no equal.',
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
    ),
    QuizQuestion(
      question: 'How many years did the Prophet ﷺ receive revelation?',
      options: ['10 years', '13 years', '23 years', '40 years'],
      correctIndex: 2,
      explanation:
          'Revelation came over approximately 23 years — about 13 in Makkah and 10 in Madinah.',
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
    ),
    QuizQuestion(
      question:
          'What is the term for relying upon Allah while still taking the permitted means?',
      options: ['Tawakkul', 'Taqwa', 'Tazkiyah', 'Tawbah'],
      correctIndex: 0,
      explanation:
          'Tawakkul is trust and reliance upon Allah. The Prophet ﷺ taught to "tie your camel and trust in Allah" — take the means, but know the outcome rests with Allah alone.',
    ),
    QuizQuestion(
      question:
          'The phrase "You alone we worship, and You alone we ask for help" is from which surah?',
      options: ['Al-Baqarah', 'Al-Fatihah', 'Al-Kahf', 'Yasin'],
      correctIndex: 1,
      explanation:
          'This is from Surah Al-Fatihah (1:5) — a direct declaration that both worship and seeking help belong to Allah alone.',
    ),
    QuizQuestion(
      question:
          'How many names of Allah are famously mentioned in a well-known hadith about entering Paradise?',
      options: ['Seventy', 'Ninety-nine', 'One hundred', 'Forty'],
      correctIndex: 1,
      explanation:
          'The Prophet ﷺ said Allah has ninety-nine names, and whoever embraces their meanings will enter Paradise (Bukhari & Muslim). Allah\'s names are not limited to these, but these are emphasised.',
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
    ),
  ];
}
