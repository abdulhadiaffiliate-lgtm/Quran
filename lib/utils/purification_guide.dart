/// Step-by-step Wudu (ablution) and Ghusl (full purification) guides,
/// in English and Urdu. Content is kept as plain data so the UI can
/// switch languages with a toggle. Wudu steps carry an `icon` key used
/// to render a matching illustration.
class PurificationGuide {
  PurificationGuide._();

  static const List<Map<String, String>> wudu = [
    {
      'icon': 'hands',
      'en': 'Say "Bismillah" and wash both hands up to the wrists three times.',
      'ur': '"بسم اللہ" کہیں اور دونوں ہاتھ پہنچوں تک تین مرتبہ دھوئیں۔',
    },
    {
      'icon': 'mouth',
      'en': 'Rinse the mouth three times, swirling water around.',
      'ur': 'تین مرتبہ کلی کریں اور منہ میں پانی اچھی طرح گھمائیں۔',
    },
    {
      'icon': 'nose',
      'en': 'Sniff water into the nostrils and blow it out, three times.',
      'ur': 'تین مرتبہ ناک میں پانی چڑھائیں اور صاف کریں۔',
    },
    {
      'icon': 'face',
      'en': 'Wash the entire face three times, from forehead to chin and ear to ear.',
      'ur': 'پورا چہرہ تین مرتبہ دھوئیں، پیشانی سے ٹھوڑی تک اور ایک کان سے دوسرے کان تک۔',
    },
    {
      'icon': 'arm',
      'en': 'Wash the right arm up to and including the elbow three times, then the left.',
      'ur': 'دایاں بازو کہنی سمیت تین مرتبہ دھوئیں، پھر بایاں بازو اسی طرح۔',
    },
    {
      'icon': 'head',
      'en': 'Wipe the head (masah) once with wet hands, from front to back.',
      'ur': 'گیلے ہاتھوں سے ایک مرتبہ سر کا مسح کریں، آگے سے پیچھے کی طرف۔',
    },
    {
      'icon': 'ears',
      'en': 'Wipe the inside and outside of both ears once with wet fingers.',
      'ur': 'گیلی انگلیوں سے دونوں کانوں کے اندر اور باہر ایک مرتبہ مسح کریں۔',
    },
    {
      'icon': 'foot',
      'en': 'Wash the right foot up to and including the ankle three times, then the left.',
      'ur': 'دایاں پاؤں ٹخنے سمیت تین مرتبہ دھوئیں، پھر بایاں پاؤں اسی طرح۔',
    },
    {
      'icon': 'done',
      'en': 'Wudu is complete. It is recommended to recite the Shahadah afterwards.',
      'ur': 'وضو مکمل ہو گیا۔ اس کے بعد کلمہ شہادت پڑھنا مستحب ہے۔',
    },
  ];

  static const List<Map<String, String>> ghusl = [
    {
      'en': 'Make the intention (niyyah) to perform ghusl to remove major impurity.',
      'ur': 'بڑی ناپاکی دور کرنے کے لیے غسل کی نیت کریں۔',
    },
    {
      'en': 'Say "Bismillah" and wash both hands up to the wrists three times.',
      'ur': '"بسم اللہ" کہیں اور دونوں ہاتھ پہنچوں تک تین مرتبہ دھوئیں۔',
    },
    {
      'en': 'Wash the private parts and remove any impurity from the body.',
      'ur': 'شرمگاہ کو دھوئیں اور جسم سے ہر قسم کی ناپاکی صاف کریں۔',
    },
    {
      'en': 'Perform a complete wudu as you would for prayer.',
      'ur': 'نماز کی طرح مکمل وضو کریں۔',
    },
    {
      'en': 'Pour water over the head three times, letting it reach the roots of the hair.',
      'ur': 'سر پر تین مرتبہ پانی ڈالیں اور بالوں کی جڑوں تک پانی پہنچائیں۔',
    },
    {
      'en': 'Pour water over the entire right side of the body, then the left side.',
      'ur': 'پہلے جسم کے دائیں حصے پر پانی بہائیں، پھر بائیں حصے پر۔',
    },
    {
      'en': 'Rub the body to ensure water reaches every part — no spot should remain dry.',
      'ur': 'جسم کو ملیں تاکہ پانی ہر جگہ پہنچ جائے، کوئی جگہ خشک نہ رہے۔',
    },
    {
      'en': 'Ghusl is complete, and the body is now in a state of purity.',
      'ur': 'غسل مکمل ہو گیا، اور جسم اب پاک حالت میں ہے۔',
    },
  ];
}
