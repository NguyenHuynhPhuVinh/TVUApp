import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;

import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class ApiService extends GetxService {
  late final Dio _dio;
  final AuthService _authService = Get.find<AuthService>();

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

  // Schedule API
  Future<Map<String, dynamic>?> getSchedule(String semester) async {
    try {
      final response = await _dio.post(
        ApiConstants.schedule,
        data: {
          'filter': {'hoc_ky': semester, 'ten_hoc_ky': ''},
          'additional': {'paging': {'limit': 100, 'page': 1}, 'ordering': []}
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

  // News API
  Future<Map<String, dynamic>?> getNews({String type = '', int limit = 20, int page = 1}) async {
    try {
      final response = await _dio.post(
        ApiConstants.news,
        data: {
          'filter': {'ky_hieu': type, 'is_hien_thi': true, 'is_hinh_dai_dien': true, 'is_quyen_xem': true},
          'additional': {
            'paging': {'limit': limit, 'page': page},
            'ordering': [{'name': 'do_uu_tien', 'order_type': 1}, {'name': 'ngay_dang_tin', 'order_type': 1}]
          }
        },
        options: Options(contentType: 'application/json'),
      );
      return response.data;
    } catch (e) {
      print('Error getNews: $e');
      return null;
    }
  }
}
