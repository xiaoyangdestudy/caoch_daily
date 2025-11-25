// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SleepRecordImpl _$$SleepRecordImplFromJson(Map<String, dynamic> json) =>
    _$SleepRecordImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      bedtime: DateTime.parse(json['bedtime'] as String),
      wakeTime: DateTime.parse(json['wakeTime'] as String),
      note: json['note'] as String?,
      sleepQuality: (json['sleepQuality'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SleepRecordImplToJson(_$SleepRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'bedtime': instance.bedtime.toIso8601String(),
      'wakeTime': instance.wakeTime.toIso8601String(),
      'note': instance.note,
      'sleepQuality': instance.sleepQuality,
    };
