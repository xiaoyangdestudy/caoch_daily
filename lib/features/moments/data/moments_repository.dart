import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/services/api_client.dart';
import '../domain/moment_model.dart';

const _momentsKey = 'moments_v1';

class MomentsRepository {
  final SharedPreferences _prefs;
  final ApiClient _apiClient;
  final _uuid = const Uuid();

  MomentsRepository(this._prefs, this._apiClient);

  /// 获取所有动态
  Future<List<Moment>> getAll() async {
    try {
      // 尝试从服务器获取
      final momentsList = await _apiClient.getMoments();
      final moments = momentsList
          .map((json) => Moment.fromJson(json))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 缓存到本地
      await _saveToLocal(moments);
      return moments;
    } catch (e) {
      // 如果服务器请求失败，从本地缓存读取
      return await _loadFromLocal();
    }
  }

  /// 创建新动态
  Future<Moment> create(CreateMomentInput input) async {
    Moment newMoment;

    try {
      // 1. 先上传图片（如果有）
      List<String> imageUrls = [];
      if (input.imagePaths.isNotEmpty) {
        imageUrls = await _apiClient.uploadImages(input.imagePaths);
      }

      // 2. 创建动态
      final momentData = await _apiClient.createMoment(
        content: input.content,
        imageUrls: imageUrls.isEmpty ? null : imageUrls,
        location: input.location,
        tags: input.tags,
      );

      newMoment = Moment.fromJson(momentData);
    } catch (e) {
      // 如果API调用失败，创建本地动态（模拟模式）
      final username = await _apiClient.getUsername() ?? '我';
      newMoment = Moment(
        id: _uuid.v4(),
        userId: _uuid.v4(),
        username: username,
        content: input.content,
        createdAt: DateTime.now(),
        imageUrls: input.imagePaths, // 在本地模式下，直接使用本地路径
        location: input.location,
        tags: input.tags,
      );
    }

    // 保存到本地缓存
    final localMoments = await _loadFromLocal();
    localMoments.insert(0, newMoment);
    await _saveToLocal(localMoments);

    return newMoment;
  }

  /// 删除动态
  Future<void> delete(String id) async {
    try {
      await _apiClient.deleteMoment(id);
    } catch (e) {
      // 如果API调用失败，忽略错误（继续删除本地数据）
    }

    // 更新本地缓存
    final moments = await _loadFromLocal();
    moments.removeWhere((m) => m.id == id);
    await _saveToLocal(moments);
  }

  /// 点赞/取消点赞
  Future<void> toggleLike(String id) async {
    // 先更新本地缓存（乐观更新）
    final moments = await _loadFromLocal();
    final index = moments.indexWhere((m) => m.id == id);
    if (index != -1) {
      final moment = moments[index];
      moments[index] = moment.copyWith(
        isLiked: !moment.isLiked,
        likes: moment.isLiked ? moment.likes - 1 : moment.likes + 1,
      );
      await _saveToLocal(moments);
    }

    try {
      await _apiClient.toggleLikeMoment(id);
    } catch (e) {
      // 如果API调用失败，回滚本地更改
      if (index != -1) {
        final moment = moments[index];
        moments[index] = moment.copyWith(
          isLiked: !moment.isLiked,
          likes: moment.isLiked ? moment.likes - 1 : moment.likes + 1,
        );
        await _saveToLocal(moments);
      }
      rethrow;
    }
  }

  // ==================== 本地缓存相关 ====================

  /// 从本地加载动态
  Future<List<Moment>> _loadFromLocal() async {
    try {
      final jsonString = _prefs.getString(_momentsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Moment.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  /// 保存到本地
  Future<void> _saveToLocal(List<Moment> moments) async {
    try {
      final jsonList = moments.map((m) => m.toJson()).toList();
      await _prefs.setString(_momentsKey, jsonEncode(jsonList));
    } catch (e) {
      // 忽略本地保存错误
    }
  }
}
