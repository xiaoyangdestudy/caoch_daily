// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutRecordImpl _$$WorkoutRecordImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutRecordImpl(
      id: json['id'] as String,
      type: $enumDecode(_$WorkoutTypeEnumMap, json['type']),
      startTime: DateTime.parse(json['startTime'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      caloriesKcal: (json['caloriesKcal'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$WorkoutRecordImplToJson(_$WorkoutRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$WorkoutTypeEnumMap[instance.type]!,
      'startTime': instance.startTime.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'distanceKm': instance.distanceKm,
      'caloriesKcal': instance.caloriesKcal,
      'notes': instance.notes,
    };

const _$WorkoutTypeEnumMap = {
  WorkoutType.run: 'run',
  WorkoutType.cycle: 'cycle',
  WorkoutType.swim: 'swim',
  WorkoutType.gym: 'gym',
  WorkoutType.walk: 'walk',
  WorkoutType.other: 'other',
};
