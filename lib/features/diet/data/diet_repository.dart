import '../../../shared/services/local_store.dart';
import '../domain/diet_models.dart';

class DietRepository {
  DietRepository(this._store);

  final LocalStore _store;

  static const _storageKey = 'diet_records';

  Future<List<MealRecord>> fetchAll() async {
    final records = _store.readList(_storageKey, MealRecord.fromJson);
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<void> save(MealRecord record) async {
    final records = await fetchAll();
    final index = records.indexWhere((element) => element.id == record.id);
    if (index >= 0) {
      records[index] = record;
    } else {
      records.insert(0, record);
    }
    await _store.writeList(_storageKey, records, (item) => item.toJson());
  }

  Future<void> delete(String id) async {
    final records = await fetchAll();
    records.removeWhere((element) => element.id == id);
    await _store.writeList(_storageKey, records, (item) => item.toJson());
  }

  Future<void> clear() => _store.remove(_storageKey);
}
