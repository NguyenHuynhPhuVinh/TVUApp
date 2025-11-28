import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  final GameService _gameService = Get.find<GameService>();

  final studentInfo = <String, dynamic>{}.obs;

  // Game stats getters
  int get coins => _gameService.stats.value.coins;
  int get diamonds => _gameService.stats.value.diamonds;
  int get level => _gameService.stats.value.level;
  int get currentXp => _gameService.stats.value.currentXp;
  int get xpForNextLevel => level * 100;
  double get xpProgress => currentXp / xpForNextLevel;
  int get totalLessonsAttended => _gameService.stats.value.totalLessonsAttended;
  int get totalLessonsMissed => _gameService.stats.value.totalLessonsMissed;
  double get attendanceRate => _gameService.stats.value.attendanceRate;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    final studentInfoData = _localStorage.getStudentInfo();
    if (studentInfoData != null && studentInfoData['data'] != null) {
      studentInfo.value = Map<String, dynamic>.from(studentInfoData['data']);
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
