import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shell/presentation/app_shell_page.dart';

import '../../../app/router/app_routes.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/dashboard_providers.dart';
import '../domain/dashboard_overview.dart';
import '../domain/record_type.dart';
import '../../profile/application/profile_provider.dart';
import 'widgets/quick_record_sheet.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String get _dateLabel {
    final now = DateTime.now();
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.month}月${now.day}日 · $weekday';
  }

  void _openRecordSheet(BuildContext context, RecordType type) {
    showQuickRecordSheet(context, initialType: type);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewState = ref.watch(dashboardOverviewProvider);
    final overview = overviewState.data;
    final nickname = overview?.nickname ?? 'Alex';
    final hasError = overviewState.error != null;
    final cards = hasError
        ? _initialCardStats
        : (overview?.cards ?? _initialCardStats);
    final summaryText = hasError
        ? '数据加载失败，请稍后重试。'
        : overview?.summary ?? '今日数据加载中...记得随手记录。';
    final vitality = hasError ? 0 : overview?.vitalityScore ?? 0;

    // Get emoji from profile
    final profileState = ref.watch(profileProvider);
    final userEmoji = profileState.overview.emoji;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_background.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dateLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.black45,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nickname,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Review Button
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.cardSoft,
                        ),
                        child: IconButton(
                          onPressed: () => context.go(AppRoutes.review),
                          icon: const Icon(Icons.note_alt_outlined),
                          color: AppColors.candyPurple,
                          tooltip: '每日复盘',
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.candyPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.candyPurple.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: AppShadows.cardSoft,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          userEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _HeroCard(
                    summary: summaryText,
                    vitality: vitality,
                    isLoading: overviewState.isLoading,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final card = cards[index];
                    return DashboardStatCard(
                      title: card.type.label,
                      type: card.type,
                      value: card.value,
                      subValue: card.subValue,
                      progress: card.progress,
                      darkText: card.type.prefersDarkText,
                      onTap: () {
                        if (card.type == RecordType.exercise) {
                          context.push(AppRoutes.sports);
                        } else if (card.type == RecordType.diet) {
                          context.push(AppRoutes.diet);
                        } else if (card.type == RecordType.sleep) {
                          context.push(AppRoutes.sleep);
                        } else if (card.type == RecordType.work) {
                          context.push(AppRoutes.work);
                        } else {
                          _openRecordSheet(context, card.type);
                        }
                      },
                    );
                  }, childCount: cards.length),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.summary,
    required this.vitality,
    required this.isLoading,
  });

  final String summary;
  final int vitality;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.candyGreen,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.green3d,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '活力值',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLoading ? '--' : vitality.toString(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12, width: 2),
                        boxShadow: AppShadows.white3d,
                      ),
                      alignment: Alignment.center,
                      child: const Text('🔥', style: TextStyle(fontSize: 24)),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white54),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black87,
                        ),
                        alignment: Alignment.center,
                        child: const Text('😎', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          summary,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<DashboardCardStat> _initialCardStats = [
  DashboardCardStat(
    type: RecordType.exercise,
    value: '0',
    subValue: 'min',
    progress: 0,
    rawValue: 0,
  ),
  DashboardCardStat(
    type: RecordType.diet,
    value: '0',
    subValue: 'kcal',
    progress: 0,
    rawValue: 0,
  ),
  DashboardCardStat(
    type: RecordType.sleep,
    value: '0',
    subValue: 'hr',
    progress: null,
    rawValue: 0,
  ),
  DashboardCardStat(
    type: RecordType.work,
    value: '0',
    subValue: 'hr',
    progress: 0,
    rawValue: 0,
  ),
];

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.type,
    required this.value,
    this.subValue,
    this.progress,
    this.onTap,
    this.darkText = false,
  });

  final String title;
  final RecordType type;
  final String value;
  final String? subValue;
  final double? progress;
  final VoidCallback? onTap;
  final bool darkText;

  List<BoxShadow> get _shadows {
    switch (type) {
      case RecordType.exercise:
        return AppShadows.pink3d;
      case RecordType.diet:
        return AppShadows.yellow3d;
      case RecordType.sleep:
        return AppShadows.blue3d;
      case RecordType.work:
        return AppShadows.purple3d;
      case RecordType.reading:
        return AppShadows.green3d;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = type.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: _shadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(darkText ? 0.4 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type.icon,
                    color: darkText ? Colors.black87 : Colors.white,
                    size: 16,
                  ),
                ),
                if (progress != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(darkText ? 0.4 : 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${(progress! * 100).round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: darkText ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: darkText ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: darkText ? Colors.black : Colors.white,
                      ),
                    ),
                    if (subValue != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          subValue!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: darkText
                                ? Colors.black.withOpacity(0.7)
                                : Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(darkText ? 0.1 : 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress!.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: darkText ? Colors.black87 : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
