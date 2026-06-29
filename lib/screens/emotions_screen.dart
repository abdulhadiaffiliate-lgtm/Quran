import 'package:flutter/material.dart';
import '../utils/emotion_guidance_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Lets the user pick how they're feeling and shows a paired Quran verse
/// and hadith that speak to that feeling — moved here from the Hadith
/// tab since this is about emotional guidance broadly, not just hadith.
class EmotionsScreen extends StatefulWidget {
  const EmotionsScreen({super.key});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen> {
  EmotionGuidance? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How are you feeling?')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Tap an emotion for a verse and a hadith that speak to it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildEmotionGrid(),
            if (_selected != null) ...[
              const SizedBox(height: 20),
              _buildGuidanceCard(_selected!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: EmotionGuidanceData.entries.map((e) {
        final selected = _selected?.emotion == e.emotion;
        return GestureDetector(
          onTap: () => setState(
              () => _selected = selected ? null : e),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.gold.withValues(alpha: 0.18)
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.gold : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  e.emotion,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.gold : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuidanceCard(EmotionGuidance e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(e.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'For when you feel ${e.emotion.toLowerCase()}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Ayah card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.menu_book_rounded,
                      size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text('From the Quran',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      )),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                e.ayahArabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.9,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                e.ayahTranslation,
                style: const TextStyle(color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                e.ayahReference,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Hadith card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote_rounded,
                      size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  const Text('From the Hadith',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      )),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (e.hadithGrade == 'Sahih'
                              ? AppColors.success
                              : AppColors.gold)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      e.hadithGrade,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: e.hadithGrade == 'Sahih'
                            ? AppColors.success
                            : AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                e.hadithArabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                  fontSize: 18,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                e.hadithTranslation,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                e.hadithReference,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
