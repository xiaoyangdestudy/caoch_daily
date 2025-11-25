import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'diet_models.freezed.dart';
part 'diet_models.g.dart';

enum MealType {
  breakfast('早餐', Icons.wb_twilight),
  lunch('午餐', Icons.wb_sunny),
  dinner('晚餐', Icons.nights_stay),
  snack('加餐', Icons.cookie);

  final String label;
  final IconData icon;
  const MealType(this.label, this.icon);
}

@freezed
class FoodItem with _$FoodItem {
  const factory FoodItem({
    required String id,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    String? imageUrl,
  }) = _FoodItem;

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);
}

@freezed
class MealRecord with _$MealRecord {
  const MealRecord._();

  const factory MealRecord({
    required String id,
    required MealType mealType,
    required DateTime timestamp,
    @Default([]) List<FoodItem> items,
    String? notes,
  }) = _MealRecord;

  factory MealRecord.fromJson(Map<String, dynamic> json) =>
      _$MealRecordFromJson(json);

  int get totalCalories =>
      items.fold(0, (previousValue, item) => previousValue + item.calories);
}
