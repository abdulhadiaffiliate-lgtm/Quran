import 'package:flutter/material.dart';
import '../utils/purification_guide.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class PurificationScreen extends StatefulWidget {
  const PurificationScreen({super.key});

  @override
  State<PurificationScreen> createState() => _PurificationScreenState();
}

class _PurificationScreenState extends State<PurificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _urdu = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wudu & Ghusl'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () => setState(() => _urdu = !_urdu),
              child: Text(
                _urdu ? 'اردو' : 'EN',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          tabs: const [
            Tab(text: 'Wudu'),
            Tab(text: 'Ghusl'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tab,
          children: [
            _stepsList(PurificationGuide.wudu),
            _stepsList(PurificationGuide.ghusl),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String? key) {
    switch (key) {
      case 'hands':
        return Icons.back_hand_rounded;
      case 'mouth':
        return Icons.water_drop_rounded;
      case 'nose':
        return Icons.air_rounded;
      case 'face':
        return Icons.face_rounded;
      case 'arm':
        return Icons.front_hand_rounded;
      case 'head':
        return Icons.psychology_rounded;
      case 'ears':
        return Icons.hearing_rounded;
      case 'foot':
        return Icons.directions_walk_rounded;
      case 'done':
        return Icons.check_circle_rounded;
      default:
        return Icons.water_drop_rounded;
    }
  }

  Widget _stepsList(List<Map<String, String>> steps) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, i) {
        final text = _urdu ? steps[i]['ur']! : steps[i]['en']!;
        final hasIcon = steps[i].containsKey('icon');
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              if (hasIcon)
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.tealPrimary,
                        AppColors.tealPrimaryLight
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconFor(steps[i]['icon']),
                    color: AppColors.goldLight,
                    size: 32,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection:
                    _urdu ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      textAlign: _urdu ? TextAlign.right : TextAlign.left,
                      textDirection:
                          _urdu ? TextDirection.rtl : TextDirection.ltr,
                      style: _urdu
                          ? AppTheme.arabicStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!,
                              fontSize: 18,
                              height: 1.8,
                            )
                          : Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
