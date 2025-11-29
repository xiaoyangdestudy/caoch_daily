import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/api_provider.dart';
import '../../../shared/services/api_client.dart';
import '../domain/user_profile.dart';

/// 用户资料Repository，负责与服务器API交互
class UserProfileRepository {
  UserProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  /// 获取当前用户资料
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/profile');
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 更新用户资料
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiClient.dio.put(
        '/profile',
        data: request.toJson(),
      );
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['error'] ?? 'Unknown error';
      return Exception('Failed to update profile: $message');
    }
    return Exception('Network error: ${e.message}');
  }
}

/// 用户资料Repository Provider
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserProfileRepository(apiClient);
});
