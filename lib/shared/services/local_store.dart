import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 的 JSON 封装，负责序列化列表结构
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  List<T> readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> writeList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final encoded = jsonEncode(
      items.map((item) => toJson(item)).toList(growable: false),
    );
    await _prefs.setString(key, encoded);
  }

  Future<void> remove(String key) => _prefs.remove(key);
}
