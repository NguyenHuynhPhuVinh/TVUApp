import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/components/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
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
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(AppStyles.space5),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: AppStyles.rounded2xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(AppStyles.space4),
                decoration: BoxDecoration(
                  color: AppColors.redSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.logout,
                  color: AppColors.red,
                  size: 32,
                ),
              ),
              SizedBox(height: AppStyles.space4),
              
              // Title
              Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: AppStyles.textXl,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppStyles.space2),
              
              // Content
              Text(
                'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppStyles.space5),
              
              // Buttons
              Column(
                children: [
                  DuoButton(
                    text: 'Đăng xuất',
                    variant: DuoButtonVariant.danger,
                    onPressed: () async {
                      Navigator.of(Get.context!).pop();
                      await _authService.logout();
                      Get.offAllNamed(Routes.login);
                    },
                    fullWidth: true,
                  ),
                  SizedBox(height: AppStyles.space2),
                  DuoButton(
                    text: 'Hủy',
                    variant: DuoButtonVariant.ghost,
                    onPressed: () => Navigator.of(Get.context!).pop(),
                    fullWidth: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}



