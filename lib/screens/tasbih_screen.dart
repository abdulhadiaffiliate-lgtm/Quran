import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  static const _dhikrList = [
    ('SubhanAllah', 'سُبْحَانَ ٱللَّٰه', 33),
    ('Alhamdulillah', 'ٱلْحَمْدُ لِلَّٰه', 33),
    ('Allahu Akbar', 'ٱللَّٰهُ أَكْبَر', 34),
    ('La ilaha illallah', 'لَا إِلَٰهَ إِلَّا ٱللَّٰه', 100),
  ];

  int _dhikrIndex = 0;
  int _count = 0;
  int _lifetimeTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadLifetime();
  }

  Future<void> _loadLifetime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _lifetimeTotal = prefs.getInt('tasbih_lifetime') ?? 0);
  }

  Future<void> _saveLifetime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_lifetime', _lifetimeTotal);
  }

  int get _target => _dhikrList[_dhikrIndex].$3;

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      _lifetimeTotal++;
      if (_count >= _target) {
        HapticFeedback.heavyImpact();
        _count = 0;
      }
    });
    _saveLifetime();
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() => _count = 0);
  }

  void _cycleDhikr() {
    setState(() {
      _dhikrIndex = (_dhikrIndex + 1) % _dhikrList.length;
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = _dhikrList[_dhikrIndex];
    final progress = _count / _target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih'),
        actions: [
          IconButton(
            onPressed: _cycleDhikr,
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Change dhikr',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                dhikr.$2,
                style: AppTheme.arabicStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                  fontSize: 34,
                  weight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                dhikr.$1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.gold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lifetime: $_lifetimeTotal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              GestureDetector(
                onTap: _increment,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.tealPrimary,
                        AppColors.tealPrimaryLight,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tealPrimary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.gold,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_count',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'of $_target',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap the circle to count',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset count'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
