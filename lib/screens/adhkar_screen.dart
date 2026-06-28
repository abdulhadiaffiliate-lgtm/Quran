import 'package:flutter/material.dart';
import '../utils/adhkar_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    // Default to evening after ~3pm, morning otherwise.
    if (DateTime.now().hour >= 15) _tab.index = 1;
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
        title: const Text('Morning & Evening Adhkar'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          tabs: const [
            Tab(text: 'Morning'),
            Tab(text: 'Evening'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tab,
          children: [
            _AdhkarList(items: AdhkarData.morning),
            _AdhkarList(items: AdhkarData.evening),
          ],
        ),
      ),
    );
  }
}

class _AdhkarList extends StatefulWidget {
  final List<Adhkar> items;
  const _AdhkarList({required this.items});

  @override
  State<_AdhkarList> createState() => _AdhkarListState();
}

class _AdhkarListState extends State<_AdhkarList>
    with AutomaticKeepAliveClientMixin {
  // Track tap progress per item index.
  late List<int> _progress;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _progress = List.filled(widget.items.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.items.length,
      itemBuilder: (context, i) {
        final item = widget.items[i];
        final done = _progress[i] >= item.repeat;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_progress[i] < item.repeat) _progress[i]++;
            });
          },
          onLongPress: item.fullArabic != null
              ? () => _showFullTextCard(context, item)
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: done ? AppColors.success : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.note != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.note!,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Repeat counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.tealPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        done ? 'Done' : '${_progress[i]} / ${item.repeat}',
                        style: TextStyle(
                          color: done ? AppColors.success : AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    item.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.arabicStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color!,
                      fontSize: 22,
                      height: 1.9,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.transliteration,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.translation,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  item.fullArabic != null
                      ? 'Tap to count · hold to read in full'
                      : 'Tap the card to count',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFullTextCard(BuildContext context, Adhkar item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    item.note ?? '',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.fullArabic ?? '',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.arabicStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color!,
                      fontSize: 22,
                      height: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
