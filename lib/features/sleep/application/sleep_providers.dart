import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/providers/preferences_provider.dart';
import '../../../shared/providers/api_provider.dart';
import '../data/sleep_repository.dart';
import '../domain/sleep_record.dart';

final sleepRepositoryProvider = Provider((ref) {
  final store = ref.watch(localStoreProvider);
  final api = ref.watch(apiClientProvider);
  return SleepRepository(store, api);
});

final sleepRecordsProvider =
    AsyncNotifierProvider<SleepRecordsNotifier, List<SleepRecord>>(
      SleepRecordsNotifier.new,
    );

class SleepRecordsNotifier extends AsyncNotifier<List<SleepRecord>> {
  late final SleepRepository _repository;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<SleepRecord>> build() async {
    _repository = ref.watch(sleepRepositoryProvider);
    return _repository.fetchAll();
  }

  Future<void> saveRecord({
    required DateTime date,
    required TimeOfDay bedtime,
    required TimeOfDay wakeTime,
    int? quality,
    String? note,
  }) async {
    final existing = _findRecordForDate(date);
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      bedtime.hour,
      bedtime.minute,
    );
    DateTime end = DateTime(
      date.year,
      date.month,
      date.day,
      wakeTime.hour,
      wakeTime.minute,
    );
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }

    final record = SleepRecord(
      id: existing?.id ?? _uuid.v4(),
      date: DateTime(date.year, date.month, date.day),
      bedtime: start,
      wakeTime: end,
      note: note,
      sleepQuality: quality,
    );

    await _repository.save(record);
    state = AsyncValue.data(await _repository.fetchAll());
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = AsyncValue.data(await _repository.fetchAll());
  }

  SleepRecord? _findRecordForDate(DateTime date) {
    final records = state.value;
    if (records == null) return null;
    for (final record in records) {
      if (_isSameDay(record.date, date)) {
        return record;
      }
    }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
