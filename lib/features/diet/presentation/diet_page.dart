import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../domain/diet_models.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final breakfastItems = [
      const FoodItem(id: '1', name: '燕麦牛奶', calories: 240, protein: 8.0, carbs: 32.0, fat: 6.0),
      const FoodItem(id: '2', name: '煮鸡蛋', calories: 70, protein: 6.0, carbs: 0.5, fat: 5.0),
    ];
    final lunchItems = [
      const FoodItem(id: '3', name: '鸡胸肉沙拉', calories: 350, protein: 30.0, carbs: 12.0, fat: 10.0),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.aiFoodRecognition),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: const Text('AI 识别', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
            title: const Text(
              '饮食记录',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _CalorieSummaryCard(
                    consumed: 660,
                    goal: 2000,
                  ),
                  const SizedBox(height: 24),
                  _MealSection(
                    type: MealType.breakfast,
                    items: breakfastItems,
                    totalCalories: 310,
                  ),
                  const SizedBox(height: 16),
                  _MealSection(
                    type: MealType.lunch,
                    items: lunchItems,
                    totalCalories: 350,
                  ),
                  const SizedBox(height: 16),
                  const _MealSection(
                    type: MealType.dinner,
                    items: [],
                    totalCalories: 0,
                  ),
                  const SizedBox(height: 16),
                  const _MealSection(
                    type: MealType.snack,
                    items: [],
                    totalCalories: 0,
                  ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({required this.consumed, required this.goal});

  final int consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);
    final remaining = goal - consumed;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.candyOrange, Color(0xFFFFAB91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.orange3d,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日摄入',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$consumed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6, left: 4),
                        child: Text(
                          'kcal',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: progress,
                        color: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        strokeWidth: 6,
                      ),
                    ),
                    const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 30),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '目标 $goal',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '还差 $remaining',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.type,
    required this.items,
    required this.totalCalories,
  });

  final MealType type;
  final List<FoodItem> items;
  final int totalCalories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.white3d,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.candyOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: AppColors.candyOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                type.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '$totalCalories kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.add_circle_outline_rounded, color: Colors.grey.shade400),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🥗', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${item.calories} kcal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                '还没有记录${type.label}',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
