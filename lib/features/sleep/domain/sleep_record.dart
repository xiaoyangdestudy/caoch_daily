import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_record.freezed.dart';
part 'sleep_record.g.dart';

@freezed
class SleepRecord with _$SleepRecord {
  const SleepRecord._();

  const factory SleepRecord({
    required String id,
    required DateTime date,
    required DateTime bedtime,
    required DateTime wakeTime,
    String? note,
    int? sleepQuality,
  }) = _SleepRecord;

  factory SleepRecord.fromJson(Map<String, dynamic> json) =>
      _$SleepRecordFromJson(json);

  Duration get duration {
    if (wakeTime.isAfter(bedtime)) {
      return wakeTime.difference(bedtime);
    }
    return wakeTime.add(const Duration(days: 1)).difference(bedtime);
  }
}
