import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/workout_repository.dart';
import '../domain/workout_record.dart';

final workoutRepositoryProvider = Provider((ref) => WorkoutRepository());

final workoutListProvider = AsyncNotifierProvider<WorkoutListNotifier, List<WorkoutRecord>>(() {
  return WorkoutListNotifier();
});

class WorkoutListNotifier extends AsyncNotifier<List<WorkoutRecord>> {
  late final WorkoutRepository _repository;

  @override
  Future<List<WorkoutRecord>> build() async {
    _repository = ref.read(workoutRepositoryProvider);
    return _repository.getAll();
  }

  Future<void> addRecord(WorkoutRecord record) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.add(record);
      return _repository.getAll();
    });
  }
  
  Future<void> deleteRecord(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      return _repository.getAll();
    });
  }
}

final weeklyStatsProvider = Provider.autoDispose((ref) {
  final recordsAsync = ref.watch(workoutListProvider);
  
  return recordsAsync.when(
    data: (records) {
      final now = DateTime.now();
      // Find start of week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final weeklyRecords = records.where((r) {
        return r.startTime.isAfter(startOfWeek) && r.startTime.isBefore(endOfWeek);
      }).toList();

      double totalDistance = 0;
      int totalCalories = 0;
      int totalDuration = 0;

      for (var r in weeklyRecords) {
        totalDistance += r.distanceKm;
        totalCalories += r.caloriesKcal;
        totalDuration += r.durationMinutes;
      }

      return {
        'count': weeklyRecords.length,
        'distance': totalDistance,
        'calories': totalCalories,
        'duration': totalDuration / 60.0, // hours
      };
    },
    loading: () => {'count': 0, 'distance': 0.0, 'calories': 0, 'duration': 0.0},
    error: (_, __) => {'count': 0, 'distance': 0.0, 'calories': 0, 'duration': 0.0},
  );
});
