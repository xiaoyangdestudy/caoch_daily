import '../../../shared/services/local_store.dart';
import '../domain/focus_session.dart';

class FocusRepository {
  FocusRepository(this._store);

  final LocalStore _store;

  static const _storageKey = 'focus_sessions';

  Future<List<FocusSession>> fetchAll() async {
    final sessions = _store.readList(_storageKey, FocusSession.fromJson);
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  Future<void> save(FocusSession session) async {
    final sessions = await fetchAll();
    final index = sessions.indexWhere((element) => element.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.insert(0, session);
    }
    await _store.writeList(
      _storageKey,
      sessions,
      (session) => session.toJson(),
    );
  }

  Future<void> delete(String id) async {
    final sessions = await fetchAll();
    sessions.removeWhere((element) => element.id == id);
    await _store.writeList(
      _storageKey,
      sessions,
      (session) => session.toJson(),
    );
  }
}
