// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FoodItemImpl _$$FoodItemImplFromJson(Map<String, dynamic> json) =>
    _$FoodItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$FoodItemImplToJson(_$FoodItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'imageUrl': instance.imageUrl,
    };

_$MealRecordImpl _$$MealRecordImplFromJson(Map<String, dynamic> json) =>
    _$MealRecordImpl(
      id: json['id'] as String,
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MealRecordImplToJson(_$MealRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'items': instance.items,
      'notes': instance.notes,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};
