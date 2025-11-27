import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (_authService.isLoggedIn.value) {
        Get.offAllNamed(Routes.main);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      // If error, go to login
      Get.offAllNamed(Routes.login);
    }
  }
}
