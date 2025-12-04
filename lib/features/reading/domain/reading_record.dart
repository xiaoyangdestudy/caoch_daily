import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_record.freezed.dart';
part 'reading_record.g.dart';

@freezed
class ReadingRecord with _$ReadingRecord {
  const factory ReadingRecord({
    required String id,
    required String bookTitle,
    String? bookAuthor,
    required DateTime startTime,
    required int durationMinutes,
    int? pagesRead,
    String? notes,
    String? excerpt,
    String? aiSummary,
  }) = _ReadingRecord;

  factory ReadingRecord.fromJson(Map<String, dynamic> json) =>
      _$ReadingRecordFromJson(json);
}
