/// A small set of short daily duas (supplications) with Arabic,
/// transliteration, English meaning, and a reference. One is shown per day
/// in the daily popup, rotating by day-of-year.
class DailyDuas {
  DailyDuas._();

  static const List<Map<String, String>> duas = [
    {
      'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'translit': 'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar',
      'meaning': 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      'reference': 'Quran 2:201',
    },
    {
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَىٰ وَالتُّقَىٰ وَالْعَفَافَ وَالْغِنَىٰ',
      'translit': 'Allahumma inni as’aluka al-huda wat-tuqa wal-‘afafa wal-ghina',
      'meaning': 'O Allah, I ask You for guidance, piety, chastity, and self-sufficiency.',
      'reference': 'Sahih Muslim',
    },
    {
      'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      'translit': 'Rabbi-shrah li sadri wa yassir li amri',
      'meaning': 'My Lord, expand for me my chest and ease for me my task.',
      'reference': 'Quran 20:25-26',
    },
    {
      'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'translit': 'Hasbunallahu wa ni‘mal-wakil',
      'meaning': 'Allah is sufficient for us, and He is the best Disposer of affairs.',
      'reference': 'Quran 3:173',
    },
    {
      'arabic': 'رَبِّ زِدْنِي عِلْمًا',
      'translit': 'Rabbi zidni ‘ilma',
      'meaning': 'My Lord, increase me in knowledge.',
      'reference': 'Quran 20:114',
    },
    {
      'arabic': 'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      'translit': 'Allahumma a‘inni ‘ala dhikrika wa shukrika wa husni ‘ibadatik',
      'meaning': 'O Allah, help me to remember You, to thank You, and to worship You well.',
      'reference': 'Abu Dawud',
    },
    {
      'arabic': 'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا',
      'translit': 'Rabbana la tu’akhidhna in nasina aw akhta’na',
      'meaning': 'Our Lord, do not impose blame upon us if we forget or make a mistake.',
      'reference': 'Quran 2:286',
    },
    {
      'arabic': 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ، دِقَّهُ وَجِلَّهُ',
      'translit': 'Allahumma-ghfir li dhanbi kullahu, diqqahu wa jillahu',
      'meaning': 'O Allah, forgive me all my sins, the small and the great.',
      'reference': 'Sahih Muslim',
    },
  ];

  static Map<String, String> todays() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return duas[dayOfYear % duas.length];
  }
}
