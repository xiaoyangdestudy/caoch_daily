import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../../shared/providers/api_provider.dart';
import '../data/reading_repository.dart';
import '../domain/reading_record.dart';

final readingRepositoryProvider = Provider((ref) {
  final api = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReadingRepository(api, prefs);
});

final readingListProvider =
    AsyncNotifierProvider<ReadingListNotifier, List<ReadingRecord>>(() {
  return ReadingListNotifier();
});

class ReadingListNotifier extends AsyncNotifier<List<ReadingRecord>> {
  late final ReadingRepository _repository;

  @override
  Future<List<ReadingRecord>> build() async {
    _repository = ref.read(readingRepositoryProvider);
    return _repository.getAll();
  }

  Future<void> addRecord(ReadingRecord record) async {
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

final weeklyReadingStatsProvider = Provider.autoDispose((ref) {
  final recordsAsync = ref.watch(readingListProvider);

  return recordsAsync.when(
    data: (records) {
      final now = DateTime.now();
      // Find start of week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final weeklyRecords = records.where((r) {
        return r.startTime.isAfter(startOfWeek) &&
            r.startTime.isBefore(endOfWeek);
      }).toList();

      int totalDuration = 0;
      int totalPages = 0;

      for (var r in weeklyRecords) {
        totalDuration += r.durationMinutes;
        totalPages += r.pagesRead ?? 0;
      }

      return {
        'count': weeklyRecords.length,
        'duration': totalDuration / 60.0, // hours
        'pages': totalPages,
      };
    },
    loading: () => {
      'count': 0,
      'duration': 0.0,
      'pages': 0,
    },
    error: (_, __) => {
      'count': 0,
      'duration': 0.0,
      'pages': 0,
    },
  );
});

final todayReadingProvider = Provider.autoDispose((ref) {
  final recordsAsync = ref.watch(readingListProvider);

  return recordsAsync.when(
    data: (records) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final todayRecords = records.where((r) {
        return r.startTime.isAfter(today) && r.startTime.isBefore(tomorrow);
      }).toList();

      int totalDuration = 0;
      for (var r in todayRecords) {
        totalDuration += r.durationMinutes;
      }

      return {
        'count': todayRecords.length,
        'duration': totalDuration,
      };
    },
    loading: () => {
      'count': 0,
      'duration': 0,
    },
    error: (_, __) => {
      'count': 0,
      'duration': 0,
    },
  );
});
