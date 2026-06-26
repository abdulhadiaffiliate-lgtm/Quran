import 'package:flutter/material.dart';
import '../utils/dua_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  IconData _iconFor(String key) {
    switch (key) {
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'toilet':
        return Icons.wc_rounded;
      case 'wudu':
        return Icons.water_drop_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      case 'prayer':
        return Icons.event_available_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'forgiveness':
        return Icons.volunteer_activism_rounded;
      case 'family':
        return Icons.family_restroom_rounded;
      case 'distress':
        return Icons.healing_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dua & Azkar')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: DuaData.categories.length,
          itemBuilder: (context, i) {
            final cat = DuaData.categories[i];
            return Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconFor(cat.icon), color: AppColors.gold),
                ),
                title: Text(cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${cat.duas.length} ${cat.duas.length == 1 ? 'dua' : 'duas'}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DuaCategoryScreen(category: cat),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DuaCategoryScreen extends StatelessWidget {
  final DuaCategory category;
  const DuaCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: category.duas.length,
          itemBuilder: (context, i) => _DuaCard(dua: category.duas[i]),
        ),
      ),
    );
  }
}

class _DuaCard extends StatefulWidget {
  final Dua dua;
  const _DuaCard({required this.dua});

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _showUrdu = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.dua;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              Expanded(
                child: Text(
                  d.title,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              // Language toggle for the translation line
              GestureDetector(
                onTap: () => setState(() => _showUrdu = !_showUrdu),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _showUrdu ? 'اردو' : 'EN',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Arabic
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              d.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color!,
                fontSize: 24,
                height: 1.9,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Transliteration
          Text(
            d.transliteration,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          // Translation (EN or Urdu)
          _showUrdu
              ? Text(
                  d.urdu,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabicStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                    fontSize: 17,
                    height: 1.7,
                  ),
                )
              : Text(
                  d.english,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
          if (d.reference != null) ...[
            const SizedBox(height: 10),
            Text(
              d.reference!,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
