import 'package:flutter/material.dart';
import '../models/hadith.dart';
import '../services/hadith_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class HadithBooksScreen extends StatefulWidget {
  const HadithBooksScreen({super.key});

  @override
  State<HadithBooksScreen> createState() => _HadithBooksScreenState();
}

class _HadithBooksScreenState extends State<HadithBooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: HadithService.tabbedBooks.length, vsync: this);
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
        title: const Text('Hadith Books'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          tabs: HadithService.tabbedBooks
              .map((b) => Tab(text: b))
              .toList(),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tab,
          children: HadithService.tabbedBooks
              .map((b) => _BookTab(bookName: b))
              .toList(),
        ),
      ),
    );
  }
}

class _BookTab extends StatefulWidget {
  final String bookName;
  const _BookTab({required this.bookName});

  @override
  State<_BookTab> createState() => _BookTabState();
}

class _BookTabState extends State<_BookTab>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  List<Hadith> _results = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final results = await HadithService.searchBook(widget.bookName, q);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search by word or hadith number',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: _search,
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_loading)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Loading the book the first time may take a moment…',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_error != null)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: _search,
                        child: const Text('Try again')),
                  ],
                ),
              ),
            ),
          )
        else if (!_searched)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_rounded,
                        size: 48,
                        color: AppColors.gold.withValues(alpha: 0.6)),
                    const SizedBox(height: 16),
                    Text(
                      'Type a word above to search ${widget.bookName}.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_results.isEmpty)
          Expanded(
            child: Center(
              child: Text('No hadith found for that word.',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: _results.length,
              itemBuilder: (context, i) =>
                  _HadithTile(hadith: _results[i]),
            ),
          ),
      ],
    );
  }
}

/// A hadith card showing reference and grade label, with EN/Urdu toggle.
class _HadithTile extends StatefulWidget {
  final Hadith hadith;
  const _HadithTile({required this.hadith});

  @override
  State<_HadithTile> createState() => _HadithTileState();
}

class _HadithTileState extends State<_HadithTile> {
  bool _showUrdu = false;

  @override
  Widget build(BuildContext context) {
    final hadith = widget.hadith;
    final hasUrdu = hadith.urduText != null && hadith.urduText!.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                '${hadith.book} · #${hadith.number}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              GradeLabel(grade: hadith.grade),
            ],
          ),
          if (hadith.arabicText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                hadith.arabicText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                  fontSize: 20,
                  height: 1.9,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (hasUrdu)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => setState(() => _showUrdu = !_showUrdu),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
            ),
          _showUrdu && hasUrdu
              ? Text(
                  hadith.urduText!,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabicStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                    fontSize: 17,
                    height: 1.8,
                  ),
                )
              : Text(
                  hadith.englishText,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
        ],
      ),
    );
  }
}

/// Renders a colored label for a hadith's authenticity grade.
class GradeLabel extends StatelessWidget {
  final String? grade;
  const GradeLabel({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final g = (grade ?? '').toLowerCase();
    Color color;
    String text;

    if (grade == null || grade!.trim().isEmpty) {
      color = Colors.grey;
      text = 'Ungraded';
    } else if (g.contains('sahih') || g.contains('authentic')) {
      color = AppColors.success;
      text = grade!;
    } else if (g.contains('hasan')) {
      color = AppColors.gold;
      text = grade!;
    } else if (g.contains('da') || g.contains('weak')) {
      color = AppColors.danger;
      text = grade!;
    } else {
      color = AppColors.brownSecondary;
      text = grade!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
