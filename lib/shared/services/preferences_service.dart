import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyOnboardingCompleted = 'onboarding_completed';
  static const _keyRememberPassword = 'remember_password';
  static const _keySavedUsername = 'saved_username';
  static const _keySavedPassword = 'saved_password';

  bool get hasCompletedOnboarding {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }

  // 记住密码功能
  bool get shouldRememberPassword {
    return _prefs.getBool(_keyRememberPassword) ?? false;
  }

  String? get savedUsername {
    return _prefs.getString(_keySavedUsername);
  }

  String? get savedPassword {
    final encoded = _prefs.getString(_keySavedPassword);
    if (encoded == null) return null;
    try {
      return utf8.decode(base64.decode(encoded));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCredentials({
    required String username,
    required String password,
    required bool remember,
  }) async {
    await _prefs.setBool(_keyRememberPassword, remember);
    if (remember) {
      await _prefs.setString(_keySavedUsername, username);
      // 使用 base64 编码密码（简单混淆，不是真正的加密）
      final encoded = base64.encode(utf8.encode(password));
      await _prefs.setString(_keySavedPassword, encoded);
    } else {
      await clearCredentials();
    }
  }

  Future<void> clearCredentials() async {
    await _prefs.remove(_keySavedUsername);
    await _prefs.remove(_keySavedPassword);
    await _prefs.setBool(_keyRememberPassword, false);
  }
}
