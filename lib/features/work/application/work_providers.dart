import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/providers/preferences_provider.dart';
import '../../../shared/providers/api_provider.dart';
import '../data/focus_repository.dart';
import '../domain/focus_session.dart';

final focusRepositoryProvider = Provider((ref) {
  final store = ref.watch(localStoreProvider);
  final api = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return FocusRepository(store, api, prefs);
});

final focusSessionsProvider =
    AsyncNotifierProvider<FocusSessionsNotifier, List<FocusSession>>(
      FocusSessionsNotifier.new,
    );

class FocusSessionsNotifier extends AsyncNotifier<List<FocusSession>> {
  late final FocusRepository _repository;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<FocusSession>> build() async {
    _repository = ref.watch(focusRepositoryProvider);
    return _repository.fetchAll();
  }

  Future<void> logSession({
    required DateTime start,
    required DateTime end,
    required int targetMinutes,
    String? taskName,
    bool completed = true,
  }) async {
    final session = FocusSession(
      id: _uuid.v4(),
      startTime: start,
      endTime: end,
      targetMinutes: targetMinutes,
      taskName: taskName,
      completed: completed,
    );
    await _repository.save(session);
    state = AsyncValue.data(await _repository.fetchAll());
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = AsyncValue.data(await _repository.fetchAll());
  }
}
