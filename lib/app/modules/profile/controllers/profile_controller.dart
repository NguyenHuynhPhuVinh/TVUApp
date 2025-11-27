import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final studentInfo = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getStudentInfo();
      if (response != null && response['data'] != null) {
        final student = response['data']['sinh_vien'];
        if (student != null) {
          studentInfo.value = Map<String, dynamic>.from(student);
        }
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải thông tin sinh viên');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              Get.offAllNamed(Routes.login);
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
