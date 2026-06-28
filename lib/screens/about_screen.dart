import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A data source credited in the app, shown in the Sources & Licenses list.
class _Source {
  final String name;
  final String usedFor;
  final String license;

  const _Source({
    required this.name,
    required this.usedFor,
    required this.license,
  });
}

const _sources = [
  _Source(
    name: 'AlAdhan API',
    usedFor: 'Prayer times & Qibla direction',
    license: 'Free to use',
  ),
  _Source(
    name: 'Al Quran Cloud',
    usedFor: 'Quran recitation audio',
    license: 'Free to use',
  ),
  _Source(
    name: 'quran-json (offline dataset)',
    usedFor: 'Quran Arabic text & translations (bundled offline)',
    license: 'Open source',
  ),
  _Source(
    name: 'fawazahmed0 hadith-api',
    usedFor: 'Hadith text, books & grades',
    license: 'CC BY-NC 4.0 (non-commercial)',
  ),
  _Source(
    name: 'spa5k tafsir_api',
    usedFor: 'Tafseer — Ibn Kathir (English) & Dr. Israr Ahmad (Urdu)',
    license: 'Open source',
  ),
  _Source(
    name: 'holy-quran-word-by-word dataset',
    usedFor: 'Word-by-word transliteration & meaning (bundled offline)',
    license: 'Open source',
  ),
  _Source(
    name: 'everyayah.com timing data',
    usedFor: 'Per-verse audio timing for highlighted recitation',
    license: 'Free to use',
  ),
];

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About SalahSync')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.tealPrimary,
                          AppColors.tealPrimaryLight
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.mosque_rounded,
                        color: AppColors.goldLight, size: 36),
                  ),
                  const SizedBox(height: 14),
                  const Text('SalahSync',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'SalahSync is here to make it a little easier to stay on top of '
              'your prayers and keep some good in every day — your salah '
              'times, the Quran, a hadith, a tasbih, all close at hand. May '
              'it be a help to you, and a reason for good to reach whoever '
              'made it.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 28),
            Card(
              child: ListTile(
                leading: const Icon(Icons.source_rounded, color: AppColors.gold),
                title: const Text('Sources & Licenses',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Data sources used in this app'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _SourcesScreen()),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.code_rounded, color: AppColors.gold),
                title: const Text('Open-source software licenses',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Packages used to build this app'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'SalahSync',
                  applicationVersion: '1.0.0',
                ),
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Column(
                  children: [
                    Text(
                      'Developed by Abdulhadi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Team: Rahim Nawaz, Hassan Qureshi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcesScreen extends StatelessWidget {
  const _SourcesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sources & Licenses')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'SalahSync is free and non-commercial. With thanks to the '
              'following open data sources and projects:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ..._sources.map((s) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(s.usedFor,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s.license,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
