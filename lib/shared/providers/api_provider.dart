import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

/// API客户端Provider
///
/// 使用方法：
/// ```dart
/// final api = ref.watch(apiClientProvider);
/// await api.login(username, password);
/// ```
final apiClientProvider = Provider<ApiClient>((ref) {
  // ⚠️ 重要：修改为你的实际API地址
  //
  // 开发环境（本地测试）：
  // - 使用 'http://localhost:3000/api'
  // - 或者使用你电脑的局域网IP（如果在真机测试）：'http://192.168.1.100:3000/api'
  //
  // 生产环境（部署后）：
  // - 使用你的域名：'https://yourdomain.com/api'

  return ApiClient(
    // baseUrl: 'http://localhost:3000/api', // 本地开发
    // baseUrl: 'http://10.0.2.2:3000/api', // Android模拟器
    // baseUrl: 'http://192.168.1.100:3000/api', // 真机测试（替换为你的IP）
    baseUrl: 'http://111.230.25.80/api', // 云服务器生产环境
  );
});

/// 认证状态Provider
///
/// 用于监听用户登录状态
final authStateProvider = StreamProvider<bool>((ref) async* {
  final api = ref.watch(apiClientProvider);

  // 初始状态
  yield api.isAuthenticated;

  // 这里可以添加实时监听逻辑
  // 例如：每隔一段时间检查token是否过期
});

/// 当前用户名Provider
final currentUsernameProvider = FutureProvider<String?>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getUsername();
});
