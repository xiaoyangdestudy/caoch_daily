// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FocusSessionImpl _$$FocusSessionImplFromJson(Map<String, dynamic> json) =>
    _$FocusSessionImpl(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      targetMinutes: (json['targetMinutes'] as num).toInt(),
      taskName: json['taskName'] as String?,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$$FocusSessionImplToJson(_$FocusSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'targetMinutes': instance.targetMinutes,
      'taskName': instance.taskName,
      'completed': instance.completed,
    };
