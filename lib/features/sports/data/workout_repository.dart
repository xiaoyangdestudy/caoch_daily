import '../../../shared/services/local_store.dart';
import '../domain/workout_record.dart';

class WorkoutRepository {
  WorkoutRepository(this._store);

  final LocalStore _store;

  static const String _storageKey = 'workout_records';

  Future<List<WorkoutRecord>> getAll() async {
    final records = _store.readList(_storageKey, WorkoutRecord.fromJson);
    records.sort((a, b) => b.startTime.compareTo(a.startTime));
    return records;
  }

  Future<void> add(WorkoutRecord record) async {
    final records = await getAll();
    records.removeWhere((element) => element.id == record.id);
    records.insert(0, record);

    await _store.writeList(_storageKey, records, (record) => record.toJson());
  }

  Future<void> delete(String id) async {
    final records = await getAll();
    records.removeWhere((e) => e.id == id);

    await _store.writeList(_storageKey, records, (record) => record.toJson());
  }
}
