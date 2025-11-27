import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sports/application/sports_providers.dart' as sports;
import '../../../sports/domain/workout_record.dart';

enum StatsPeriod { week, month }

class StatsState {
  final StatsPeriod period;
  final DateTime focusedDate;
  final List<WorkoutRecord> allRecords;
  final bool isLoading;

  // Cached computed values
  final List<WorkoutRecord> filteredRecords;
  final int totalWorkouts;
  final int totalDurationMinutes;
  final int totalCalories;
  final Map<int, int> dailyDuration;

  const StatsState({
    this.period = StatsPeriod.week,
    required this.focusedDate,
    this.allRecords = const [],
    this.isLoading = false,
    this.filteredRecords = const [],
    this.totalWorkouts = 0,
    this.totalDurationMinutes = 0,
    this.totalCalories = 0,
    this.dailyDuration = const {},
  });

  StatsState copyWith({
    StatsPeriod? period,
    DateTime? focusedDate,
    List<WorkoutRecord>? allRecords,
    bool? isLoading,
  }) {
    // Recompute cached values when dependencies change
    final newPeriod = period ?? this.period;
    final newFocusedDate = focusedDate ?? this.focusedDate;
    final newAllRecords = allRecords ?? this.allRecords;

    final computed = _computeStats(
      period: newPeriod,
      focusedDate: newFocusedDate,
      allRecords: newAllRecords,
    );

    return StatsState(
      period: newPeriod,
      focusedDate: newFocusedDate,
      allRecords: newAllRecords,
      isLoading: isLoading ?? this.isLoading,
      filteredRecords: computed.filteredRecords,
      totalWorkouts: computed.totalWorkouts,
      totalDurationMinutes: computed.totalDurationMinutes,
      totalCalories: computed.totalCalories,
      dailyDuration: computed.dailyDuration,
    );
  }

  static _ComputedStats _computeStats({
    required StatsPeriod period,
    required DateTime focusedDate,
    required List<WorkoutRecord> allRecords,
  }) {
    final start = _getStartDate(period, focusedDate);
    final end = _getEndDate(period, focusedDate);

    final filtered = allRecords.where((record) {
      return record.startTime.isAfter(start) && record.startTime.isBefore(end);
    }).toList();

    final totalWorkouts = filtered.length;
    final totalDurationMinutes = filtered.fold<int>(
      0,
      (sum, record) => sum + record.durationMinutes,
    );
    final totalCalories = filtered.fold<int>(
      0,
      (sum, record) => sum + record.caloriesKcal,
    );

    final dailyDurationMap = <int, int>{};
    for (var record in filtered) {
      final day = period == StatsPeriod.week
          ? record.startTime.weekday
          : record.startTime.day;
      dailyDurationMap[day] = (dailyDurationMap[day] ?? 0) + record.durationMinutes;
    }

    return _ComputedStats(
      filteredRecords: filtered,
      totalWorkouts: totalWorkouts,
      totalDurationMinutes: totalDurationMinutes,
      totalCalories: totalCalories,
      dailyDuration: dailyDurationMap,
    );
  }

  static DateTime _getStartDate(StatsPeriod period, DateTime focusedDate) {
    if (period == StatsPeriod.week) {
      return focusedDate
          .subtract(Duration(days: focusedDate.weekday - 1))
          .copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          );
    } else {
      return DateTime(focusedDate.year, focusedDate.month, 1);
    }
  }

  static DateTime _getEndDate(StatsPeriod period, DateTime focusedDate) {
    final start = _getStartDate(period, focusedDate);
    if (period == StatsPeriod.week) {
      return start.add(const Duration(days: 7));
    } else {
      return DateTime(start.year, start.month + 1, 1);
    }
  }
}

class _ComputedStats {
  final List<WorkoutRecord> filteredRecords;
  final int totalWorkouts;
  final int totalDurationMinutes;
  final int totalCalories;
  final Map<int, int> dailyDuration;

  const _ComputedStats({
    required this.filteredRecords,
    required this.totalWorkouts,
    required this.totalDurationMinutes,
    required this.totalCalories,
    required this.dailyDuration,
  });
}

class StatsNotifier extends Notifier<StatsState> {
  @override
  StatsState build() {
    // Mark as keepAlive to prevent rebuilding when switching tabs
    ref.keepAlive();

    // Load data only once when first initialized
    Future.microtask(() => _loadData());

    return StatsState(focusedDate: DateTime.now());
  }

  Future<void> _loadData() async {
    // Prevent reloading if already loaded or loading
    if (state.allRecords.isNotEmpty || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(sports.workoutRepositoryProvider);
      final records = await repository.getAll();
      state = state.copyWith(allRecords: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error if needed
    }
  }

  void setPeriod(StatsPeriod period) {
    state = state.copyWith(period: period);
  }

  void previousPeriod() {
    if (state.period == StatsPeriod.week) {
      state = state.copyWith(
        focusedDate: state.focusedDate.subtract(const Duration(days: 7)),
      );
    } else {
      state = state.copyWith(
        focusedDate: DateTime(
          state.focusedDate.year,
          state.focusedDate.month - 1,
          state.focusedDate.day,
        ),
      );
    }
  }

  void nextPeriod() {
    if (state.period == StatsPeriod.week) {
      state = state.copyWith(
        focusedDate: state.focusedDate.add(const Duration(days: 7)),
      );
    } else {
      state = state.copyWith(
        focusedDate: DateTime(
          state.focusedDate.year,
          state.focusedDate.month + 1,
          state.focusedDate.day,
        ),
      );
    }
  }
}

final statsProvider = NotifierProvider<StatsNotifier, StatsState>(
  StatsNotifier.new,
);
