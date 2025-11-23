import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';

class SportsPage extends StatelessWidget {
  const SportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '本周目标',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '3/5 次运动',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.candyGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '保持不错 💪',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.candyGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _StartWorkoutCard(),
                  const SizedBox(height: 32),
                  const Text(
                    '本周数据',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: '总距离',
                          value: '12.5',
                          unit: 'km',
                          icon: Icons.map_outlined,
                          color: AppColors.candyBlue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          label: '消耗',
                          value: '840',
                          unit: 'kcal',
                          icon: Icons.local_fire_department_outlined,
                          color: AppColors.candyOrange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          label: '时长',
                          value: '3.2',
                          unit: 'hr',
                          icon: Icons.timer_outlined,
                          color: AppColors.candyPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '最近记录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          '查看全部',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _ActivityItem(
                    title: '晨间慢跑',
                    date: '今天 07:30',
                    value: '5.2 km',
                    duration: '32 min',
                    icon: Icons.directions_run,
                    color: AppColors.candyPink,
                  ),
                  const SizedBox(height: 12),
                  const _ActivityItem(
                    title: '力量训练',
                    date: '昨天 18:45',
                    value: '340 kcal',
                    duration: '45 min',
                    icon: Icons.fitness_center,
                    color: AppColors.candyPurple,
                  ),
                  const SizedBox(height: 12),
                  const _ActivityItem(
                    title: '轻松骑行',
                    date: '11月20日',
                    value: '12.0 km',
                    duration: '55 min',
                    icon: Icons.directions_bike,
                    color: AppColors.candyBlue,
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

class _StartWorkoutCard extends StatelessWidget {
  const _StartWorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.candyLime.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.candyLime.withOpacity(0.4),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_run,
                            color: AppColors.candyLime,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '户外跑步',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  '准备好了吗？',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '开始运动',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.candyLime,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.candyLime.withOpacity(0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.white3d,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.title,
    required this.date,
    required this.value,
    required this.duration,
    required this.icon,
    required this.color,
  });

  final String title;
  final String date;
  final String value;
  final String duration;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.white3d,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
