import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/workout_record.dart';

class WorkoutRepository {
  WorkoutRepository(this._store, this._api, this._prefs);

  final LocalStore _store;
  final ApiClient _api;
  final SharedPreferences _prefs;

  static const String _storageKeyPrefix = 'workout_records';
  static const String _cacheKey = 'workout_records_cache';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    return _storageKeyPrefix;
  }

  /// 获取所有运动记录（优先从服务器获取）
  Future<List<WorkoutRecord>> getAll() async {
    try {
      // 尝试从服务器获取
      final workoutsList = await _api.getWorkouts();
      final workouts = workoutsList
          .map((json) => WorkoutRecord.fromJson(json))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));

      // 缓存到本地
      await _saveToLocal(workouts);
      return workouts;
    } catch (e) {
      // 如果服务器请求失败，从本地缓存读取
      return await _loadFromLocal();
    }
  }

  /// 添加运动记录（同步到服务器）
  Future<void> add(WorkoutRecord record) async {
    try {
      // 先创建到服务器
      await _api.createWorkout(record.toJson());
    } catch (e) {
      // 如果服务器请求失败，仍然保存到本地
      print('Failed to sync workout to server: $e');
    }

    // 保存到本地缓存
    final records = await _loadFromLocal();
    records.removeWhere((element) => element.id == record.id);
    records.insert(0, record);
    await _saveToLocal(records);
  }

  /// 删除运动记录（同步到服务器）
  Future<void> delete(String id) async {
    try {
      // 先从服务器删除
      await _api.deleteWorkout(id);
    } catch (e) {
      // 如果服务器请求失败，仍然删除本地数据
      print('Failed to delete workout from server: $e');
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
      await _api.batchCreateWorkouts(jsonList);
    } catch (e) {
      print('Failed to batch sync workouts: $e');
      rethrow;
    }
  }

  // ==================== 本地缓存相关 ====================

  /// 从本地加载运动记录
  Future<List<WorkoutRecord>> _loadFromLocal() async {
    try {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => WorkoutRecord.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      return [];
    }
  }

  /// 保存到本地
  Future<void> _saveToLocal(List<WorkoutRecord> records) async {
    try {
      final jsonList = records.map((r) => r.toJson()).toList();
      await _prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      // 忽略本地保存错误
    }
  }
}
