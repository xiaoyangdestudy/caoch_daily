import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_record.freezed.dart';
part 'review_record.g.dart';

@freezed
class ReviewEntry with _$ReviewEntry {
  const ReviewEntry._();

  const factory ReviewEntry({
    required String id,
    required DateTime date,
    required String mood,
    @Default([]) List<String> highlights,
    @Default([]) List<String> improvements,
    @Default([]) List<String> tomorrowPlans,
    String? aiSummary,
    String? note,
  }) = _ReviewEntry;

  factory ReviewEntry.fromJson(Map<String, dynamic> json) =>
      _$ReviewEntryFromJson(json);

  bool get isToday {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }
}
