import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_session.freezed.dart';
part 'focus_session.g.dart';

@freezed
class FocusSession with _$FocusSession {
  const FocusSession._();

  const factory FocusSession({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required int targetMinutes,
    String? taskName,
    @Default(false) bool completed,
  }) = _FocusSession;

  factory FocusSession.fromJson(Map<String, dynamic> json) =>
      _$FocusSessionFromJson(json);

  Duration get actualDuration => endTime.difference(startTime);
}
