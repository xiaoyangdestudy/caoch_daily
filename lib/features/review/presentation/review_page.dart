import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/review_providers.dart';
import '../domain/review_record.dart';

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(reviewEntriesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: entriesAsync.when(
          data: (entries) {
            final todayIndex = entries.indexWhere((entry) => entry.isToday);
            ReviewEntry? todayEntry;
            late final List<ReviewEntry> history;

            if (todayIndex >= 0) {
              todayEntry = entries[todayIndex];
              history = [
                ...entries.sublist(0, todayIndex),
                ...entries.sublist(todayIndex + 1),
              ];
            } else {
              history = entries;
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '复盘',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        if (todayEntry != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.candyBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: AppColors.candyBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '已完成',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.candyBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ReviewHeroCard(
                          entry: todayEntry,
                          onDetail: todayEntry == null
                              ? null
                              : () => _showReviewDetail(context, todayEntry!),
                          onStart: () => _openReviewSheet(context, ref),
                        ),
                        if (history.isNotEmpty) const SizedBox(height: 24),
                        if (history.isNotEmpty)
                          const Text(
                            '历史复盘',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (history.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppShadows.white3d,
                        ),
                        child: const Text(
                          '还没有历史复盘记录。坚持每天 3 分钟，看看自己如何进步！',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = history[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == history.length - 1 ? 120 : 16,
                          ),
                          child: _ReviewHistoryCard(
                            entry: entry,
                            onTap: () => _showReviewDetail(context, entry),
                          ),
                        );
                      }, childCount: history.length),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('加载失败：$error')),
        ),
      ),
    );
  }

  Future<void> _openReviewSheet(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_ReviewFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReviewFormSheet(),
    );
    if (result != null) {
      await ref
          .read(reviewEntriesProvider.notifier)
          .addReview(
            mood: result.mood,
            highlights: result.highlights,
            improvements: result.improvements,
            plans: result.plans,
            note: result.note,
          );
    }
  }

  void _showReviewDetail(BuildContext context, ReviewEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReviewDetailSheet(entry: entry),
    );
  }
}

class _ReviewHeroCard extends StatelessWidget {
  const _ReviewHeroCard({
    required this.entry,
    required this.onDetail,
    required this.onStart,
  });

  final ReviewEntry? entry;
  final VoidCallback? onDetail;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 16),
              blurRadius: 32,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '夜间复盘 · 3 分钟',
              style: TextStyle(
                color: Colors.white70,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '记录高光与不足，让 AI 帮你生成明日计划。',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('开始复盘'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.candyBlue, AppColors.candyPurple],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.blue3d,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry!.mood, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 8),
              const Text(
                '今日心情',
                style: TextStyle(color: Colors.white70, letterSpacing: 2),
              ),
              const Spacer(),
              Text(
                DateFormat('MM月dd日').format(entry!.date),
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry!.aiSummary ?? '持续向前的一天，继续保持！',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onDetail,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            child: const Text('查看报告'),
          ),
        ],
      ),
    );
  }
}

class _ReviewHistoryCard extends StatelessWidget {
  const _ReviewHistoryCard({required this.entry, required this.onTap});

  final ReviewEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MM.dd').format(entry.date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.white3d,
        ),
        child: Row(
          children: [
            Text(entry.mood, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.highlights.isNotEmpty
                        ? entry.highlights.first
                        : '保持专注的一天',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _ReviewDetailSheet extends StatelessWidget {
  const _ReviewDetailSheet({required this.entry});

  final ReviewEntry entry;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ReviewSection('今日亮点', entry.highlights),
      _ReviewSection('可改进', entry.improvements),
      _ReviewSection('明日计划', entry.tomorrowPlans),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(entry.mood, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Text(
                  DateFormat('yyyy.MM.dd').format(entry.date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              entry.aiSummary ?? '保持专注，稳步前进。',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...items,
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(entry.note!, style: const TextStyle(color: Colors.black54)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection(this.title, this.items);

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black45,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewFormResult {
  _ReviewFormResult({
    required this.mood,
    required this.highlights,
    required this.improvements,
    required this.plans,
    this.note,
  });

  final String mood;
  final List<String> highlights;
  final List<String> improvements;
  final List<String> plans;
  final String? note;
}

class _ReviewFormSheet extends StatefulWidget {
  const _ReviewFormSheet();

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _highlightController = TextEditingController();
  final TextEditingController _improvementController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<String> _moods = ['😄 状态在线', '🙂 平稳', '😴 有点累'];
  late String _selectedMood = _moods.first;

  @override
  void dispose() {
    _highlightController.dispose();
    _improvementController.dispose();
    _planController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      _ReviewFormResult(
        mood: _selectedMood,
        highlights: _splitLines(_highlightController.text),
        improvements: _splitLines(_improvementController.text),
        plans: _splitLines(_planController.text),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  List<String> _splitLines(String input) {
    return input
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        '今日复盘',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: _moods.map((mood) {
                      final selected = mood == _selectedMood;
                      return ChoiceChip(
                        label: Text(mood),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedMood = mood),
                        selectedColor: AppColors.candyBlue,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _highlightController,
                    label: '今日做得好的事',
                    hint: '每行一条，例如：坚持完 45 分钟力量训练',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _improvementController,
                    label: '需要改进的点',
                    hint: '每行一条，例如：复盘前刷手机太久',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _planController,
                    label: '明日行动',
                    hint: '每行一条，例如：早上 7:30 前完成晨跑',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(labelText: '附加备注（可选）'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('保存复盘'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
      ),
      minLines: 2,
      maxLines: 4,
      validator: (value) =>
          value == null || value.trim().isEmpty ? '请输入内容' : null,
    );
  }
}
