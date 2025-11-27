import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/preferences_provider.dart';
import '../data/moments_repository.dart';
import '../domain/moment_model.dart';

final momentsRepositoryProvider = Provider<MomentsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MomentsRepository(prefs);
});

final momentsProvider =
    AsyncNotifierProvider<MomentsNotifier, List<Moment>>(MomentsNotifier.new);

class MomentsNotifier extends AsyncNotifier<List<Moment>> {
  @override
  Future<List<Moment>> build() async {
    // Keep alive to prevent reloading when switching tabs
    ref.keepAlive();
    return _loadMoments();
  }

  Future<List<Moment>> _loadMoments() async {
    final repository = ref.read(momentsRepositoryProvider);
    return repository.getAll();
  }

  Future<void> createMoment(CreateMomentInput input) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(momentsRepositoryProvider);
      await repository.create(input);
      return _loadMoments();
    });
  }

  Future<void> deleteMoment(String id) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(momentsRepositoryProvider);
      await repository.delete(id);
      return _loadMoments();
    });
  }

  Future<void> toggleLike(String id) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(momentsRepositoryProvider);
      await repository.toggleLike(id);
      return _loadMoments();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadMoments);
  }
}
