import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/focus_session.dart';

class FocusRepository {
  FocusRepository(this._store, this._api, this._prefs);

  final LocalStore _store;
  final ApiClient _api;
  final SharedPreferences _prefs;

  static const _storageKeyPrefix = 'focus_sessions';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    return _storageKeyPrefix;
  }

  /// 获取所有专注记录（优先从服务器获取）
  Future<List<FocusSession>> fetchAll() async {
    try {
      // 尝试从服务器获取
      final focusList = await _api.getFocus();
      final focus = focusList
          .map((json) => FocusSession.fromJson(json))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));

      // 缓存到本地
      await _saveToLocal(focus);
      return focus;
    } catch (e) {
      // 如果服务器请求失败，从本地缓存读取
      return await _loadFromLocal();
    }
  }

  /// 保存专注记录（同步到服务器）
  Future<void> save(FocusSession session) async {
    try {
      // 先创建到服务器
      await _api.createFocus(session.toJson());
    } catch (e) {
      // 如果服务器请求失败，仍然保存到本地
      print('Failed to sync focus to server: $e');
    }

    // 保存到本地缓存
    final sessions = await _loadFromLocal();
    final index = sessions.indexWhere((element) => element.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.insert(0, session);
    }
    await _saveToLocal(sessions);
  }

  /// 删除专注记录（同步到服务器）
  Future<void> delete(String id) async {
    try {
      // 先从服务器删除
      await _api.deleteFocus(id);
    } catch (e) {
      // 如果服务器请求失败，仍然删除本地数据
      print('Failed to delete focus from server: $e');
    }

    // 更新本地缓存
    final sessions = await _loadFromLocal();
    sessions.removeWhere((element) => element.id == id);
    await _saveToLocal(sessions);
  }

  /// 同步本地数据到服务器（批量上传）
  Future<void> syncToServer() async {
    try {
      final localSessions = await _loadFromLocal();
      if (localSessions.isEmpty) return;

      final jsonList = localSessions.map((r) => r.toJson()).toList();
      await _api.batchCreateFocus(jsonList);
    } catch (e) {
      print('Failed to batch sync focus: $e');
      rethrow;
    }
  }

  // ==================== 本地缓存相关 ====================

  /// 从本地加载专注记录
  Future<List<FocusSession>> _loadFromLocal() async {
    try {
      final storageKey = await _getStorageKey();
      final jsonString = _prefs.getString(storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => FocusSession.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      return [];
    }
  }

  /// 保存到本地
  Future<void> _saveToLocal(List<FocusSession> sessions) async {
    try {
      final storageKey = await _getStorageKey();
      final jsonList = sessions.map((r) => r.toJson()).toList();
      await _prefs.setString(storageKey, jsonEncode(jsonList));
    } catch (e) {
      // 忽略本地保存错误
    }
  }
}
