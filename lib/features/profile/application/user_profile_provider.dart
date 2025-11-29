import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_profile_repository.dart';
import '../domain/user_profile.dart';

/// 用户资料Provider - 获取和管理用户资料
final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

/// 用户资料Notifier - 管理用户资料状态
class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  late final UserProfileRepository _repository;

  @override
  Future<UserProfile?> build() async {
    _repository = ref.watch(userProfileRepositoryProvider);
    // Keep alive to prevent reloading when switching tabs
    ref.keepAlive();

    try {
      return await _repository.getProfile();
    } catch (e) {
      // 如果获取失败，返回 null
      return null;
    }
  }

  /// 加载用户资料
  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.getProfile();
    });
  }

  /// 更新用户资料
  Future<void> updateProfile({
    String? nickname,
    String? avatar,
    String? signature,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final request = UpdateProfileRequest(
        nickname: nickname,
        avatar: avatar,
        signature: signature,
        email: email,
      );
      return await _repository.updateProfile(request);
    });
  }

  /// 刷新用户资料
  Future<void> refresh() async {
    await loadProfile();
  }
}
