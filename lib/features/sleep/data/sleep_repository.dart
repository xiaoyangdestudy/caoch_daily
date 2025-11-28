import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/sleep_record.dart';

class SleepRepository {
  SleepRepository(this._store, this._api, this._prefs);

  final LocalStore _store;
  final ApiClient _api;
  final SharedPreferences _prefs;

  static const _storageKeyPrefix = 'sleep_records';
  static const String _cacheKey = 'sleep_records_cache';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    return _storageKeyPrefix;
  }

  /// 获取所有睡眠记录（优先从服务器获取）
  Future<List<SleepRecord>> fetchAll() async {
    try {
      // 尝试从服务器获取
      final sleepList = await _api.getSleep();
      final sleep = sleepList
          .map((json) => SleepRecord.fromJson(json))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // 缓存到本地
      await _saveToLocal(sleep);
      return sleep;
    } catch (e) {
      // 如果服务器请求失败，从本地缓存读取
      return await _loadFromLocal();
    }
  }

  /// 保存睡眠记录（同步到服务器）
  Future<void> save(SleepRecord record) async {
    try {
      // 先创建到服务器
      await _api.createSleep(record.toJson());
    } catch (e) {
      // 如果服务器请求失败，仍然保存到本地
      print('Failed to sync sleep to server: $e');
    }

    // 保存到本地缓存
    final records = await _loadFromLocal();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      records[index] = record;
    } else {
      records.insert(0, record);
    }
    await _saveToLocal(records);
  }

  /// 删除睡眠记录（同步到服务器）
  Future<void> delete(String id) async {
    try {
      // 先从服务器删除
      await _api.deleteSleep(id);
    } catch (e) {
      // 如果服务器请求失败，仍然删除本地数据
      print('Failed to delete sleep from server: $e');
    }

    // 更新本地缓存
    final records = await _loadFromLocal();
    records.removeWhere((record) => record.id == id);
    await _saveToLocal(records);
  }

  /// 同步本地数据到服务器（批量上传）
  Future<void> syncToServer() async {
    try {
      final localRecords = await _loadFromLocal();
      if (localRecords.isEmpty) return;

      final jsonList = localRecords.map((r) => r.toJson()).toList();
      await _api.batchCreateSleep(jsonList);
    } catch (e) {
      print('Failed to batch sync sleep: $e');
      rethrow;
    }
  }

  // ==================== 本地缓存相关 ====================

  /// 从本地加载睡眠记录
  Future<List<SleepRecord>> _loadFromLocal() async {
    try {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => SleepRecord.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  /// 保存到本地
  Future<void> _saveToLocal(List<SleepRecord> records) async {
    try {
      final jsonList = records.map((r) => r.toJson()).toList();
      await _prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      // 忽略本地保存错误
    }
  }
}
