import 'package:flutter/material.dart';

enum MealType {
  breakfast('早餐', Icons.wb_twilight),
  lunch('午餐', Icons.wb_sunny),
  dinner('晚餐', Icons.nights_stay),
  snack('加餐', Icons.cookie);

  final String label;
  final IconData icon;
  const MealType(this.label, this.icon);
}

class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? imageUrl;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl,
  });
}

class DailyDiet {
  final DateTime date;
  final List<FoodItem> breakfast;
  final List<FoodItem> lunch;
  final List<FoodItem> dinner;
  final List<FoodItem> snacks;

  const DailyDiet({
    required this.date,
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
    this.snacks = const [],
  });

  int get totalCalories =>
      [...breakfast, ...lunch, ...dinner, ...snacks]
          .fold(0, (sum, item) => sum + item.calories);
}
