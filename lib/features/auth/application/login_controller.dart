import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/api_provider.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../diet/application/diet_providers.dart';
import '../../moments/application/moments_provider.dart';
import '../../profile/application/user_profile_provider.dart';
import '../../review/application/review_providers.dart';
import '../../sleep/application/sleep_providers.dart';
import '../../sports/application/sports_providers.dart';
import '../../work/application/work_providers.dart';

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.rememberPassword = false,
    this.errorMessage,
    this.savedUsername,
    this.savedPassword,
    this.hasRestoredCredentials = false,
  });

  final bool isLoading;
  final bool rememberPassword;
  final String? errorMessage;
  final String? savedUsername;
  final String? savedPassword;
  final bool hasRestoredCredentials;

  static const _unset = Object();

  LoginState copyWith({
    bool? isLoading,
    bool? rememberPassword,
    Object? errorMessage = _unset,
    Object? savedUsername = _unset,
    Object? savedPassword = _unset,
    bool? hasRestoredCredentials,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      rememberPassword: rememberPassword ?? this.rememberPassword,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      savedUsername: identical(savedUsername, _unset)
          ? this.savedUsername
          : savedUsername as String?,
      savedPassword: identical(savedPassword, _unset)
          ? this.savedPassword
          : savedPassword as String?,
      hasRestoredCredentials:
          hasRestoredCredentials ?? this.hasRestoredCredentials,
    );
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    final prefsService = ref.watch(preferencesServiceProvider);
    final shouldRemember = prefsService.shouldRememberPassword;
    final username = shouldRemember ? prefsService.savedUsername : null;
    final password = shouldRemember ? prefsService.savedPassword : null;

    return LoginState(
      rememberPassword: shouldRemember,
      savedUsername: username,
      savedPassword: password,
      hasRestoredCredentials: true,
    );
  }

  void setRememberPassword(bool value) {
    state = state.copyWith(rememberPassword: value);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  Future<bool> submit({
    required String username,
    required String password,
  }) async {
    if (state.isLoading) {
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    final api = ref.read(apiClientProvider);
    final prefsService = ref.read(preferencesServiceProvider);

    try {
      await api.login(username, password);
      await prefsService.saveCredentials(
        username: username,
        password: password,
        remember: state.rememberPassword,
      );

      _refreshFeatureProviders();

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        savedUsername: state.rememberPassword ? username : null,
        savedPassword: state.rememberPassword ? password : null,
        hasRestoredCredentials: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return false;
    }
  }

  void _refreshFeatureProviders() {
    ref.invalidate(authStateProvider);
    ref.invalidate(currentUsernameProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(reviewEntriesProvider);
    ref.invalidate(workoutListProvider);
    ref.invalidate(dietRecordsProvider);
    ref.invalidate(sleepRecordsProvider);
    ref.invalidate(focusSessionsProvider);
    ref.invalidate(momentsProvider);
  }
}
