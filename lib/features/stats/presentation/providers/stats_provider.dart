import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sports/data/workout_repository.dart';
import '../../../sports/domain/workout_record.dart';

enum StatsPeriod { week, month }

class StatsState {
  final StatsPeriod period;
  final DateTime focusedDate;
  final List<WorkoutRecord> allRecords;
  final bool isLoading;

  const StatsState({
    this.period = StatsPeriod.week,
    required this.focusedDate,
    this.allRecords = const [],
    this.isLoading = false,
  });

  StatsState copyWith({
    StatsPeriod? period,
    DateTime? focusedDate,
    List<WorkoutRecord>? allRecords,
    bool? isLoading,
  }) {
    return StatsState(
      period: period ?? this.period,
      focusedDate: focusedDate ?? this.focusedDate,
      allRecords: allRecords ?? this.allRecords,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Get records filtered by the current period and focused date
  List<WorkoutRecord> get filteredRecords {
    final start = _getStartDate();
    final end = _getEndDate();
    return allRecords.where((record) {
      return record.startTime.isAfter(start) && record.startTime.isBefore(end);
    }).toList();
  }

  DateTime _getStartDate() {
    final now = focusedDate;
    if (period == StatsPeriod.week) {
      // Start of week (Monday)
      return now.subtract(Duration(days: now.weekday - 1)).copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );
    } else {
      // Start of month
      return DateTime(now.year, now.month, 1);
    }
  }

  DateTime _getEndDate() {
    final start = _getStartDate();
    if (period == StatsPeriod.week) {
      return start.add(const Duration(days: 7));
    } else {
      return DateTime(start.year, start.month + 1, 1);
    }
  }

  // Summary getters
  int get totalWorkouts => filteredRecords.length;
  
  int get totalDurationMinutes => filteredRecords.fold(
        0,
        (sum, record) => sum + record.durationMinutes,
      );
      
  int get totalCalories => filteredRecords.fold(
        0,
        (sum, record) => sum + record.caloriesKcal,
      );

  // Chart data helpers
  Map<int, int> get dailyDuration {
    final map = <int, int>{};
    final records = filteredRecords;
    
    for (var record in records) {
      final day = period == StatsPeriod.week 
          ? record.startTime.weekday 
          : record.startTime.day;
      map[day] = (map[day] ?? 0) + record.durationMinutes;
    }
    return map;
  }
}

class StatsNotifier extends Notifier<StatsState> {
  @override
  StatsState build() {
    _loadData();
    return StatsState(focusedDate: DateTime.now());
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(workoutRepositoryProvider);
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

final workoutRepositoryProvider = Provider((ref) => WorkoutRepository());

final statsProvider = NotifierProvider<StatsNotifier, StatsState>(
  StatsNotifier.new,
);
