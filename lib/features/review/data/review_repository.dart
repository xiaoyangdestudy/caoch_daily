import '../../../shared/services/local_store.dart';
import '../domain/review_record.dart';

class ReviewRepository {
  ReviewRepository(this._store);

  final LocalStore _store;

  static const _storageKey = 'review_entries';

  Future<List<ReviewEntry>> fetchAll() async {
    final entries = _store.readList(_storageKey, ReviewEntry.fromJson);
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> save(ReviewEntry entry) async {
    final entries = await fetchAll();
    final index = entries.indexWhere((element) => element.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.insert(0, entry);
    }
    await _store.writeList(_storageKey, entries, (entry) => entry.toJson());
  }

  Future<void> delete(String id) async {
    final entries = await fetchAll();
    entries.removeWhere((element) => element.id == id);
    await _store.writeList(_storageKey, entries, (entry) => entry.toJson());
  }
}
