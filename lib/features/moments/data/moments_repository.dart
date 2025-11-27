import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/moment_model.dart';

const _momentsKey = 'moments_v1';

class MomentsRepository {
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  MomentsRepository(this._prefs);

  /// 获取所有动态
  Future<List<Moment>> getAll() async {
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

  /// 创建新动态
  Future<Moment> create(CreateMomentInput input) async {
    final moment = Moment(
      id: _uuid.v4(),
      content: input.content,
      createdAt: DateTime.now(),
      imageUrls: input.imageUrls,
      location: input.location,
      tags: input.tags,
    );

    final moments = await getAll();
    moments.insert(0, moment);
    await _saveAll(moments);

    return moment;
  }

  /// 删除动态
  Future<void> delete(String id) async {
    final moments = await getAll();
    moments.removeWhere((m) => m.id == id);
    await _saveAll(moments);
  }

  /// 点赞/取消点赞
  Future<void> toggleLike(String id) async {
    final moments = await getAll();
    final index = moments.indexWhere((m) => m.id == id);
    if (index != -1) {
      final moment = moments[index];
      moments[index] = moment.copyWith(
        likes: moment.likes > 0 ? 0 : 1,
      );
      await _saveAll(moments);
    }
  }

  Future<void> _saveAll(List<Moment> moments) async {
    final jsonList = moments.map((m) => m.toJson()).toList();
    await _prefs.setString(_momentsKey, jsonEncode(jsonList));
  }
}
