import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);

  String get _durationString {
    final bed = _bedtime.hour * 60 + _bedtime.minute;
    final wake = _wakeTime.hour * 60 + _wakeTime.minute;
    
    int diffMinutes;
    if (wake >= bed) {
      diffMinutes = wake - bed;
    } else {
      diffMinutes = (24 * 60 - bed) + wake;
    }
    
    final hours = diffMinutes ~/ 60;
    final minutes = diffMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> _showRecordSheet() async {
    TimeOfDay tempBedtime = _bedtime;
    TimeOfDay tempWakeTime = _wakeTime;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _TimePickerButton(
                      label: '入睡时间',
                      time: tempBedtime,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: tempBedtime,
                        );
                        if (time != null) {
                          setSheetState(() => tempBedtime = time);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimePickerButton(
                      label: '起床时间',
                      time: tempWakeTime,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: tempWakeTime,
                        );
                        if (time != null) {
                          setSheetState(() => tempWakeTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _bedtime = tempBedtime;
                      _wakeTime = tempWakeTime;
                    });
                    Navigator.pop(context);
                  },
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B4B), // Deep blue background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E1A47), // Deep purple
              Color(0xFF1A1B4B), // Deep blue
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  '睡眠监测',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _SleepSummaryCard(
                        duration: _durationString,
                        bedtime: _bedtime.format(context),
                        wakeTime: _wakeTime.format(context),
                      ),
                      const SizedBox(height: 24),
                      const _SleepQualityCard(),
                      const SizedBox(height: 24),
                      const _WeeklySleepChart(),
                      const SizedBox(height: 32),
                      _RecordSleepButton(onTap: _showRecordSheet),
                    ],
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
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

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

class _SleepSummaryCard extends StatelessWidget {
  final String duration;
  final String bedtime;
  final String wakeTime;

  const _SleepSummaryCard({
    required this.duration,
    required this.bedtime,
    required this.wakeTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            '昨晚睡眠时长',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            duration,
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
              _buildDetailItem(Icons.bedtime_rounded, '入睡', bedtime),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildDetailItem(Icons.wb_sunny_rounded, '起床', wakeTime),
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
  const _SleepQualityCard();

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
            child: Icon(Icons.stars_rounded, color: AppColors.candyBlue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '睡眠质量不错',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '深度睡眠占比 25%，继续保持！',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
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
  const _WeeklySleepChart();

  @override
  Widget build(BuildContext context) {
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
              children: [
                _buildBar('周一', 7.5, true),
                _buildBar('周二', 6.0, false),
                _buildBar('周三', 8.0, false),
                _buildBar('周四', 7.0, false),
                _buildBar('周五', 5.5, false),
                _buildBar('周六', 9.0, false),
                _buildBar('周日', 8.5, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double hours, bool isToday) {
    final height = (hours / 10) * 100; // Max 10 hours
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: height,
          decoration: BoxDecoration(
            color: isToday ? AppColors.candyBlue : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isToday ? Colors.white : Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _RecordSleepButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RecordSleepButton({required this.onTap});

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
