// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReadingRecordImpl _$$ReadingRecordImplFromJson(Map<String, dynamic> json) =>
    _$ReadingRecordImpl(
      id: json['id'] as String,
      bookTitle: json['bookTitle'] as String,
      bookAuthor: json['bookAuthor'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      pagesRead: (json['pagesRead'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      excerpt: json['excerpt'] as String?,
      aiSummary: json['aiSummary'] as String?,
    );

Map<String, dynamic> _$$ReadingRecordImplToJson(_$ReadingRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookTitle': instance.bookTitle,
      'bookAuthor': instance.bookAuthor,
      'startTime': instance.startTime.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'pagesRead': instance.pagesRead,
      'notes': instance.notes,
      'excerpt': instance.excerpt,
      'aiSummary': instance.aiSummary,
    };
