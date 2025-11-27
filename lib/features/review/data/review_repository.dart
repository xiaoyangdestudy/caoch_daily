import '../../../shared/services/local_store.dart';
import '../../../shared/services/api_client.dart';
import '../domain/review_record.dart';

/// 每日回顾Repository - 支持本地+云端双存储
///
/// 策略：
/// - 优先从服务器获取数据（如果已登录）
/// - 服务器失败时使用本地数据
/// - 保存时同时保存到本地和服务器
class ReviewRepository {
  ReviewRepository(this._store, this._api);

  final LocalStore _store;
  final ApiClient _api;

  static const _storageKey = 'review_entries';

  // ==================== 获取数据 ====================

  /// 从本地获取所有记录
  Future<List<ReviewEntry>> fetchLocal() async {
    final entries = _store.readList(_storageKey, ReviewEntry.fromJson);
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// 从服务器获取所有记录
  Future<List<ReviewEntry>> fetchFromServer({
    String? startDate,
    String? endDate,
    int limit = 100,
  }) async {
    final response = await _api.get('/reviews', queryParameters: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      'limit': limit.toString(),
    });

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ReviewEntry.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// 获取所有记录（优先服务器，失败则本地）
  Future<List<ReviewEntry>> fetchAll() async {
    if (_api.isAuthenticated) {
      try {
        // 从服务器获取
        final serverEntries = await fetchFromServer();

        // 缓存到本地
        await _store.writeList(_storageKey, serverEntries, (e) => e.toJson());

        return serverEntries;
      } catch (e) {
        print('⚠️ 从服务器获取失败，使用本地数据: $e');
        // fallback到本地
        return fetchLocal();
      }
    } else {
      // 未登录，使用本地数据
      return fetchLocal();
    }
  }

  // ==================== 保存数据 ====================

  /// 保存记录（本地+服务器）
  Future<void> save(ReviewEntry entry) async {
    // 1. 先保存到本地（确保离线也能用）
    final entries = await fetchLocal();
    final index = entries.indexWhere((element) => element.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.insert(0, entry);
    }
    await _store.writeList(_storageKey, entries, (entry) => entry.toJson());

    // 2. 同步到服务器（如果已登录）
    if (_api.isAuthenticated) {
      try {
        await _api.post('/reviews', data: {
          'id': entry.id,
          'date': entry.date.toIso8601String(),
          'mood': entry.mood,
          'highlights': entry.highlights,
          'improvements': entry.improvements,
          'tomorrowPlans': entry.tomorrowPlans,
          'aiSummary': entry.aiSummary,
          'note': entry.note,
        });
        print('✓ 已同步到服务器: ${entry.id}');
      } catch (e) {
        print('⚠️ 同步到服务器失败（已保存到本地）: $e');
        // 不抛出异常，因为本地已保存成功
      }
    }
  }

  // ==================== 删除数据 ====================

  /// 删除记录（本地+服务器）
  Future<void> delete(String id) async {
    // 1. 从本地删除
    final entries = await fetchLocal();
    entries.removeWhere((element) => element.id == id);
    await _store.writeList(_storageKey, entries, (entry) => entry.toJson());

    // 2. 从服务器删除（如果已登录）
    if (_api.isAuthenticated) {
      try {
        await _api.delete('/reviews/$id');
        print('✓ 已从服务器删除: $id');
      } catch (e) {
        print('⚠️ 从服务器删除失败（已从本地删除）: $e');
      }
    }
  }

  // ==================== 数据同步 ====================

  /// 批量同步本地数据到服务器
  ///
  /// 使用场景：
  /// - 用户刚登录后，将本地数据上传到服务器
  /// - 手动触发同步
  Future<void> syncToServer() async {
    if (!_api.isAuthenticated) {
      throw Exception('请先登录');
    }

    final localEntries = await fetchLocal();

    if (localEntries.isEmpty) {
      return;
    }

    int successCount = 0;
    int failCount = 0;

    for (final entry in localEntries) {
      try {
        await _api.post('/reviews', data: {
          'id': entry.id,
          'date': entry.date.toIso8601String(),
          'mood': entry.mood,
          'highlights': entry.highlights,
          'improvements': entry.improvements,
          'tomorrowPlans': entry.tomorrowPlans,
          'aiSummary': entry.aiSummary,
          'note': entry.note,
        });
        successCount++;
      } catch (e) {
        print('⚠️ 同步失败: ${entry.id}, 错误: $e');
        failCount++;
      }
    }

    print('✓ 同步完成: 成功 $successCount 条, 失败 $failCount 条');

    if (failCount > 0) {
      throw Exception('部分数据同步失败: 成功 $successCount 条, 失败 $failCount 条');
    }
  }

  /// 从服务器拉取数据到本地
  ///
  /// 使用场景：
  /// - 用户登录后，从服务器获取最新数据
  /// - 手动触发下载
  Future<void> syncFromServer() async {
    if (!_api.isAuthenticated) {
      throw Exception('请先登录');
    }

    final serverEntries = await fetchFromServer();

    // 保存到本地
    await _store.writeList(_storageKey, serverEntries, (e) => e.toJson());

    print('✓ 已从服务器下载 ${serverEntries.length} 条记录');
  }
}
