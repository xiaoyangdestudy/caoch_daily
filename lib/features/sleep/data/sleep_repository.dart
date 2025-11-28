import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/sleep_record.dart';

class SleepRepository {
  SleepRepository(this._store, this._api);

  final LocalStore _store;
  final ApiClient _api;

  static const _storageKeyPrefix = 'sleep_records';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    return _storageKeyPrefix;
  }

  Future<List<SleepRecord>> fetchAll() async {
    final storageKey = await _getStorageKey();
    final records = _store.readList(storageKey, SleepRecord.fromJson);
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<void> save(SleepRecord record) async {
    final storageKey = await _getStorageKey();
    final records = await fetchAll();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      records[index] = record;
    } else {
      records.insert(0, record);
    }
    await _store.writeList(storageKey, records, (record) => record.toJson());
  }

  Future<void> delete(String id) async {
    final storageKey = await _getStorageKey();
    final records = await fetchAll();
    records.removeWhere((record) => record.id == id);
    await _store.writeList(storageKey, records, (record) => record.toJson());
  }
}
