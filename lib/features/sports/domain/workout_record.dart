import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_record.freezed.dart';
part 'workout_record.g.dart';

enum WorkoutType {
  run('跑步', 'assets/icons/run.png'),
  cycle('骑行', 'assets/icons/cycle.png'),
  swim('游泳', 'assets/icons/swim.png'),
  gym('健身', 'assets/icons/gym.png'),
  walk('步行', 'assets/icons/walk.png'),
  other('其他', 'assets/icons/other.png');

  final String label;
  final String iconPath;
  const WorkoutType(this.label, this.iconPath);
}

@freezed
class WorkoutRecord with _$WorkoutRecord {
  const factory WorkoutRecord({
    required String id,
    required WorkoutType type,
    required DateTime startTime,
    required int durationMinutes,
    required double distanceKm,
    required int caloriesKcal,
    String? notes,
  }) = _WorkoutRecord;

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRecordFromJson(json);
}
