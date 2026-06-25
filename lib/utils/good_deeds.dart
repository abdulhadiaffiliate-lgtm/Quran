/// A curated list of short, actionable good-deed reminders. One is shown
/// per day, rotating deterministically by day-of-year so everyone sees the
/// same suggestion on the same day.
class GoodDeeds {
  GoodDeeds._();

  static const List<String> deeds = [
    'Smile at someone today — the Prophet ﷺ called it charity.',
    'Call or visit a parent and ask how they are.',
    'Give something in charity, even a small amount.',
    'Forgive someone you have been holding a grudge against.',
    'Say "SubhanAllah" 33 times after a prayer today.',
    'Help someone carry, lift, or fix something without being asked.',
    'Remove something harmful from a path or walkway.',
    'Send a kind message to a friend you have not spoken to in a while.',
    'Make sincere dua for a fellow Muslim by name.',
    'Lower your gaze and guard your tongue from gossip today.',
    'Feed someone — a person or even an animal.',
    'Learn the meaning of one new verse of the Quran.',
    'Thank Allah for three specific blessings right now.',
    'Be the first to give salaam to those you meet.',
    'Hold back your anger in a moment you would normally react.',
    'Visit or check on someone who is sick.',
    'Give your seat or your place in line to someone who needs it.',
    'Read a portion of Surah Al-Kahf (especially on Friday).',
    'Seek forgiveness (Istighfar) 100 times today.',
    'Share useful knowledge with someone who can benefit.',
    'Be patient and gentle with someone difficult today.',
    'Pray two extra rak\'ahs of voluntary prayer.',
    'Spend a moment in honest gratitude before sleeping.',
    'Give a sincere compliment that lifts someone up.',
    'Restrain from wasting food or water today.',
    'Make peace between two people who are in conflict.',
    'Donate clothes or items you no longer need.',
    'Recite Ayat al-Kursi after a prayer today.',
    'Speak well of someone behind their back.',
    'Take a quiet moment to reflect on your purpose.',
    'Be generous to a neighbor today.',
  ];

  /// Returns today's deed, rotating by day-of-year.
  static String todays() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return deeds[dayOfYear % deeds.length];
  }
}
