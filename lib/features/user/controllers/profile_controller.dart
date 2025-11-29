import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../features/gamification/shared/models/player_stats.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../infrastructure/storage/storage_service.dart';
import '../../../../routes/app_routes.dart';
import '../models/student_model.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();
  final GameService _gameService = Get.find<GameService>();

  final studentInfo = Rxn<StudentInfo>();

  // Game stats - expose reactive stats directly
  PlayerStats get gameStats => _gameService.stats.value;
  int get coins => gameStats.coins;
  int get diamonds => gameStats.diamonds;
  int get level => gameStats.level;
  int get currentXp => gameStats.currentXp;
  int get xpForNextLevel => level * 100;
  double get xpProgress => currentXp / xpForNextLevel;
  int get totalLessonsAttended => gameStats.totalLessonsAttended;
  int get totalLessonsMissed => gameStats.totalLessonsMissed;
  double get attendanceRate => gameStats.attendanceRate;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    final studentInfoData = _storage.getStudentInfo();
    if (studentInfoData != null && studentInfoData['data'] != null) {
      studentInfo.value = StudentInfo.fromJson(studentInfoData['data']);
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



