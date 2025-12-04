import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/api_client.dart';
import '../domain/reading_record.dart';

class ReadingRepository {
  ReadingRepository(this._api, this._prefs);

  final ApiClient _api;
  final SharedPreferences _prefs;

  static const String _storageKeyPrefix = 'reading_records';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    return _storageKeyPrefix;
  }

  /// 获取所有阅读记录（优先从服务器获取）
  Future<List<ReadingRecord>> getAll() async {
    try {
      // 尝试从服务器获取
      final readingList = await _api.getReading();
      final reading = readingList
          .map((json) => ReadingRecord.fromJson(json))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));

      // 缓存到本地
      await _saveToLocal(reading);
      return reading;
    } catch (e) {
      // 如果服务器请求失败，从本地缓存读取
      return await _loadFromLocal();
    }
  }

  /// 添加阅读记录（同步到服务器）
  Future<void> add(ReadingRecord record) async {
    try {
      // 先创建到服务器
      await _api.createReading(record.toJson());
    } catch (e) {
      // 如果服务器请求失败，仍然保存到本地
      debugPrint('Failed to sync reading to server: $e');
    }

    // 保存到本地缓存
    final records = await _loadFromLocal();
    records.removeWhere((element) => element.id == record.id);
    records.insert(0, record);
    await _saveToLocal(records);
  }

  /// 删除阅读记录（同步到服务器）
  Future<void> delete(String id) async {
    try {
      // 先从服务器删除
      await _api.deleteReading(id);
    } catch (e) {
      // 如果服务器请求失败，仍然删除本地数据
      debugPrint('Failed to delete reading from server: $e');
    }

    // 更新本地缓存
    final records = await _loadFromLocal();
    records.removeWhere((e) => e.id == id);
    await _saveToLocal(records);
  }

  /// 同步本地数据到服务器（批量上传）
  Future<void> syncToServer() async {
    try {
      final localRecords = await _loadFromLocal();
      if (localRecords.isEmpty) return;

      final jsonList = localRecords.map((r) => r.toJson()).toList();
      await _api.batchCreateReading(jsonList);
    } catch (e) {
      debugPrint('Failed to batch sync reading: $e');
      rethrow;
    }
  }

  // ==================== 本地缓存相关 ====================

  /// 从本地加载阅读记录
  Future<List<ReadingRecord>> _loadFromLocal() async {
    try {
      final storageKey = await _getStorageKey();
      final jsonString = _prefs.getString(storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => ReadingRecord.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      return [];
    }
  }

  /// 保存到本地
  Future<void> _saveToLocal(List<ReadingRecord> records) async {
    try {
      final storageKey = await _getStorageKey();
      final jsonList = records.map((r) => r.toJson()).toList();
      await _prefs.setString(storageKey, jsonEncode(jsonList));
    } catch (e) {
      // 忽略本地保存错误
    }
  }
}
