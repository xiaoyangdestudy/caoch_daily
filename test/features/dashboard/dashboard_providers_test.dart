import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caoch_daily/features/dashboard/application/dashboard_providers.dart';
import 'package:caoch_daily/features/dashboard/domain/dashboard_overview.dart';
import 'package:caoch_daily/features/dashboard/domain/record_type.dart';
import 'package:caoch_daily/features/diet/application/diet_providers.dart';
import 'package:caoch_daily/features/diet/domain/diet_models.dart';
import 'package:caoch_daily/features/sleep/application/sleep_providers.dart';
import 'package:caoch_daily/features/sleep/domain/sleep_record.dart';
import 'package:caoch_daily/features/sports/application/sports_providers.dart';
import 'package:caoch_daily/features/sports/domain/workout_record.dart';
import 'package:caoch_daily/features/work/application/work_providers.dart';
import 'package:caoch_daily/features/work/domain/focus_session.dart';

void main() {
  test('Dashboard 汇总 provider 能正确聚合当天数据', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9);
    final workouts = [
      WorkoutRecord(
        id: 'w1',
        type: WorkoutType.run,
        startTime: today,
        durationMinutes: 40,
        distanceKm: 5.2,
        caloriesKcal: 320,
      ),
      WorkoutRecord(
        id: 'w2',
        type: WorkoutType.walk,
        startTime: today.subtract(const Duration(days: 1)),
        durationMinutes: 20,
        distanceKm: 2,
        caloriesKcal: 90,
      ),
    ];
    final meals = [
      MealRecord(
        id: 'm1',
        mealType: MealType.lunch,
        timestamp: today,
        items: const [
          FoodItem(
            id: 'f1',
            name: '沙拉',
            calories: 400,
            protein: 20,
            carbs: 12,
            fat: 8,
          ),
          FoodItem(
            id: 'f2',
            name: '鸡胸肉',
            calories: 350,
            protein: 32,
            carbs: 0,
            fat: 5,
          ),
          FoodItem(
            id: 'f3',
            name: '燕麦',
            calories: 250,
            protein: 8,
            carbs: 34,
            fat: 4,
          ),
        ],
      ),
    ];
    final sleeps = [
      SleepRecord(
        id: 's1',
        date: DateTime(now.year, now.month, now.day),
        bedtime: DateTime(now.year, now.month, now.day, 0, 0),
        wakeTime: DateTime(now.year, now.month, now.day, 7, 30),
        sleepQuality: 4,
      ),
    ];
    final sessions = [
      FocusSession(
        id: 'fs1',
        startTime: today.add(const Duration(hours: 1)),
        endTime: today.add(const Duration(hours: 2)),
        targetMinutes: 60,
        taskName: '写周报',
        completed: true,
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        workoutListProvider.overrideWith(() => _FakeWorkoutNotifier(workouts)),
        dietRecordsProvider.overrideWith(() => _FakeDietNotifier(meals)),
        sleepRecordsProvider.overrideWith(() => _FakeSleepNotifier(sleeps)),
        focusSessionsProvider.overrideWith(() => _FakeFocusNotifier(sessions)),
      ],
    );
    addTearDown(container.dispose);

    await _drainSources(container);

    final state = container.read(dashboardOverviewProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    final overview = state.data;
    expect(overview, isNotNull);
    expect(overview!.cards.length, 4);

    DashboardCardStat cardOf(RecordType type) =>
        overview.cards.firstWhere((card) => card.type == type);

    expect(cardOf(RecordType.exercise).value, '40');
    expect(cardOf(RecordType.diet).value, '1.0k');
    expect(cardOf(RecordType.sleep).value, '7.5');
    expect(cardOf(RecordType.work).value, '1');
    expect(overview.summary, contains('状态平稳'));
    expect(overview.vitalityScore, greaterThan(0));
  });

  test('当日无数据时返回默认提示', () async {
    final container = ProviderContainer(
      overrides: [
        workoutListProvider.overrideWith(() => _FakeWorkoutNotifier(const [])),
        dietRecordsProvider.overrideWith(() => _FakeDietNotifier(const [])),
        sleepRecordsProvider.overrideWith(() => _FakeSleepNotifier(const [])),
        focusSessionsProvider.overrideWith(() => _FakeFocusNotifier(const [])),
      ],
    );
    addTearDown(container.dispose);

    await _drainSources(container);

    final state = container.read(dashboardOverviewProvider);
    expect(state.isLoading, isFalse);
    expect(state.data, isNotNull);
    expect(state.data!.summary, contains('还没有任何记录'));
    expect(state.data!.cards.every((card) => card.rawValue == 0), isTrue);
  });
}

Future<void> _drainSources(ProviderContainer container) async {
  await container.read(workoutListProvider.future);
  await container.read(dietRecordsProvider.future);
  await container.read(sleepRecordsProvider.future);
  await container.read(focusSessionsProvider.future);
}

class _FakeWorkoutNotifier extends WorkoutListNotifier {
  _FakeWorkoutNotifier(this._records);

  final List<WorkoutRecord> _records;

  @override
  Future<List<WorkoutRecord>> build() async => _records;
}

class _FakeDietNotifier extends DietRecordsNotifier {
  _FakeDietNotifier(this._records);

  final List<MealRecord> _records;

  @override
  Future<List<MealRecord>> build() async => _records;
}

class _FakeSleepNotifier extends SleepRecordsNotifier {
  _FakeSleepNotifier(this._records);

  final List<SleepRecord> _records;

  @override
  Future<List<SleepRecord>> build() async => _records;
}

class _FakeFocusNotifier extends FocusSessionsNotifier {
  _FakeFocusNotifier(this._sessions);

  final List<FocusSession> _sessions;

  @override
  Future<List<FocusSession>> build() async => _sessions;
}
