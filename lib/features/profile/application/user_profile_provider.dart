import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_profile_repository.dart';
import '../domain/user_profile.dart';

/// 用户资料Provider - 获取和管理用户资料
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UserProfileNotifier(repository);
});

/// 用户资料Notifier - 管理用户资料状态
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier(this._repository) : super(const AsyncValue.data(null)) {
    // 自动加载用户资料
    loadProfile();
  }

  final UserProfileRepository _repository;

  /// 加载用户资料
  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 更新用户资料
  Future<void> updateProfile({
    String? nickname,
    String? avatar,
    String? signature,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    try {
      final request = UpdateProfileRequest(
        nickname: nickname,
        avatar: avatar,
        signature: signature,
        email: email,
      );
      final updatedProfile = await _repository.updateProfile(request);
      state = AsyncValue.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      // 重新加载当前数据以恢复状态
      await loadProfile();
    }
  }

  /// 刷新用户资料
  Future<void> refresh() async {
    await loadProfile();
  }
}
