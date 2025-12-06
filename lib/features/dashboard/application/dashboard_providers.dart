import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../diet/application/diet_providers.dart';
import '../../diet/domain/diet_models.dart';
import '../../profile/application/profile_provider.dart';
import '../../profile/application/user_profile_provider.dart';
import '../../sleep/application/sleep_providers.dart';
import '../../sleep/domain/sleep_record.dart';
import '../../sports/application/sports_providers.dart';
import '../../sports/domain/workout_record.dart';
import '../../work/application/work_providers.dart';
import '../../work/domain/focus_session.dart';
import '../domain/dashboard_overview.dart';
import '../domain/record_type.dart';

const _exerciseTargetMinutes = 45;
const _dietTargetCalories = 1800;
const _sleepTargetHours = 8.0;
const _workTargetHours = 4.0;

final dashboardOverviewProvider = Provider<DashboardOverviewState>((ref) {
  final workouts = ref.watch(workoutListProvider);
  final meals = ref.watch(dietRecordsProvider);
  final sleeps = ref.watch(sleepRecordsProvider);
  final sessions = ref.watch(focusSessionsProvider);
  final userProfile = ref.watch(userProfileProvider);
  final profile = ref.watch(profileProvider);

  final asyncValues = [workouts, meals, sleeps, sessions, userProfile];
  if (asyncValues.any((value) => value.isLoading)) {
    return const DashboardOverviewState.loading();
  }

  for (final value in asyncValues) {
    if (value.hasError) {
      return DashboardOverviewState.error(value.error ?? 'unknown');
    }
  }

  // 优先使用服务器的用户资料，如果没有则使用本地默认值
  final nickname = userProfile.value?.nickname ??
                   userProfile.value?.username ??
                   profile.overview.nickname;

  final overview = _buildOverview(
    nickname: nickname,
    workouts: workouts.value ?? const [],
    meals: meals.value ?? const [],
    sleeps: sleeps.value ?? const [],
    sessions: sessions.value ?? const [],
  );

  return DashboardOverviewState.data(overview);
});

DashboardOverview _buildOverview({
  required String nickname,
  required List<WorkoutRecord> workouts,
  required List<MealRecord> meals,
  required List<SleepRecord> sleeps,
  required List<FocusSession> sessions,
}) {
  final today = DateTime.now();
  final exerciseMinutes = workouts
      .where((record) => _isSameDay(record.startTime, today))
      .fold<int>(0, (sum, record) => sum + record.durationMinutes);
  final dietCalories = meals
      .where((record) => _isSameDay(record.timestamp, today))
      .fold<int>(0, (sum, record) => sum + record.totalCalories);
  final sleepRecord = _findTodaySleep(sleeps, today);
  final sleepHours = sleepRecord == null
      ? 0.0
      : sleepRecord.duration.inMinutes / 60.0;
  final workHours = sessions
      .where((session) => _isSameDay(session.startTime, today))
      .fold<double>(
        0,
        (sum, session) => sum + session.actualDuration.inMinutes / 60.0,
      );

  final cards = [
    DashboardCardStat(
      type: RecordType.exercise,
      value: exerciseMinutes.toString(),
      subValue: 'min',
      progress: _progress(exerciseMinutes / _exerciseTargetMinutes),
      rawValue: exerciseMinutes.toDouble(),
    ),
    DashboardCardStat(
      type: RecordType.diet,
      value: _formatCalories(dietCalories),
      subValue: 'kcal',
      progress: _progress(dietCalories / _dietTargetCalories),
      rawValue: dietCalories.toDouble(),
    ),
    DashboardCardStat(
      type: RecordType.sleep,
      value: _formatHours(sleepHours),
      subValue: 'hr',
      progress: null,
      rawValue: sleepHours,
    ),
    DashboardCardStat(
      type: RecordType.work,
      value: _formatHours(workHours),
      subValue: 'hr',
      progress: _progress(workHours / _workTargetHours),
      rawValue: workHours,
    ),
  ];

  final summary = _buildSummary(
    exerciseMinutes: exerciseMinutes,
    calories: dietCalories,
    sleepHours: sleepHours,
    workHours: workHours,
  );

  final vitality = _calculateVitality(
    exerciseMinutes: exerciseMinutes,
    calories: dietCalories,
    sleepHours: sleepHours,
    workHours: workHours,
  );

  return DashboardOverview(
    nickname: nickname,
    summary: summary,
    vitalityScore: vitality,
    cards: cards,
  );
}

SleepRecord? _findTodaySleep(List<SleepRecord> records, DateTime today) {
  for (final record in records) {
    if (_isSameDay(record.date, today)) {
      return record;
    }
  }
  return null;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

double _progress(double value) {
  if (value.isInfinite || value.isNaN) {
    return 0;
  }
  if (value < 0) return 0;
  if (value > 1) return 1;
  return value;
}

String _formatCalories(int calories) {
  if (calories >= 1000) {
    final kilo = calories / 1000;
    final decimals = kilo >= 10 ? 0 : 1;
    return '${kilo.toStringAsFixed(decimals)}k';
  }
  return calories.toString();
}

String _formatHours(double hours) {
  if (hours == 0) {
    return '0';
  }
  if (hours >= 10) {
    return hours.toStringAsFixed(0);
  }
  final hasFraction = (hours - hours.truncateToDouble()).abs() >= 0.05;
  return hours.toStringAsFixed(hasFraction ? 1 : 0);
}

int _calculateVitality({
  required int exerciseMinutes,
  required int calories,
  required double sleepHours,
  required double workHours,
}) {
  final exerciseScore = (exerciseMinutes / _exerciseTargetMinutes)
      .clamp(0, 1)
      .toDouble();
  final calorieDiff = (calories - _dietTargetCalories).abs();
  final dietScore = (1 - calorieDiff / _dietTargetCalories)
      .clamp(0, 1)
      .toDouble();
  final sleepScore = (sleepHours / _sleepTargetHours).clamp(0, 1).toDouble();
  final workScore = (workHours / _workTargetHours).clamp(0, 1).toDouble();

  final average = (exerciseScore + dietScore + sleepScore + workScore) / 4;
  return (average * 100).round();
}

String _buildSummary({
  required int exerciseMinutes,
  required int calories,
  required double sleepHours,
  required double workHours,
}) {
  final total =
      exerciseMinutes + calories + sleepHours.round() + workHours.round();
  if (total == 0) {
    return '今天还没有任何记录，先完成一次打卡吧。';
  }
  if (sleepHours < 6) {
    return '睡眠有点少，今晚尽量早点休息。';
  }
  if (exerciseMinutes < 30) {
    return '活动量偏低，安排一组简单拉伸。';
  }
  if (calories > _dietTargetCalories + 200) {
    return '摄入略多，下一餐可以换成轻食。';
  }
  if (workHours >= _workTargetHours) {
    return '专注表现很好，记得适当休息喝水。';
  }
  return '状态平稳，保持节奏与好心情。';
}
