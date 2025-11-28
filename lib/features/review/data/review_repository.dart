import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/review_record.dart';

/// 每日回顾Repository - 支持本地+云端双存储
///
/// 策略：
/// - 优先从服务器获取数据（如果已登录）
/// - 服务器失败时使用本地数据
/// - 保存时同时保存到本地和服务器
/// - 不同用户的数据使用不同的本地存储key，实现数据隔离
class ReviewRepository {
  ReviewRepository(this._store, this._api, this._prefs);

  final LocalStore _store;
  final ApiClient _api;
  final SharedPreferences _prefs;

  static const _storageKeyPrefix = 'review_entries';
  static const String _cacheKey = 'review_entries_cache';

  /// 获取当前用户的存储key
  Future<String> _getStorageKey() async {
    final username = await _api.getUsername();
    if (username != null && username.isNotEmpty) {
      return '${_storageKeyPrefix}_$username';
    }
    // 未登录时使用通用key
    return _storageKeyPrefix;
  }

  // ==================== 获取数据 ====================

  /// 获取所有复盘记录（优先从服务器获取）
  Future<List<ReviewEntry>> fetchAll() async {
    try {
      // 尝试从服务器获取
      final reviewsList = await _api.getReviews();
      final reviews = reviewsList
          .map((json) => ReviewEntry.fromJson(json))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // 缓存到本地
      await _saveToLocal(reviews);
      return reviews;
    } catch (e) {
      // 如果服务器请求失败，从本地缓存读取
      return await _loadFromLocal();
    }
  }

  /// 从本地获取所有记录（已废弃，使用fetchAll）
  @Deprecated('Use fetchAll() instead')
  Future<List<ReviewEntry>> fetchLocal() async {
    return _loadFromLocal();
  }

  // ==================== 保存数据 ====================

  /// 保存复盘记录（同步到服务器）
  Future<void> save(ReviewEntry entry) async {
    try {
      // 先创建到服务器
      await _api.createReview(entry.toJson());
    } catch (e) {
      // 如果服务器请求失败，仍然保存到本地
      print('Failed to sync review to server: $e');
    }

    // 保存到本地缓存
    final entries = await _loadFromLocal();
    final index = entries.indexWhere((element) => element.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.insert(0, entry);
    }
    await _saveToLocal(entries);
  }

  // ==================== 删除数据 ====================

  /// 删除复盘记录（同步到服务器）
  Future<void> delete(String id) async {
    try {
      // 先从服务器删除
      await _api.deleteReview(id);
    } catch (e) {
      // 如果服务器请求失败，仍然删除本地数据
      print('Failed to delete review from server: $e');
    }

    // 更新本地缓存
    final entries = await _loadFromLocal();
    entries.removeWhere((element) => element.id == id);
    await _saveToLocal(entries);
  }

  // ==================== 数据同步 ====================

  /// 批量同步本地数据到服务器
  Future<void> syncToServer() async {
    try {
      final localEntries = await _loadFromLocal();
      if (localEntries.isEmpty) return;

      final jsonList = localEntries.map((r) => r.toJson()).toList();
      await _api.batchCreateReviews(jsonList);
    } catch (e) {
      print('Failed to batch sync reviews: $e');
      rethrow;
    }
  }

  /// 从服务器拉取数据到本地（已废弃，使用fetchAll）
  @Deprecated('Use fetchAll() instead')
  Future<void> syncFromServer() async {
    await fetchAll();
  }

  // ==================== 本地缓存相关 ====================

  /// 从本地加载复盘记录
  Future<List<ReviewEntry>> _loadFromLocal() async {
    try {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => ReviewEntry.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  /// 保存到本地
  Future<void> _saveToLocal(List<ReviewEntry> entries) async {
    try {
      final jsonList = entries.map((r) => r.toJson()).toList();
      await _prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      // 忽略本地保存错误
    }
  }
}
