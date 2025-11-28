import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final errorMessage = ''.obs;
  final acceptedTerms = false.obs;
  final showLoginForm = false.obs; // Hiển thị form đăng nhập hay màn hình giới thiệu

  void showForm() {
    showLoginForm.value = true;
  }

  void hideForm() {
    showLoginForm.value = false;
    errorMessage.value = '';
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleAcceptedTerms() {
    acceptedTerms.value = !acceptedTerms.value;
  }

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Vui lòng nhập đầy đủ thông tin';
      return;
    }

    if (!acceptedTerms.value) {
      errorMessage.value = 'Vui lòng đồng ý với điều khoản sử dụng';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiService.login(
        usernameController.text.trim(),
        passwordController.text,
      );

      print('Login response: $response');
      if (response != null && response['access_token'] != null) {
        print('Token received: ${response['access_token'].toString().substring(0, 30)}...');
        await _authService.saveCredentials(
          token: response['access_token'],
          user: usernameController.text.trim(),
          password: passwordController.text,
        );
        print('Token saved, navigating to splash for sync...');
        // Chuyển về splash để sync hết data (lần đầu login)
        Get.offAllNamed(Routes.splash, arguments: {'justLoggedIn': true});
      } else {
        errorMessage.value = 'Đăng nhập thất bại';
      }
    } catch (e) {
      errorMessage.value = 'Sai tài khoản hoặc mật khẩu';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
