import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/design/app_colors.dart';
import '../../work/application/work_providers.dart';
import '../../work/domain/focus_session.dart';

class WorkPage extends ConsumerStatefulWidget {
  const WorkPage({super.key});

  @override
  ConsumerState<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends ConsumerState<WorkPage> {
  static const int _defaultSeconds = 25 * 60;

  Timer? _timer;
  int _remainingSeconds = _defaultSeconds;
  bool _isRunning = false;
  DateTime? _sessionStart;
  String _taskName = '深度专注';

  String get _timerString {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _toggleTimer() {
    if (_isRunning) {
      _completeSession(completed: false);
    } else {
      setState(() {
        _isRunning = true;
        _remainingSeconds = _defaultSeconds;
        _sessionStart = DateTime.now();
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _completeSession(completed: true);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('恭喜完成 25 分钟专注！')));
        }
      });
    }
  }

  Future<void> _completeSession({required bool completed}) async {
    _timer?.cancel();

    final start = _sessionStart;
    if (start != null) {
      final elapsed = _defaultSeconds - _remainingSeconds;
      final end = start.add(
        Duration(seconds: completed ? _defaultSeconds : elapsed),
      );
      await ref
          .read(focusSessionsProvider.notifier)
          .logSession(
            start: start,
            end: end,
            targetMinutes: _defaultSeconds ~/ 60,
            taskName: _taskName,
            completed: completed,
          );
    }

    setState(() {
      _isRunning = false;
      _remainingSeconds = _defaultSeconds;
      _sessionStart = null;
    });
  }

  Future<void> _editTaskName() async {
    final controller = TextEditingController(text: _taskName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置当前任务'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '例如：整理周报'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      setState(() => _taskName = name);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<_FocusDayStat> _buildWeeklyStats(List<FocusSession> sessions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final stats = <_FocusDayStat>[];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final daySessions = sessions.where(
        (session) => _isSameDay(session.startTime, day),
      );
      final hours = daySessions.fold<double>(
        0,
        (sum, session) => sum + session.actualDuration.inMinutes / 60,
      );
      stats.add(
        _FocusDayStat(
          label: ['一', '二', '三', '四', '五', '六', '日'][i],
          hours: hours,
        ),
      );
    }
    return stats;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(focusSessionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '工作专注',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          final today = DateTime.now();
          final todaySessions = sessions.where(
            (session) => _isSameDay(session.startTime, today),
          );
          final completedCount = todaySessions
              .where((session) => session.completed)
              .length;
          final totalHours = todaySessions.fold<double>(
            0,
            (sum, session) => sum + session.actualDuration.inMinutes / 60,
          );
          final weeklyStats = _buildWeeklyStats(sessions);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _FocusTimerCard(
                    timeString: _timerString,
                    isRunning: _isRunning,
                    taskName: _taskName,
                    onEditTask: _editTaskName,
                  ),
                  const SizedBox(height: 24),
                  _TaskSummaryCard(
                    completedCount: completedCount,
                    totalHours: totalHours,
                  ),
                  const SizedBox(height: 24),
                  _ProductivityChart(stats: weeklyStats),
                  const SizedBox(height: 24),
                  _RecentSessionsList(sessions: sessions.take(5).toList()),
                  const SizedBox(height: 32),
                  _StartFocusButton(isRunning: _isRunning, onTap: _toggleTimer),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
      ),
    );
  }
}

class _FocusTimerCard extends StatelessWidget {
  const _FocusTimerCard({
    required this.timeString,
    required this.isRunning,
    required this.taskName,
    required this.onEditTask,
  });

  final String timeString;
  final bool isRunning;
  final String taskName;
  final VoidCallback onEditTask;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isRunning ? Colors.black : Colors.black12,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            timeString,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 64,
              fontWeight: FontWeight.w200,
              letterSpacing: -2,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isRunning ? Colors.black : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRunning ? 'RUNNING' : 'FOCUS',
              style: TextStyle(
                color: isRunning ? Colors.white : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                taskName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: onEditTask,
                icon: const Icon(Icons.edit, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskSummaryCard extends StatelessWidget {
  const _TaskSummaryCard({
    required this.completedCount,
    required this.totalHours,
  });

  final int completedCount;
  final double totalHours;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('已完成', completedCount.toString(), 'Sessions'),
          ),
          Container(width: 1, height: 48, color: Colors.black12),
          Expanded(
            child: _buildStatItem(
              '投入时长',
              totalHours.toStringAsFixed(1),
              'Hours',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$unit $label',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ProductivityChart extends StatelessWidget {
  const _ProductivityChart({required this.stats});

  final List<_FocusDayStat> stats;

  @override
  Widget build(BuildContext context) {
    final maxHours = stats.fold<double>(
      0,
      (maxValue, stat) => stat.hours > maxValue ? stat.hours : maxValue,
    );
    final normalizedMax = maxHours > 0 ? maxHours : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVITY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: stats.map((stat) {
              final height = (stat.hours / normalizedMax) * 120;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 20,
                    height: height,
                    decoration: BoxDecoration(
                      color: stat.hours > 0.5 ? Colors.black : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat.label,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RecentSessionsList extends StatelessWidget {
  const _RecentSessionsList({required this.sessions});

  final List<FocusSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.grey[50],
        ),
        child: const Text(
          '还没有记录，开始一次专注吧！',
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近记录',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...sessions.map((session) => _FocusSessionTile(session: session)),
        ],
      ),
    );
  }
}

class _FocusSessionTile extends StatelessWidget {
  const _FocusSessionTile({required this.session});

  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MM/dd HH:mm');
    final durationMinutes = session.actualDuration.inMinutes;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: session.completed ? Colors.black : Colors.grey[200],
            ),
            alignment: Alignment.center,
            child: Icon(
              session.completed ? Icons.check : Icons.pause,
              color: session.completed ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.taskName ?? '专注任务',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatter.format(session.startTime),
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          Text(
            '$durationMinutes min',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FocusDayStat {
  const _FocusDayStat({required this.label, required this.hours});

  final String label;
  final double hours;
}

class _StartFocusButton extends StatelessWidget {
  const _StartFocusButton({required this.onTap, required this.isRunning});

  final VoidCallback onTap;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: isRunning ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Text(
            isRunning ? 'PAUSE SESSION' : 'START SESSION',
            style: TextStyle(
              color: isRunning ? Colors.black : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
