import '../../../shared/services/local_store.dart';
import '../domain/sleep_record.dart';

class SleepRepository {
  SleepRepository(this._store);

  final LocalStore _store;

  static const _storageKey = 'sleep_records';

  Future<List<SleepRecord>> fetchAll() async {
    final records = _store.readList(_storageKey, SleepRecord.fromJson);
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<void> save(SleepRecord record) async {
    final records = await fetchAll();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      records[index] = record;
    } else {
      records.insert(0, record);
    }
    await _store.writeList(_storageKey, records, (record) => record.toJson());
  }

  Future<void> delete(String id) async {
    final records = await fetchAll();
    records.removeWhere((record) => record.id == id);
    await _store.writeList(_storageKey, records, (record) => record.toJson());
  }
}
