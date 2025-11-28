import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API客户端 - 处理所有HTTP请求和认证
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  String? _token;
  String? _userId;

  bool _isInitialized = false;

  ApiClient({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 请求拦截器 - 自动添加token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Token过期，清除本地token
        if (error.response?.statusCode == 401) {
          await clearToken();
        }
        return handler.next(error);
      },
    ));
  }

  /// 初始化 - 加载本地token
  Future<void> init() async {
    if (!_isInitialized) {
      await _loadToken();
      _isInitialized = true;
    }
  }

  /// 从SharedPreferences加载token
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');
  }

  /// 保存token到本地
  Future<void> setToken(String token, String userId, String username) async {
    _token = token;
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('username', username);
  }

  /// 清除token
  Future<void> clearToken() async {
    _token = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('username');
  }

  /// 是否已认证
  bool get isAuthenticated => _token != null;

  /// 当前用户ID
  String? get userId => _userId;

  /// 获取当前用户名
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // ==================== 认证API ====================

  /// 注册
  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['token'] as String;
      final userId = response.data['userId'] as String;
      final returnedUsername = response.data['username'] as String;

      await setToken(token, userId, returnedUsername);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['token'] as String;
      final userId = response.data['userId'] as String;
      final returnedUsername = response.data['username'] as String;

      await setToken(token, userId, returnedUsername);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 登出
  Future<void> logout() async {
    await clearToken();
  }

  // ==================== 通用请求方法 ====================

  /// GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST请求
  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE请求
  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 错误处理 ====================

  /// 统一错误处理
  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return '连接超时，请检查网络';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return '服务器响应超时';
    } else if (e.type == DioExceptionType.connectionError) {
      return '无法连接到服务器';
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (statusCode == 401) {
        return '认证失败，请重新登录';
      } else if (statusCode == 404) {
        return '请求的资源不存在';
      } else if (statusCode == 409) {
        // 通常是用户名已存在等冲突
        if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
        return '数据冲突';
      } else if (statusCode == 400) {
        // 请求参数错误
        if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
        return '请求参数错误';
      } else if (statusCode != null && statusCode >= 500) {
        return '服务器错误，请稍后重试';
      }

      // 尝试从响应中提取错误消息
      if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      }

      return '请求失败: $statusCode';
    }

    return '网络请求失败: ${e.message}';
  }
}
