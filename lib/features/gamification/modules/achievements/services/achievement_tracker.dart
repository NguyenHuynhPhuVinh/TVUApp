import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'achievement_service.dart';
import '../../../../academic/grades/controllers/grades_controller.dart';
import '../../../core/game_service.dart';
import '../../../core/rank_helper.dart';

/// Tracker tự động cập nhật thành tựu khi có sự kiện
/// Singleton pattern để đảm bảo chỉ có 1 instance
class AchievementTracker {
  static AchievementTracker? _instance;
  static AchievementTracker get instance => _instance ??= AchievementTracker._();

  AchievementTracker._();

  bool _isInitialized = false;

  /// Khởi tạo tracker
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint('🏆 AchievementTracker initialized');
  }

  /// Gọi khi user đăng nhập lần đầu
  Future<void> onFirstLogin() async {
    await _updateAchievements(firstLogin: true);
  }

  /// Gọi khi khởi tạo game
  Future<void> onGameInitialized() async {
    await _updateAchievements(gameInitialized: true);
  }

  /// Gọi khi check-in buổi học
  Future<void> onLessonCheckIn({required int lessonsCount}) async {
    final service = _getService();
    if (service == null) return;

    final gameService = Get.find<GameService>();
    final stats = gameService.stats.value;

    await service.updateProgress(
      lessonsAttended: stats.totalLessonsAttended,
      attendanceRate: stats.attendanceRate,
      firstCheckIn: stats.totalLessonsAttended == lessonsCount, // First check-in
    );
  }

  /// Gọi khi nhận thưởng môn học
  Future<void> onSubjectRewardClaimed({required bool isFirst}) async {
    if (isFirst) {
      await _updateAchievements(firstSubjectReward: true);
    }
  }

  /// Gọi khi nhận thưởng rank
  Future<void> onRankRewardClaimed({required bool isFirst}) async {
    if (isFirst) {
      await _updateAchievements(firstRankReward: true);
    }
  }

  /// Gọi khi đóng học phí
  Future<void> onTuitionPaid({required int totalPaid, required int semestersPaid}) async {
    final service = _getService();
    if (service == null) return;

    await service.updateProgress(
      tuitionPaid: totalPaid,
      semestersPaid: semestersPaid,
    );
  }

  /// Gọi khi cập nhật điểm
  Future<void> onGradesUpdated() async {
    await _refreshFromGrades();
  }

  /// Gọi khi level up
  Future<void> onLevelUp({required int newLevel}) async {
    final service = _getService();
    if (service == null) return;

    final gameService = Get.find<GameService>();
    final stats = gameService.stats.value;

    await service.updateProgress(
      level: newLevel,
      totalCoinsEarned: stats.coins,
      totalDiamondsEarned: stats.diamonds,
    );
  }

  /// Refresh toàn bộ từ dữ liệu hiện tại
  Future<void> refreshAll() async {
    await _refreshFromGrades();
    await _refreshFromGameStats();
  }

  // ============ PRIVATE METHODS ============

  AchievementService? _getService() {
    if (!Get.isRegistered<AchievementService>()) {
      debugPrint('⚠️ AchievementService not registered');
      return null;
    }
    return Get.find<AchievementService>();
  }

  Future<void> _updateAchievements({
    bool? firstLogin,
    bool? gameInitialized,
    bool? firstCheckIn,
    bool? firstSubjectReward,
    bool? firstRankReward,
    bool? allSemesterPaid,
    bool? perfectAttendanceSemester,
    bool? graduated,
  }) async {
    final service = _getService();
    if (service == null) return;

    await service.updateProgress(
      firstLogin: firstLogin,
      gameInitialized: gameInitialized,
      firstCheckIn: firstCheckIn,
      firstSubjectReward: firstSubjectReward,
      firstRankReward: firstRankReward,
      allSemesterPaid: allSemesterPaid,
      perfectAttendanceSemester: perfectAttendanceSemester,
      graduated: graduated,
    );
  }

  Future<void> _refreshFromGrades() async {
    final service = _getService();
    if (service == null) return;

    if (!Get.isRegistered<GradesController>()) return;

    final gradesController = Get.find<GradesController>();
    final semesters = gradesController.gradesBySemester;

    int subjectsPassed = 0;
    int totalCredits = 0;
    double gpa = 0;
    int gradeACount = 0;
    int perfectScoreCount = 0;

    for (final semester in semesters) {
      for (final subject in semester.subjects) {
        if (subject.isPassed) {
          subjectsPassed++;

          final score = subject.diemTkDouble ?? 0;
          if (score >= 8.5) gradeACount++;
          if (score >= 10) perfectScoreCount++;
        }
      }

      if (semester.dtbTichLuyHe10Double != null) {
        gpa = semester.dtbTichLuyHe10Double!;
      }
      totalCredits = semester.soTinChiDatTichLuyInt;
    }

    final currentRankIndex = RankHelper.getRankIndexFromGpa(gpa);

    await service.updateProgress(
      subjectsPassed: subjectsPassed,
      totalCredits: totalCredits,
      gpa: gpa,
      gradeACount: gradeACount,
      perfectScoreCount: perfectScoreCount,
      currentRankIndex: currentRankIndex,
    );
  }

  Future<void> _refreshFromGameStats() async {
    final service = _getService();
    if (service == null) return;

    if (!Get.isRegistered<GameService>()) return;

    final gameService = Get.find<GameService>();
    final stats = gameService.stats.value;

    await service.updateProgress(
      lessonsAttended: stats.totalLessonsAttended,
      attendanceRate: stats.attendanceRate,
      tuitionPaid: stats.totalTuitionPaid,
      level: stats.level,
      totalCoinsEarned: stats.coins,
      totalDiamondsEarned: stats.diamonds,
      gameInitialized: stats.isInitialized,
    );
  }
}
