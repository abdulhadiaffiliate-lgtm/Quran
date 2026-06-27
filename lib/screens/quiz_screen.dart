import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/quiz_data.dart';
import '../theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, int> _bestScores = {};

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestScores = {
        'easy': prefs.getInt('quiz_best_easy') ?? 0,
        'medium': prefs.getInt('quiz_best_medium') ?? 0,
        'hard': prefs.getInt('quiz_best_hard') ?? 0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Quiz')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Test your knowledge',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a level. Each quiz gives you the correct answer and a short explanation as you go.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _levelCard(
              'Easy',
              QuizLevel.easy,
              'easy',
              'Basics of Islam, prayer, and faith',
              Icons.star_outline_rounded,
            ),
            const SizedBox(height: 12),
            _levelCard(
              'Medium',
              QuizLevel.medium,
              'medium',
              'Tawheed, the Quran, and the Seerah',
              Icons.star_half_rounded,
            ),
            const SizedBox(height: 12),
            _levelCard(
              'Hard',
              QuizLevel.hard,
              'hard',
              'Deeper aqeedah and Islamic history',
              Icons.star_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelCard(String title, QuizLevel level, String key,
      String subtitle, IconData icon) {
    final total = QuizData.forLevel(level).length;
    final best = _bestScores[key] ?? 0;
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.gold),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 17)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 2),
            Text('Best: $best / $total',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.play_circle_fill_rounded,
            color: AppColors.gold, size: 30),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizPlayScreen(level: level, levelKey: key),
            ),
          );
          _loadScores();
        },
      ),
    );
  }
}

class QuizPlayScreen extends StatefulWidget {
  final QuizLevel level;
  final String levelKey;
  const QuizPlayScreen(
      {super.key, required this.level, required this.levelKey});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late List<QuizQuestion> _questions;
  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    // Shuffle a copy so order varies each attempt.
    _questions = List.of(QuizData.forLevel(widget.level))..shuffle(Random());
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selected = index;
      _answered = true;
      if (index == _questions[_current].correctIndex) _score++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _finished = true);
    final prefs = await SharedPreferences.getInstance();
    final key = 'quiz_best_${widget.levelKey}';
    final prevBest = prefs.getInt(key) ?? 0;
    if (_score > prevBest) {
      await prefs.setInt(key, _score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_levelName()} Quiz'),
      ),
      body: SafeArea(
        child: _finished ? _buildResult() : _buildQuestion(),
      ),
    );
  }

  String _levelName() {
    switch (widget.level) {
      case QuizLevel.easy:
        return 'Easy';
      case QuizLevel.medium:
        return 'Medium';
      case QuizLevel.hard:
        return 'Hard';
    }
  }

  Widget _buildQuestion() {
    final q = _questions[_current];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Progress
        Row(
          children: [
            Text(
              'Question ${_current + 1} of ${_questions.length}',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text('Score: $_score',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (_current + 1) / _questions.length,
            minHeight: 6,
            backgroundColor: AppColors.tealPrimary.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          q.question,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(height: 1.4, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        ...List.generate(q.options.length, (i) => _optionTile(q, i)),
        if (_answered) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _selected == q.correctIndex
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: _selected == q.correctIndex
                          ? AppColors.success
                          : AppColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selected == q.correctIndex ? 'Correct' : 'Not quite',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _selected == q.correctIndex
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(q.explanation,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.darkBg,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: _next,
            child: Text(
              _current < _questions.length - 1
                  ? 'Next question'
                  : 'See result',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }

  Widget _optionTile(QuizQuestion q, int i) {
    Color? bg;
    Color? border;
    if (_answered) {
      if (i == q.correctIndex) {
        bg = AppColors.success.withValues(alpha: 0.15);
        border = AppColors.success;
      } else if (i == _selected) {
        bg = AppColors.danger.withValues(alpha: 0.12);
        border = AppColors.danger;
      }
    }
    return GestureDetector(
      onTap: () => _selectOption(i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg ?? Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: border ?? Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                String.fromCharCode(65 + i), // A, B, C, D
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(q.options[i],
                  style: const TextStyle(fontSize: 15, height: 1.3)),
            ),
            if (_answered && i == q.correctIndex)
              const Icon(Icons.check_rounded, color: AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final pct = _score / _questions.length;
    String message;
    if (pct == 1.0) {
      message = 'Maa shaa Allah — a perfect score!';
    } else if (pct >= 0.7) {
      message = 'Well done — strong knowledge.';
    } else if (pct >= 0.4) {
      message = 'Good effort. Keep learning and try again.';
    } else {
      message = 'A good start. Review and give it another go.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$_score/${_questions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.darkBg,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                setState(() {
                  _questions =
                      List.of(QuizData.forLevel(widget.level))
                        ..shuffle(Random());
                  _current = 0;
                  _score = 0;
                  _selected = null;
                  _answered = false;
                  _finished = false;
                });
              },
              child: const Text('Try again',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to levels'),
            ),
          ],
        ),
      ),
    );
  }
}
