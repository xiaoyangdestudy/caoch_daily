import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/diet_models.dart';

class DietRepository {
  DietRepository(this._store, this._api);

  final LocalStore _store;
  final ApiClient _api;

  static const _storageKeyPrefix = 'diet_records';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    return _storageKeyPrefix;
  }

  Future<List<MealRecord>> fetchAll() async {
    final storageKey = await _getStorageKey();
    final records = _store.readList(storageKey, MealRecord.fromJson);
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<void> save(MealRecord record) async {
    final storageKey = await _getStorageKey();
    final records = await fetchAll();
    final index = records.indexWhere((element) => element.id == record.id);
    if (index >= 0) {
      records[index] = record;
    } else {
      records.insert(0, record);
    }
    await _store.writeList(storageKey, records, (item) => item.toJson());
  }

  Future<void> delete(String id) async {
    final storageKey = await _getStorageKey();
    final records = await fetchAll();
    records.removeWhere((element) => element.id == id);
    await _store.writeList(storageKey, records, (item) => item.toJson());
  }

  Future<void> clear() async {
    final storageKey = await _getStorageKey();
    await _store.remove(storageKey);
  }
}
