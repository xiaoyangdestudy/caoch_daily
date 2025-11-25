import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/sleep_providers.dart';
import '../domain/sleep_record.dart';

class SleepPage extends ConsumerStatefulWidget {
  const SleepPage({super.key});

  @override
  ConsumerState<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends ConsumerState<SleepPage> {
  DateTime _selectedDate = DateTime.now();

  SleepRecord? _recordForDate(List<SleepRecord> records) {
    for (final record in records) {
      if (_isSameDay(record.date, _selectedDate)) {
        return record;
      }
    }
    return null;
  }

  List<_SleepDayStat> _buildWeekStats(List<SleepRecord> records) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final stats = <_SleepDayStat>[];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayRecords = records.where(
        (record) => _isSameDay(record.date, day),
      );
      final hours = dayRecords.fold<double>(
        0,
        (sum, record) => sum + record.duration.inMinutes / 60,
      );
      stats.add(
        _SleepDayStat(
          label: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][i],
          hours: hours,
          isToday: _isSameDay(day, now),
        ),
      );
    }
    return stats;
  }

  void _changeDate(int offset) {
    final newDate = _selectedDate.add(Duration(days: offset));
    final today = DateTime.now();
    if (newDate.isAfter(today)) return;
    setState(() => _selectedDate = newDate);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> _showRecordSheet(SleepRecord? record) async {
    final result = await showModalBottomSheet<_SleepRecordResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SleepRecordSheet(
          initialBedtime: record != null
              ? TimeOfDay.fromDateTime(record.bedtime)
              : const TimeOfDay(hour: 23, minute: 30),
          initialWakeTime: record != null
              ? TimeOfDay.fromDateTime(record.wakeTime)
              : const TimeOfDay(hour: 7, minute: 0),
          initialQuality: record?.sleepQuality ?? 3,
          initialNote: record?.note,
        );
      },
    );

    if (result != null && mounted) {
      await ref
          .read(sleepRecordsProvider.notifier)
          .saveRecord(
            date: _selectedDate,
            bedtime: result.bedtime,
            wakeTime: result.wakeTime,
            quality: result.quality,
            note: result.note,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(sleepRecordsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1B4B),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E1A47), Color(0xFF1A1B4B)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  '睡眠监测',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: recordsAsync.when(
                  data: (records) {
                    final record = _recordForDate(records);
                    final stats = _buildWeekStats(records);
                    final duration = record?.duration;

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _SleepSummaryCard(
                            record: record,
                            selectedDate: _selectedDate,
                            durationLabel: _formatDuration(duration),
                            onPrevDay: () => _changeDate(-1),
                            onNextDay: () => _changeDate(1),
                          ),
                          const SizedBox(height: 24),
                          _SleepQualityCard(record: record),
                          const SizedBox(height: 24),
                          _WeeklySleepChart(stats: stats),
                          const SizedBox(height: 32),
                          _RecordSleepButton(
                            onTap: () => _showRecordSheet(record),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      '加载失败：$error',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepSummaryCard extends StatelessWidget {
  const _SleepSummaryCard({
    required this.record,
    required this.selectedDate,
    required this.durationLabel,
    required this.onPrevDay,
    required this.onNextDay,
  });

  final SleepRecord? record;
  final DateTime selectedDate;
  final String durationLabel;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MM月dd日').format(selectedDate);
    final weekdayLabel = [
      '周一',
      '周二',
      '周三',
      '周四',
      '周五',
      '周六',
      '周日',
    ][selectedDate.weekday - 1];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPrevDay,
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Column(
                children: [
                  Text(
                    weekdayLabel,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onNextDay,
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '昨晚睡眠时长',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            durationLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(
                Icons.bedtime_rounded,
                '入睡',
                record != null
                    ? DateFormat('HH:mm').format(record!.bedtime)
                    : '--:--',
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildDetailItem(
                Icons.wb_sunny_rounded,
                '起床',
                record != null
                    ? DateFormat('HH:mm').format(record!.wakeTime)
                    : '--:--',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String time) {
    return Column(
      children: [
        Icon(icon, color: AppColors.candyBlue, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SleepQualityCard extends StatelessWidget {
  const _SleepQualityCard({this.record});

  final SleepRecord? record;

  String get _qualityLabel {
    final quality = record?.sleepQuality ?? 0;
    if (quality >= 4) return '睡眠质量不错';
    if (quality == 3) return '睡得一般，可以再优化';
    if (quality > 0) return '今晚多注意放松';
    return '还没有记录睡眠';
  }

  String get _qualityDetail {
    final customNote = record?.note;
    if (customNote != null && customNote.isNotEmpty) return customNote;
    final quality = record?.sleepQuality ?? 0;
    if (quality >= 4) return '深度睡眠占比 25%，继续保持！';
    if (quality == 3) return '可尝试提前 30 分钟放松，提升入睡效率。';
    if (quality > 0) return '试着早点上床或减少睡前看屏幕时间。';
    return '记录一次睡眠，就能看到趋势～';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.candyBlue.withOpacity(0.2),
            ),
            child: Icon(
              Icons.stars_rounded,
              color: AppColors.candyBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _qualityLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _qualityDetail,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySleepChart extends StatelessWidget {
  const _WeeklySleepChart({required this.stats});

  final List<_SleepDayStat> stats;

  @override
  Widget build(BuildContext context) {
    final maxHours = stats.fold<double>(
      0,
      (previousValue, element) =>
          element.hours > previousValue ? element.hours : previousValue,
    );
    final normalizedMax = maxHours > 0 ? maxHours : 8;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本周睡眠趋势',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.map((stat) {
                final height = (stat.hours / normalizedMax) * 120;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 12,
                      height: height,
                      decoration: BoxDecoration(
                        color: stat.isToday
                            ? AppColors.candyBlue
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stat.label,
                      style: TextStyle(
                        color: stat.isToday ? Colors.white : Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordSleepButton extends StatelessWidget {
  const _RecordSleepButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.candyBlue, AppColors.candyPurple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.blue3d,
        ),
        child: const Center(
          child: Text(
            '记录睡眠',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _SleepDayStat {
  const _SleepDayStat({
    required this.label,
    required this.hours,
    required this.isToday,
  });

  final String label;
  final double hours;
  final bool isToday;
}

class _SleepRecordResult {
  _SleepRecordResult({
    required this.bedtime,
    required this.wakeTime,
    required this.quality,
    this.note,
  });

  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;
  final int quality;
  final String? note;
}

class _SleepRecordSheet extends StatefulWidget {
  const _SleepRecordSheet({
    required this.initialBedtime,
    required this.initialWakeTime,
    required this.initialQuality,
    this.initialNote,
  });

  final TimeOfDay initialBedtime;
  final TimeOfDay initialWakeTime;
  final int initialQuality;
  final String? initialNote;

  @override
  State<_SleepRecordSheet> createState() => _SleepRecordSheetState();
}

class _SleepRecordSheetState extends State<_SleepRecordSheet> {
  late TimeOfDay _bedtime = widget.initialBedtime;
  late TimeOfDay _wakeTime = widget.initialWakeTime;
  late double _quality = widget.initialQuality.toDouble();
  late final TextEditingController _noteController = TextEditingController(
    text: widget.initialNote ?? '',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickBedtime() async {
    final time = await showTimePicker(context: context, initialTime: _bedtime);
    if (time != null) {
      setState(() => _bedtime = time);
    }
  }

  Future<void> _pickWakeTime() async {
    final time = await showTimePicker(context: context, initialTime: _wakeTime);
    if (time != null) {
      setState(() => _wakeTime = time);
    }
  }

  void _submit() {
    Navigator.of(context).pop(
      _SleepRecordResult(
        bedtime: _bedtime,
        wakeTime: _wakeTime,
        quality: _quality.round(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
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
            color: Color(0xFF1A1B4B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '记录昨晚睡眠',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _TimePickerButton(
                      label: '入睡时间',
                      time: _bedtime,
                      onTap: _pickBedtime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimePickerButton(
                      label: '起床时间',
                      time: _wakeTime,
                      onTap: _pickWakeTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('主观睡眠质量', style: TextStyle(color: Colors.white70)),
                  Slider(
                    value: _quality,
                    onChanged: (value) => setState(() => _quality = value),
                    divisions: 4,
                    min: 1,
                    max: 5,
                    label: _quality.round().toString(),
                    activeColor: AppColors.candyBlue,
                    inactiveColor: Colors.white24,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '备注（可选）',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.candyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '保存记录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
