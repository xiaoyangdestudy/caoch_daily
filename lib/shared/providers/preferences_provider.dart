import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/preferences_service.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.when(
    data: (sharedPrefs) => PreferencesService(sharedPrefs),
    loading: () => throw Exception('SharedPreferences not initialized'),
    error: (error, stack) => throw error,
  );
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return prefsService.hasCompletedOnboarding;
});
