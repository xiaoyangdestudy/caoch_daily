import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import 'providers/stats_provider.dart';
import '../../sports/domain/workout_record.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsProvider);
    final notifier = ref.read(statsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '统计',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _DateSelector(
                      period: state.period,
                      focusedDate: state.focusedDate,
                      onPeriodChanged: notifier.setPeriod,
                      onPrevious: notifier.previousPeriod,
                      onNext: notifier.nextPeriod,
                    ),
                    const SizedBox(height: 24),
                    _SummaryCards(
                      duration: state.totalDurationMinutes,
                      calories: state.totalCalories,
                      count: state.totalWorkouts,
                    ),
                    const SizedBox(height: 24),
                    _ActivityChart(
                      period: state.period,
                      dailyDuration: state.dailyDuration,
                    ),
                    const SizedBox(height: 24),
                    _RecentActivityList(
                      records: state.filteredRecords,
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

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.period,
    required this.focusedDate,
    required this.onPeriodChanged,
    required this.onPrevious,
    required this.onNext,
  });

  final StatsPeriod period;
  final DateTime focusedDate;
  final ValueChanged<StatsPeriod> onPeriodChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  String get _dateRangeLabel {
    if (period == StatsPeriod.week) {
      // Start of week (Monday)
      final start = focusedDate.subtract(Duration(days: focusedDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      final dateFormat = DateFormat('MM.dd');
      return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
    } else {
      return DateFormat('yyyy年MM月').format(focusedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: '周',
                  isSelected: period == StatsPeriod.week,
                  onTap: () => onPeriodChanged(StatsPeriod.week),
                ),
              ),
              Expanded(
                child: _SegmentButton(
                  label: '月',
                  isSelected: period == StatsPeriod.month,
                  onTap: () => onPeriodChanged(StatsPeriod.month),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
                color: Colors.black54,
              ),
              Text(
                _dateRangeLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
                color: Colors.black54,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.candyBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.duration,
    required this.calories,
    required this.count,
  });

  final int duration;
  final int calories;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: '总时长',
            value: duration.toString(),
            unit: 'min',
            color: AppColors.candyPink,
            shadow: AppShadows.pink3d,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: '消耗',
            value: (calories / 1000).toStringAsFixed(1),
            unit: 'kcal',
            color: AppColors.candyYellow,
            shadow: AppShadows.yellow3d,
            darkText: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: '次数',
            value: count.toString(),
            unit: '次',
            color: AppColors.candyBlue,
            shadow: AppShadows.blue3d,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.shadow,
    this.darkText = false,
  });

  final String title;
  final String value;
  final String unit;
  final Color color;
  final List<BoxShadow> shadow;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final textColor = darkText ? Colors.black87 : Colors.white;
    final subTextColor = darkText ? Colors.black54 : Colors.white70;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({
    required this.period,
    required this.dailyDuration,
  });

  final StatsPeriod period;
  final Map<int, int> dailyDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '活动趋势',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: dailyDuration.isEmpty
                ? const Center(
                    child: Text(
                      '暂无数据',
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _getBottomLabel(value.toInt()),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getMaxY() / 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _getBarGroups(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    if (dailyDuration.isEmpty) return 100;
    final maxValue = dailyDuration.values.reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  String _getBottomLabel(int value) {
    if (period == StatsPeriod.week) {
      const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
      return value >= 1 && value <= 7 ? weekdays[value - 1] : '';
    } else {
      return value.toString();
    }
  }

  List<BarChartGroupData> _getBarGroups() {
    final groups = <BarChartGroupData>[];
    final maxIndex = period == StatsPeriod.week ? 7 : 31;

    for (int i = 1; i <= maxIndex; i++) {
      final value = dailyDuration[i]?.toDouble() ?? 0;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: AppColors.candyPink,
              width: period == StatsPeriod.week ? 20 : 8,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    return groups;
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.records});

  final List<WorkoutRecord> records;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近活动',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  '暂无活动记录',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else
            ...records.take(5).map((record) => _ActivityItem(record: record)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.record});

  final WorkoutRecord record;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.candyPink.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_run,
              color: AppColors.candyPink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.type.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(record.startTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.durationMinutes} min',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${record.caloriesKcal} kcal',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
