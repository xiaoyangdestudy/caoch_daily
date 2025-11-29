import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API客户端 - 处理所有HTTP请求和认证
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  String? _token;
  String? _userId;

  bool _isInitialized = false;

  /// 获取 Dio 实例（用于直接访问）
  Dio get dio => _dio;

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

  /// PUT请求
  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 文件上传 ====================

  /// 上传图片文件
  /// 返回上传后的图片URL列表
  Future<List<String>> uploadImages(List<String> filePaths) async {
    try {
      final formData = FormData();

      for (var i = 0; i < filePaths.length; i++) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(
            filePaths[i],
            filename: 'image_$i.jpg',
          ),
        ));
      }

      final response = await _dio.post(
        '/upload/images',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.data['urls'] != null) {
        return List<String>.from(response.data['urls'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 动态相关API ====================

  /// 获取动态列表
  Future<List<Map<String, dynamic>>> getMoments({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await get('/moments', queryParameters: {
        'page': page,
        'limit': limit,
      });

      if (response.data['moments'] != null) {
        return List<Map<String, dynamic>>.from(
          response.data['moments'] as List,
        );
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 创建动态
  Future<Map<String, dynamic>> createMoment({
    required String content,
    List<String>? imageUrls,
    String? location,
    List<String>? tags,
  }) async {
    try {
      final response = await post('/moments', data: {
        'content': content,
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (location != null) 'location': location,
        if (tags != null) 'tags': tags,
      });

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除动态
  Future<void> deleteMoment(String momentId) async {
    try {
      await delete('/moments/$momentId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 点赞/取消点赞动态
  Future<Map<String, dynamic>> toggleLikeMoment(String momentId) async {
    try {
      final response = await put('/moments/$momentId/like');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 运动记录API ====================

  /// 获取运动记录列表
  Future<List<Map<String, dynamic>>> getWorkouts() async {
    try {
      final response = await get('/workouts');
      if (response.data['workouts'] != null) {
        return List<Map<String, dynamic>>.from(response.data['workouts'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 创建运动记录
  Future<Map<String, dynamic>> createWorkout(Map<String, dynamic> workout) async {
    try {
      final response = await post('/workouts', data: workout);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 批量创建运动记录
  Future<void> batchCreateWorkouts(List<Map<String, dynamic>> workouts) async {
    try {
      await post('/workouts/batch', data: {'workouts': workouts});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除运动记录
  Future<void> deleteWorkout(String id) async {
    try {
      await delete('/workouts/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 饮食记录API ====================

  /// 获取饮食记录列表
  Future<List<Map<String, dynamic>>> getMeals() async {
    try {
      final response = await get('/meals');
      if (response.data['meals'] != null) {
        return List<Map<String, dynamic>>.from(response.data['meals'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 创建饮食记录
  Future<Map<String, dynamic>> createMeal(Map<String, dynamic> meal) async {
    try {
      final response = await post('/meals', data: meal);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 批量创建饮食记录
  Future<void> batchCreateMeals(List<Map<String, dynamic>> meals) async {
    try {
      await post('/meals/batch', data: {'meals': meals});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除饮食记录
  Future<void> deleteMeal(String id) async {
    try {
      await delete('/meals/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 睡眠记录API ====================

  /// 获取睡眠记录列表
  Future<List<Map<String, dynamic>>> getSleep() async {
    try {
      final response = await get('/sleep');
      if (response.data['sleep'] != null) {
        return List<Map<String, dynamic>>.from(response.data['sleep'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 创建睡眠记录
  Future<Map<String, dynamic>> createSleep(Map<String, dynamic> sleep) async {
    try {
      final response = await post('/sleep', data: sleep);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 批量创建睡眠记录
  Future<void> batchCreateSleep(List<Map<String, dynamic>> sleep) async {
    try {
      await post('/sleep/batch', data: {'sleep': sleep});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除睡眠记录
  Future<void> deleteSleep(String id) async {
    try {
      await delete('/sleep/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 专注记录API ====================

  /// 获取专注记录列表
  Future<List<Map<String, dynamic>>> getFocus() async {
    try {
      final response = await get('/focus');
      if (response.data['focus'] != null) {
        return List<Map<String, dynamic>>.from(response.data['focus'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 创建专注记录
  Future<Map<String, dynamic>> createFocus(Map<String, dynamic> focus) async {
    try {
      final response = await post('/focus', data: focus);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 批量创建专注记录
  Future<void> batchCreateFocus(List<Map<String, dynamic>> focus) async {
    try {
      await post('/focus/batch', data: {'focus': focus});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除专注记录
  Future<void> deleteFocus(String id) async {
    try {
      await delete('/focus/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 复盘记录API ====================

  /// 获取复盘记录列表
  Future<List<Map<String, dynamic>>> getReviews() async {
    try {
      final response = await get('/reviews');
      if (response.data['reviews'] != null) {
        return List<Map<String, dynamic>>.from(response.data['reviews'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 创建复盘记录
  Future<Map<String, dynamic>> createReview(Map<String, dynamic> review) async {
    try {
      final response = await post('/reviews', data: review);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 批量创建复盘记录
  Future<void> batchCreateReviews(List<Map<String, dynamic>> reviews) async {
    try {
      await post('/reviews/batch', data: {'reviews': reviews});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除复盘记录
  Future<void> deleteReview(String id) async {
    try {
      await delete('/reviews/$id');
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
