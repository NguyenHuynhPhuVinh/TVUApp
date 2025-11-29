import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/achievement_model.dart';
import '../models/achievement_reward.dart';
import '../services/achievement_service.dart';
import '../../../../academic/grades/controllers/grades_controller.dart';
import '../../../../user/controllers/profile_controller.dart';
import '../../../core/game_service.dart';
import '../../../core/rank_helper.dart';
import '../../../shared/widgets/game_widgets.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';

/// Controller cho màn hình thành tựu
class AchievementsController extends GetxController {
  late final AchievementService _achievementService;
  late final GameService _gameService;

  /// Category đang chọn
  final selectedCategory = Rxn<AchievementCategory>();

  /// Loading state
  final isLoading = false.obs;
  final isClaiming = false.obs;

  /// Filter
  final showOnlyUnlocked = false.obs;
  final showOnlyLocked = false.obs;
  final showOnlyClaimable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _achievementService = Get.find<AchievementService>();
    _gameService = Get.find<GameService>();
  }

  @override
  void onReady() {
    super.onReady();
    refreshAchievements();
  }

  // ============ GETTERS ============

  List<Achievement> get achievements => _achievementService.achievements;

  List<Achievement> get filteredAchievements {
    var list = achievements.toList();

    // Filter by category
    if (selectedCategory.value != null) {
      list = list.where((a) => a.category == selectedCategory.value).toList();
    }

    // Filter by unlocked
    if (showOnlyUnlocked.value) {
      list = list.where((a) => a.isUnlocked).toList();
    }

    // Filter by locked
    if (showOnlyLocked.value) {
      list = list.where((a) => !a.isUnlocked).toList();
    }

    // Filter by claimable
    if (showOnlyClaimable.value) {
      list = list.where((a) => a.canClaimReward).toList();
    }

    // Sort: claimable first, then by progress
    list.sort((a, b) {
      if (a.canClaimReward && !b.canClaimReward) return -1;
      if (!a.canClaimReward && b.canClaimReward) return 1;
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;
      return b.progress.compareTo(a.progress);
    });

    return list;
  }

  int get totalUnlocked => _achievementService.totalUnlocked.value;
  int get totalClaimed => _achievementService.totalClaimed.value;
  int get unclaimedCount => _achievementService.unclaimedCount.value;
  int get totalAchievements => achievements.length;

  double get completionRate =>
      totalAchievements > 0 ? totalUnlocked / totalAchievements : 0.0;

  AchievementReward get totalClaimableReward =>
      _achievementService.totalClaimableReward;

  // ============ ACTIONS ============

  /// Làm mới và cập nhật tiến độ thành tựu
  Future<void> refreshAchievements() async {
    isLoading.value = true;

    try {
      final stats = _gameService.stats.value;

      // Lấy dữ liệu học tập
      int subjectsPassed = 0;
      int totalCredits = 0;
      double gpa = 0;
      int gradeACount = 0;
      int perfectScoreCount = 0;

      if (Get.isRegistered<GradesController>()) {
        final gradesController = Get.find<GradesController>();
        final semesters = gradesController.gradesBySemester;

        for (final semester in semesters) {
          for (final subject in semester.subjects) {
            if (subject.isPassed) {
              subjectsPassed++;

              final score = subject.diemTkDouble ?? 0;
              if (score >= 8.5) gradeACount++;
              if (score >= 10) perfectScoreCount++;
            }
          }

          // Lấy GPA tích lũy từ học kỳ cuối
          if (semester.dtbTichLuyHe10Double != null) {
            gpa = semester.dtbTichLuyHe10Double!;
          }

          // Lấy tổng tín chỉ tích lũy
          totalCredits = semester.soTinChiDatTichLuyInt;
        }
      }

      // Tính rank index từ GPA
      final currentRankIndex = RankHelper.getRankIndexFromGpa(gpa);

      // Cập nhật tiến độ
      final newlyUnlocked = await _achievementService.updateProgress(
        // Academic
        subjectsPassed: subjectsPassed,
        totalCredits: totalCredits,
        gpa: gpa,
        gradeACount: gradeACount,
        perfectScoreCount: perfectScoreCount,
        // Attendance
        lessonsAttended: stats.totalLessonsAttended,
        attendanceRate: stats.attendanceRate,
        // Financial
        tuitionPaid: stats.totalTuitionPaid,
        // Progress
        level: stats.level,
        totalCoinsEarned: stats.coins,
        totalDiamondsEarned: stats.diamonds,
        currentRankIndex: currentRankIndex,
        // Special
        gameInitialized: stats.isInitialized,
      );

      // Hiển thị thông báo nếu có thành tựu mới
      if (newlyUnlocked.isNotEmpty) {
        _showUnlockedNotification(newlyUnlocked);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Nhận thưởng một thành tựu
  Future<void> claimReward(Achievement achievement) async {
    if (!achievement.canClaimReward) return;

    final profileController = Get.find<ProfileController>();
    final mssv = profileController.studentInfo.value?.mssv ?? '';
    if (mssv.isEmpty) return;

    final result = await _achievementService.claimReward(
      mssv: mssv,
      achievementId: achievement.id,
    );

    if (result != null) {
      _showRewardDialog(result);
    }
  }

  /// Nhận tất cả thưởng
  Future<void> claimAllRewards() async {
    if (unclaimedCount == 0) return;

    final profileController = Get.find<ProfileController>();
    final mssv = profileController.studentInfo.value?.mssv ?? '';
    if (mssv.isEmpty) return;

    isClaiming.value = true;

    try {
      final result = await _achievementService.claimAllRewards(mssv: mssv);

      if (result != null) {
        _showRewardDialog(result, isMultiple: true);
      }
    } finally {
      isClaiming.value = false;
    }
  }

  /// Chọn category
  void selectCategory(AchievementCategory? category) {
    selectedCategory.value = category;
  }

  /// Toggle filter
  void toggleUnlockedFilter() {
    showOnlyUnlocked.value = !showOnlyUnlocked.value;
    if (showOnlyUnlocked.value) {
      showOnlyLocked.value = false;
      showOnlyClaimable.value = false;
    }
  }

  void toggleLockedFilter() {
    showOnlyLocked.value = !showOnlyLocked.value;
    if (showOnlyLocked.value) {
      showOnlyUnlocked.value = false;
      showOnlyClaimable.value = false;
    }
  }

  void toggleClaimableFilter() {
    showOnlyClaimable.value = !showOnlyClaimable.value;
    if (showOnlyClaimable.value) {
      showOnlyUnlocked.value = false;
      showOnlyLocked.value = false;
    }
  }

  // ============ UI HELPERS ============

  void _showUnlockedNotification(List<Achievement> achievements) {
    if (achievements.isEmpty) return;

    final names = achievements.map((a) => a.name).join(', ');
    Get.snackbar(
      'Thành tựu mới!',
      'Bạn đã mở khóa: $names',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: AppColors.withAlpha(AppColors.green, 0.95),
      colorText: Colors.white,
      icon: Padding(
        padding: EdgeInsets.only(left: AppStyles.space3),
        child: Image.asset(AppAssets.crown, width: 28, height: 28),
      ),
    );
  }

  void _showRewardDialog(Map<String, dynamic> result,
      {bool isMultiple = false}) {
    final coins = result['coins'] ?? result['totalCoins'] ?? 0;
    final diamonds = result['diamonds'] ?? result['totalDiamonds'] ?? 0;
    final xp = result['xp'] ?? result['totalXp'] ?? 0;
    final leveledUp = result['leveledUp'] ?? false;
    final newLevel = result['newLevel'];

    DuoRewardDialog.showCustom(
      title: isMultiple
          ? 'Nhận thưởng thành công!'
          : result['achievementName'] ?? 'Thành tựu',
      subtitle: isMultiple ? 'Đã nhận ${result['claimedCount']} thành tựu' : null,
      rewards: [
        RewardItem(
          icon: AppAssets.coin,
          label: 'Coins',
          value: coins,
          color: AppColors.yellow,
        ),
        RewardItem(
          icon: AppAssets.diamond,
          label: 'Diamonds',
          value: diamonds,
          color: AppColors.primary,
        ),
        RewardItem(
          icon: AppAssets.xpStar,
          label: 'XP',
          value: xp,
          color: AppColors.purple,
        ),
      ],
      leveledUp: leveledUp,
      newLevel: newLevel,
    );
  }

  /// Lấy icon cho category (không dùng emoji)
  String getCategoryIcon(AchievementCategory category) {
    // Trả về asset path thay vì emoji
    switch (category) {
      case AchievementCategory.academic:
        return AppAssets.medalGold;
      case AchievementCategory.attendance:
        return AppAssets.checkmark;
      case AchievementCategory.financial:
        return AppAssets.tvuCash;
      case AchievementCategory.progress:
        return AppAssets.xpStar;
      case AchievementCategory.special:
        return AppAssets.giftPurple;
    }
  }

  /// Lấy tên cho category
  String getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.academic:
        return 'Học tập';
      case AchievementCategory.attendance:
        return 'Chuyên cần';
      case AchievementCategory.financial:
        return 'Tài chính';
      case AchievementCategory.progress:
        return 'Tiến trình';
      case AchievementCategory.special:
        return 'Đặc biệt';
    }
  }
}
