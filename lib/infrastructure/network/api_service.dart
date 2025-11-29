import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;

import '../../core/constants/api_constants.dart';
import '../../features/auth/data/auth_service.dart';
import 'connectivity_service.dart';

class ApiService extends GetxService {
  late final Dio _dio;
  final AuthService _authService = Get.find<AuthService>();

  /// Kiểm tra có mạng không
  bool get _hasConnection {
    try {
      return Get.find<ConnectivityService>().hasConnection;
    } catch (_) {
      return true; // Nếu service chưa init, giả sử có mạng
    }
  }

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.timeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.timeout),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Referer': ApiConstants.baseUrl,
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authService.accessToken.value;
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final retryResponse = await _retry(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final credentials = await _authService.getCredentials();
      if (credentials['username'] == null || credentials['password'] == null) {
        return false;
      }
      final response = await login(credentials['username']!, credentials['password']!);
      if (response != null && response['access_token'] != null) {
        await _authService.updateToken(response['access_token']);
        return true;
      }
    } catch (e) {
      print('Refresh token failed: $e');
    }
    return false;
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer ${_authService.accessToken.value}'},
    );
    return _dio.request(requestOptions.path, data: requestOptions.data, queryParameters: requestOptions.queryParameters, options: options);
  }

  // Login API
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: 'username=$username&password=$password&grant_type=password',
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    return response.data;
  }

  // Get Semesters API
  Future<Map<String, dynamic>?> getSemesters() async {
    if (!_hasConnection) return null;
    try {
      final response = await _dio.post(
        ApiConstants.semesters,
        data: {
          'filter': {'is_tieng_anh': null},
          'additional': {
            'paging': {'limit': 100, 'page': 1},
            'ordering': [{'name': 'hoc_ky', 'order_type': 1}]
          }
        },
        options: Options(contentType: 'application/json'),
      );
      return response.data;
    } catch (e) {
      print('Error getSemesters: $e');
      return null;
    }
  }

  // Schedule API
  Future<Map<String, dynamic>?> getSchedule(int semester) async {
    if (!_hasConnection) return null;
    try {
      final response = await _dio.post(
        ApiConstants.schedule,
        data: {
          'filter': {'hoc_ky': semester, 'ten_hoc_ky': ''},
          'additional': {'paging': {'limit': 100, 'page': 1}, 'ordering': [{'name': null, 'order_type': null}]}
        },
        options: Options(contentType: 'application/json'),
      );
      return response.data;
    } catch (e) {
      print('Error getSchedule: $e');
      return null;
    }
  }

  // Grades API
  Future<Map<String, dynamic>?> getGrades() async {
    if (!_hasConnection) return null;
    try {
      final response = await _dio.post(
        ApiConstants.grades,
        data: {'filter': {'is_tinh_diem': true}, 'additional': {'paging': {'limit': 1000, 'page': 1}}},
        options: Options(contentType: 'application/json', headers: {'hien_thi_mon_theo_hkdk': 'false'}),
      );
      return response.data;
    } catch (e) {
      print('Error getGrades: $e');
      return null;
    }
  }

  // Tuition API
  Future<Map<String, dynamic>?> getTuition() async {
    if (!_hasConnection) return null;
    try {
      final response = await _dio.post(
        ApiConstants.tuition,
        data: {'filter': {}, 'additional': {'paging': {'limit': 100, 'page': 1}}},
        options: Options(contentType: 'application/json'),
      );
      return response.data;
    } catch (e) {
      print('Error getTuition: $e');
      return null;
    }
  }

  // Student Info API
  Future<Map<String, dynamic>?> getStudentInfo() async {
    if (!_hasConnection) return null;
    try {
      final response = await _dio.post(
        ApiConstants.studentInfo,
        data: {},
        options: Options(contentType: 'application/json'),
      );
      print('Student Info Response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error getStudentInfo: $e');
      return null;
    }
  }

  // Curriculum API
  Future<Map<String, dynamic>?> getCurriculum() async {
    if (!_hasConnection) return null;
    try {
      final response = await _dio.post(
        ApiConstants.curriculum,
        data: {
          'filter': {'loai_chuong_trinh_dao_tao': 2},
          'additional': {'paging': {'limit': 500, 'page': 1}, 'ordering': []}
        },
        options: Options(contentType: 'application/json'),
      );
      return response.data;
    } catch (e) {
      print('Error getCurriculum: $e');
      return null;
    }
  }

  // Notifications API
  Future<Map<String, dynamic>?> getNotifications({int limit = 50, int page = 1}) async {
    if (!_hasConnection) return null;
    try {
      final response = await _dio.post(
        ApiConstants.notifications,
        data: {
          'filter': {'id': null, 'is_noi_dung': true, 'is_web': true},
          'additional': {
            'paging': {'limit': limit, 'page': page},
            'ordering': [{'name': 'ngay_gui', 'order_type': 1}]
          }
        },
        options: Options(contentType: 'application/json'),
      );
      return response.data;
    } catch (e) {
      print('Error getNotifications: $e');
      return null;
    }
  }
}
