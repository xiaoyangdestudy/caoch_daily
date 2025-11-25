// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewEntryImpl _$$ReviewEntryImplFromJson(Map<String, dynamic> json) =>
    _$ReviewEntryImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String,
      highlights:
          (json['highlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      improvements:
          (json['improvements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tomorrowPlans:
          (json['tomorrowPlans'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      aiSummary: json['aiSummary'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$ReviewEntryImplToJson(_$ReviewEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'mood': instance.mood,
      'highlights': instance.highlights,
      'improvements': instance.improvements,
      'tomorrowPlans': instance.tomorrowPlans,
      'aiSummary': instance.aiSummary,
      'note': instance.note,
    };
