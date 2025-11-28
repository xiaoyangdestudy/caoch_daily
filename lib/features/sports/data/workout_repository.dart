import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/workout_record.dart';

class WorkoutRepository {
  WorkoutRepository(this._store, this._api);

  final LocalStore _store;
  final ApiClient _api;

  static const String _storageKeyPrefix = 'workout_records';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    return _storageKeyPrefix;
  }

  Future<List<WorkoutRecord>> getAll() async {
    final storageKey = await _getStorageKey();
    final records = _store.readList(storageKey, WorkoutRecord.fromJson);
    records.sort((a, b) => b.startTime.compareTo(a.startTime));
    return records;
  }

  Future<void> add(WorkoutRecord record) async {
    final storageKey = await _getStorageKey();
    final records = await getAll();
    records.removeWhere((element) => element.id == record.id);
    records.insert(0, record);

    await _store.writeList(storageKey, records, (record) => record.toJson());
  }

  Future<void> delete(String id) async {
    final storageKey = await _getStorageKey();
    final records = await getAll();
    records.removeWhere((e) => e.id == id);

    await _store.writeList(storageKey, records, (record) => record.toJson());
  }
}
