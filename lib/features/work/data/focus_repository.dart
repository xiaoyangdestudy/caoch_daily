import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/focus_session.dart';

class FocusRepository {
  FocusRepository(this._store, this._api);

  final LocalStore _store;
  final ApiClient _api;

  static const _storageKeyPrefix = 'focus_sessions';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    return _storageKeyPrefix;
  }

  Future<List<FocusSession>> fetchAll() async {
    final storageKey = await _getStorageKey();
    final sessions = _store.readList(storageKey, FocusSession.fromJson);
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  Future<void> save(FocusSession session) async {
    final storageKey = await _getStorageKey();
    final sessions = await fetchAll();
    final index = sessions.indexWhere((element) => element.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.insert(0, session);
    }
    await _store.writeList(
      storageKey,
      sessions,
      (session) => session.toJson(),
    );
  }

  Future<void> delete(String id) async {
    final storageKey = await _getStorageKey();
    final sessions = await fetchAll();
    sessions.removeWhere((element) => element.id == id);
    await _store.writeList(
      storageKey,
      sessions,
      (session) => session.toJson(),
    );
  }
}
