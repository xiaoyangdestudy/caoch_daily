import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';

import 'dart:async';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  Timer? _timer;
  static const int _defaultTime = 25 * 60; // 25 minutes
  int _remainingSeconds = _defaultTime;
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    } else {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _stopTimer();
          // TODO: Show completion notification
        }
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _defaultTime;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerString {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _FocusTimerCard(
                timeString: _timerString,
                isRunning: _isRunning,
              ),
              const SizedBox(height: 40),
              const _TaskSummaryCard(),
              const SizedBox(height: 40),
              const _ProductivityChart(),
              const SizedBox(height: 40),
              _StartFocusButton(
                isRunning: _isRunning,
                onTap: _toggleTimer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusTimerCard extends StatelessWidget {
  const _FocusTimerCard({
    required this.timeString,
    required this.isRunning,
  });

  final String timeString;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isRunning ? Colors.black : Colors.black12,
              width: isRunning ? 2 : 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 8),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskSummaryCard extends StatelessWidget {
  const _TaskSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Completed',
            '8',
            'Tasks',
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: Colors.black12,
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),
        Expanded(
          child: _buildStatItem(
            'Duration',
            '4.5',
            'Hours',
          ),
        ),
      ],
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
  const _ProductivityChart();

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 24),
        SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('M', 0.4),
              _buildBar('T', 0.6),
              _buildBar('W', 0.8),
              _buildBar('T', 0.5),
              _buildBar('F', 0.7),
              _buildBar('S', 0.2),
              _buildBar('S', 0.3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String day, double progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 100 * progress,
          decoration: BoxDecoration(
            color: progress > 0.5 ? Colors.black : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: const TextStyle(
            color: Colors.black38,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StartFocusButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isRunning;

  const _StartFocusButton({
    required this.onTap,
    required this.isRunning,
  });

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
