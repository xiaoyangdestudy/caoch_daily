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
    // baseUrl: 'http://10.0.2.2:3000/api', // Android模拟器连接本地服务器
    // baseUrl: 'http://localhost:3000/api', // 本地开发
    // baseUrl: 'http://192.168.1.100:3000/api', // 真机测试（替换为你的IP）
    baseUrl: 'http://111.230.25.80:3000/api', // 云服务器生产环境
  );
});

/// 认证状态Provider（异步初始化）
///
/// 等待ApiClient初始化完成后返回认证状态
final authStateProvider = FutureProvider<bool>((ref) async {
  final api = ref.watch(apiClientProvider);
  await api.init(); // 等待token加载完成
  return api.isAuthenticated;
});

/// 当前用户名Provider
final currentUsernameProvider = FutureProvider<String?>((ref) async {
  final api = ref.watch(apiClientProvider);
  await api.init(); // 确保已初始化
  return await api.getUsername();
});
