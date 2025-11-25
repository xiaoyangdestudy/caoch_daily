import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/preferences_service.dart';
import '../services/local_store.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences 需要在 main 中注入');
});

final localStoreProvider = Provider<LocalStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStore(prefs);
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesService(prefs);
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return prefsService.hasCompletedOnboarding;
});
