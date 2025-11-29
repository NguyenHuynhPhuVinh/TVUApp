import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement_model.dart';
import '../models/achievement_reward.dart';
import '../data/achievement_definitions.dart';
import '../../../core/game_service.dart';
import '../../../core/game_sync_service.dart';
import '../../../core/game_security_guard.dart';
import '../../../../../infrastructure/security/security_service.dart';
import '../../../../../infrastructure/storage/storage_service.dart';

/// Service quản lý hệ thống thành tựu
/// 
/// BẢO MẬT 5 LỚP:
/// 1. Firebase Check - Kiểm tra đã claim chưa (source of truth)
/// 2. Security Check - Root/Jailbreak, Emulator, Debug mode
/// 3. Lock Mechanism - Chống double click/spam
/// 4. Server Time Validation - Chống hack đồng hồ
/// 5. Data Signing - Checksum + Device fingerprint khi sync
class AchievementService extends GetxService {
  late final SharedPreferences _prefs;
  late final GameService _gameService;
  late final GameSyncService _syncService;
  late final GameSecurityGuard _guard;
  late final SecurityService _security;

  static const String _achievementsKey = 'player_achievements';

  /// Danh sách thành tựu của người chơi
  final achievements = <Achievement>[].obs;

  /// Thống kê thành tựu
  final totalUnlocked = 0.obs;
  final totalClaimed = 0.obs;
  final unclaimedCount = 0.obs;

  /// Loading state
  final isLoading = false.obs;

  /// Lock để chống double claim
  bool _isClaimingReward = false;
  bool _isClaimingAll = false;

  Future<AchievementService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _gameService = Get.find<GameService>();
    _syncService = Get.find<GameSyncService>();
    _guard = Get.find<GameSecurityGuard>();
    _security = Get.find<SecurityService>();
    await _loadAchievements();
    
    // Tự động check achievements khi game stats thay đổi
    _listenToGameStats();
    
    // Check tiến độ ngay khi init để cập nhật thành tựu
    // Retry nhiều lần để đảm bảo có data
    _scheduleInitialCheck();
    
    return this;
  }
  
  /// Schedule check tiến độ ban đầu với retry
  void _scheduleInitialCheck() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      final stats = _gameService.stats.value;
      if (stats.isInitialized) {
        await _autoCheckProgress();
      } else {
        // Retry sau 1 giây nếu chưa init
        Future.delayed(const Duration(seconds: 1), () async {
          await _autoCheckProgress();
        });
      }
    });
  }
  
  /// Listen vào game stats để tự động cập nhật tiến độ thành tựu
  void _listenToGameStats() {
    ever(_gameService.stats, (_) {
      // Debounce - chỉ check sau 1 giây để tránh spam
      Future.delayed(const Duration(seconds: 1), () {
        _autoCheckProgress();
      });
    });
  }
  
  /// Tự động check tiến độ dựa trên game stats và storage data
  Future<void> _autoCheckProgress() async {
    final stats = _gameService.stats.value;
    
    // Lấy data từ storage
    final storage = Get.find<StorageService>();
    
    // Tính tín chỉ, môn đã qua, GPA và điểm A từ grades (nguồn chính xác)
    int totalCredits = 0;
    int subjectsPassed = 0;
    double gpa = 0;
    int gradeACount = 0;
    int perfectScoreCount = 0;
    
    final gradesData = storage.getGrades();
    if (gradesData != null && gradesData['data'] != null) {
      final semesterList = gradesData['data']['ds_diem_hocky'] as List? ?? [];
      
      for (int i = 0; i < semesterList.length; i++) {
        final sem = semesterList[i];
        
        // Lấy GPA tích lũy và tín chỉ tích lũy từ học kỳ đầu tiên (mới nhất)
        if (i == 0) {
          gpa = double.tryParse(sem['dtb_tich_luy_he_10']?.toString() ?? '') ?? 0;
          totalCredits = int.tryParse(sem['so_tin_chi_dat_tich_luy']?.toString() ?? '') ?? 0;
        }
        
        final subjects = sem['ds_diem_mon_hoc'] as List? ?? [];
        for (final subject in subjects) {
          // Đếm môn đã đạt
          final ketQua = subject['ket_qua'];
          if (ketQua == 1 || ketQua == '1') {
            subjectsPassed++;
          }
          
          // Đếm điểm A và điểm 10
          final scoreStr = subject['diem_tk']?.toString() ?? '';
          final score = double.tryParse(scoreStr) ?? 0;
          if (score >= 8.5) gradeACount++;
          if (score >= 10) perfectScoreCount++;
        }
      }
    }
    
    // Tính tổng học phí đã đóng từ tuition data
    int tuitionPaid = 0;
    int semestersPaid = 0;
    bool allSemesterPaid = true;
    
    final tuitionData = storage.getTuition();
    if (tuitionData != null && tuitionData['data'] != null) {
      final tuitionList = tuitionData['data']['ds_hoc_phi_hoc_ky'] as List? ?? [];
      for (final sem in tuitionList) {
        final daThu = double.tryParse(sem['da_thu']?.toString() ?? '') ?? 0;
        final conNo = double.tryParse(sem['con_no']?.toString() ?? '') ?? 0;
        
        tuitionPaid += daThu.toInt();
        
        if (daThu > 0 && conNo <= 0) {
          semestersPaid++;
        }
        
        if (conNo > 0) {
          allSemesterPaid = false;
        }
      }
    }
    
    // Tính rank index từ GPA (0-55)
    // Công thức: (gpa / 10) * 55
    final currentRankIndex = ((gpa / 10) * 55).floor().clamp(0, 55);
    
    // Tính tổng số buổi đã check-in từ storage
    final checkIns = storage.getLessonCheckIns();
    final checkInTotal = checkIns.length;
    final firstCheckIn = checkInTotal > 0;
    
    // Check first login (game initialized = first login)
    final firstLogin = stats.isInitialized;
    
    // Check first rank reward
    final firstRankReward = stats.claimedRankRewards.isNotEmpty;
    
    // Check first subject reward
    final firstSubjectReward = stats.claimedSubjects.isNotEmpty;
    
    final newlyUnlocked = await updateProgress(
      // Academic
      subjectsPassed: subjectsPassed,
      totalCredits: totalCredits,
      gpa: gpa,
      gradeACount: gradeACount,
      perfectScoreCount: perfectScoreCount,
      // Attendance
      lessonsAttended: stats.totalLessonsAttended,
      attendanceRate: stats.attendanceRate,
      checkInTotal: checkInTotal,
      // Financial
      tuitionPaid: tuitionPaid,
      semestersPaid: semestersPaid,
      // Progress
      level: stats.level,
      totalCoinsEarned: stats.coins,
      totalDiamondsEarned: stats.diamonds,
      currentRankIndex: currentRankIndex,
      // Special
      firstLogin: firstLogin,
      gameInitialized: stats.isInitialized,
      firstCheckIn: firstCheckIn,
      firstRankReward: firstRankReward,
      firstSubjectReward: firstSubjectReward,
      allSemesterPaid: allSemesterPaid && semestersPaid > 0,
    );
    
    // Hiển thị thông báo nếu có thành tựu mới
    if (newlyUnlocked.isNotEmpty) {
      _showUnlockedNotification(newlyUnlocked);
    }
  }
  
  /// Hiển thị thông báo khi mở khóa thành tựu mới
  void _showUnlockedNotification(List<Achievement> achievements) {
    if (achievements.isEmpty) return;
    
    final names = achievements.map((a) => a.name).join(', ');
    Get.snackbar(
      'Thành tựu mới!',
      'Bạn đã mở khóa: $names',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xF058CC02),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  // ============ LOCAL STORAGE ============

  Future<void> _loadAchievements() async {
    final str = _prefs.getString(_achievementsKey);
    if (str != null) {
      final list = jsonDecode(str) as List;
      achievements.value = list.map((e) => Achievement.fromJson(e)).toList();
    } else {
      achievements.value = AchievementDefinitions.getAllDefinitions();
    }
    _updateStats();
  }

  Future<void> _saveAchievements() async {
    await _prefs.setString(
      _achievementsKey,
      jsonEncode(achievements.map((e) => e.toJson()).toList()),
    );
  }

  void _updateStats() {
    totalUnlocked.value = achievements.where((a) => a.isUnlocked).length;
    totalClaimed.value = achievements.where((a) => a.isRewardClaimed).length;
    unclaimedCount.value = achievements.where((a) => a.canClaimReward).length;
  }

  // ============ ACHIEVEMENT CHECKING ============

  Future<List<Achievement>> updateProgress({
    int? subjectsPassed,
    int? totalCredits,
    double? gpa,
    int? gradeACount,
    int? perfectScoreCount,
    int? lessonsAttended,
    double? attendanceRate,
    int? checkInTotal,
    int? tuitionPaid,
    int? semestersPaid,
    int? level,
    int? totalCoinsEarned,
    int? totalDiamondsEarned,
    int? currentRankIndex,
    bool? firstLogin,
    bool? gameInitialized,
    bool? firstCheckIn,
    bool? firstSubjectReward,
    bool? firstRankReward,
    bool? allSemesterPaid,
    bool? perfectAttendanceSemester,
    bool? graduated,
  }) async {
    final newlyUnlocked = <Achievement>[];

    for (int i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      if (achievement.isUnlocked) continue;

      int? newValue;

      switch (achievement.id.split('_').first) {
        case 'subject':
          if (achievement.id.startsWith('subject_passed')) {
            newValue = subjectsPassed;
          }
        case 'credits':
          newValue = totalCredits;
        case 'gpa':
          if (gpa != null) newValue = (gpa * 10).round();
        case 'grade':
          if (achievement.id.startsWith('grade_a')) {
            newValue = gradeACount;
          }
        case 'perfect':
          if (achievement.id.startsWith('perfect_score')) {
            newValue = perfectScoreCount;
          } else if (achievement.id == 'perfect_attendance_semester' &&
              perfectAttendanceSemester == true) {
            newValue = 1;
          }
        case 'lessons':
          newValue = lessonsAttended;
        case 'attendance':
          if (attendanceRate != null) newValue = attendanceRate.round();
        case 'checkin':
          newValue = checkInTotal;
        case 'tuition':
          newValue = tuitionPaid;
        case 'semesters':
          newValue = semestersPaid;
        case 'level':
          newValue = level;
        case 'coins':
          newValue = totalCoinsEarned;
        case 'diamonds':
          newValue = totalDiamondsEarned;
        case 'rank':
          newValue = currentRankIndex;
        case 'first':
          if (achievement.id == 'first_login' && firstLogin == true) {
            newValue = 1;
          }
          if (achievement.id == 'first_checkin' && firstCheckIn == true) {
            newValue = 1;
          }
          if (achievement.id == 'first_subject_reward' &&
              firstSubjectReward == true) {
            newValue = 1;
          }
          if (achievement.id == 'first_rank_reward' && firstRankReward == true) {
            newValue = 1;
          }
        case 'game':
          if (achievement.id == 'game_initialized' && gameInitialized == true) {
            newValue = 1;
          }
        case 'all':
          if (achievement.id == 'all_semester_paid' && allSemesterPaid == true) {
            newValue = 1;
          }
        case 'graduate':
          if (graduated == true) newValue = 1;
      }

      // Cập nhật nếu có giá trị mới và lớn hơn hoặc bằng giá trị cũ
      if (newValue != null && newValue >= achievement.currentValue) {
        final shouldUnlock = newValue >= achievement.targetValue;
        final updated = achievement.copyWith(
          currentValue: newValue,
          isUnlocked: shouldUnlock,
          unlockedAt: shouldUnlock && !achievement.isUnlocked 
              ? DateTime.now() 
              : achievement.unlockedAt,
        );
        
        // Chỉ cập nhật nếu có thay đổi
        if (updated.currentValue != achievement.currentValue || 
            updated.isUnlocked != achievement.isUnlocked) {
          achievements[i] = updated;

          if (updated.isUnlocked && !achievement.isUnlocked) {
            newlyUnlocked.add(updated);
            debugPrint('Achievement unlocked: ${updated.name}');
          }
        }
      }
    }

    // Luôn save và update stats nếu có thay đổi
    await _saveAchievements();
    _updateStats();

    return newlyUnlocked;
  }

  // ============ REWARD CLAIMING (BẢO MẬT 5 LỚP) ============

  /// Nhận thưởng cho một thành tựu
  /// 
  /// BẢO MẬT 5 LỚP:
  /// 1. Firebase Check - Đã claim chưa
  /// 2. Security Check - Root/Jailbreak/Emulator
  /// 3. Lock Mechanism - Chống double click
  /// 4. Server Time Validation - Chống hack đồng hồ
  /// 5. Data Signing - Checksum khi sync
  Future<Map<String, dynamic>?> claimReward({
    required String mssv,
    required String achievementId,
  }) async {
    // LỚP 3: Lock mechanism - chống double click
    if (_isClaimingReward) {
      debugPrint('claimReward blocked: Already processing');
      return null;
    }

    final index = achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) {
      debugPrint('Achievement not found: $achievementId');
      return null;
    }

    final achievement = achievements[index];
    if (!achievement.canClaimReward) {
      debugPrint('Cannot claim reward for: $achievementId');
      return null;
    }

    _isClaimingReward = true;
    isLoading.value = true;

    try {
      // LỚP 1: Firebase Check - đã claim chưa (source of truth)
      final alreadyClaimed = await _syncService.checkAchievementClaimedOnFirebase(
        mssv,
        achievementId,
      );
      if (alreadyClaimed) {
        debugPrint('claimReward blocked: Already claimed on Firebase');
        achievements[index] = achievement.copyWith(isRewardClaimed: true);
        await _saveAchievements();
        _updateStats();
        return null;
      }

      // LỚP 2: Security Check - Root/Jailbreak/Emulator
      if (!_guard.isSecure.value) {
        await _guard.checkSecurity();
        if (!_guard.isSecure.value) {
          debugPrint('claimReward blocked: Security issues - ${_guard.securityIssues}');
          return null;
        }
      }

      // LỚP 4: Server Time Validation - chống hack đồng hồ
      final isTimeValid = await _syncService.validateLocalTime(mssv);
      if (!isTimeValid) {
        debugPrint('claimReward blocked: Time manipulation detected');
        return null;
      }

      // Tính phần thưởng
      final reward = AchievementReward.forAchievement(achievement);

      // Cộng rewards (đã có bảo mật trong GameService)
      await _gameService.addCoins(reward.coins, mssv);
      await _gameService.addDiamonds(reward.diamonds, mssv);
      final xpResult = await _gameService.addXp(reward.xp, mssv);

      // Cập nhật local state
      achievements[index] = achievement.copyWith(isRewardClaimed: true);
      await _saveAchievements();
      _updateStats();

      // LỚP 5: Data Signing - sync với checksum
      await _syncAchievementToFirebaseSecure(mssv, achievementId, reward);

      return {
        'achievementId': achievementId,
        'achievementName': achievement.name,
        'tier': achievement.tier.name,
        'coins': reward.coins,
        'diamonds': reward.diamonds,
        'xp': reward.xp,
        'leveledUp': xpResult?['leveledUp'] ?? false,
        'newLevel': xpResult?['newLevel'],
      };
    } finally {
      _isClaimingReward = false;
      isLoading.value = false;
    }
  }

  /// Nhận thưởng tất cả thành tựu đã mở khóa (BẢO MẬT 5 LỚP)
  Future<Map<String, dynamic>?> claimAllRewards({required String mssv}) async {
    // LỚP 3: Lock mechanism
    if (_isClaimingAll) {
      debugPrint('claimAllRewards blocked: Already processing');
      return null;
    }

    final claimable = achievements.where((a) => a.canClaimReward).toList();
    if (claimable.isEmpty) return null;

    _isClaimingAll = true;
    isLoading.value = true;

    try {
      // LỚP 2: Security Check
      if (!_guard.isSecure.value) {
        await _guard.checkSecurity();
        if (!_guard.isSecure.value) {
          debugPrint('claimAllRewards blocked: Security issues');
          return null;
        }
      }

      // LỚP 4: Server Time Validation
      final isTimeValid = await _syncService.validateLocalTime(mssv);
      if (!isTimeValid) {
        debugPrint('claimAllRewards blocked: Time manipulation detected');
        return null;
      }

      // LỚP 1: Firebase Check cho từng achievement
      final claimedOnFirebase =
          await _syncService.getClaimedAchievementsFromFirebase(mssv);

      int totalCoins = 0;
      int totalDiamonds = 0;
      int totalXp = 0;
      int claimedCount = 0;
      final toClaim = <Achievement>[];
      final rewards = <AchievementReward>[];

      // Bước 1: Tính tổng và chuẩn bị danh sách (không await trong loop)
      for (final achievement in claimable) {
        // Skip nếu đã claim trên Firebase
        if (claimedOnFirebase.contains(achievement.id)) {
          final idx = achievements.indexWhere((a) => a.id == achievement.id);
          if (idx != -1) {
            achievements[idx] = achievement.copyWith(isRewardClaimed: true);
          }
          continue;
        }

        final reward = AchievementReward.forAchievement(achievement);
        totalCoins += reward.coins;
        totalDiamonds += reward.diamonds;
        totalXp += reward.xp;
        toClaim.add(achievement);
        rewards.add(reward);
        claimedCount++;
      }

      if (claimedCount == 0) {
        await _saveAchievements();
        _updateStats();
        return null;
      }

      // Bước 2: Cập nhật local state ngay lập tức
      for (final achievement in toClaim) {
        final idx = achievements.indexWhere((a) => a.id == achievement.id);
        if (idx != -1) {
          achievements[idx] = achievement.copyWith(isRewardClaimed: true);
        }
      }
      
      // Cập nhật stats ngay để UI phản hồi nhanh
      _updateStats();

      // Bước 3: Cộng rewards một lần
      await _gameService.addCoins(totalCoins, mssv);
      await _gameService.addDiamonds(totalDiamonds, mssv);
      final xpResult = await _gameService.addXp(totalXp, mssv);

      await _saveAchievements();

      // Bước 4: Sync Firebase song song (không block UI)
      _syncAllAchievementsToFirebase(mssv, toClaim, rewards);

      return {
        'claimedCount': claimedCount,
        'totalCoins': totalCoins,
        'totalDiamonds': totalDiamonds,
        'totalXp': totalXp,
        'leveledUp': xpResult?['leveledUp'] ?? false,
        'newLevel': xpResult?['newLevel'],
      };
    } finally {
      _isClaimingAll = false;
      isLoading.value = false;
    }
  }
  
  /// Sync tất cả achievements lên Firebase (1 batch request duy nhất)
  void _syncAllAchievementsToFirebase(
    String mssv,
    List<Achievement> achievementsList,
    List<AchievementReward> rewards,
  ) {
    // Fire and forget - không await, chạy background
    Future(() async {
      try {
        // Chuẩn bị data cho batch
        final batchData = <Map<String, dynamic>>[];
        
        for (int i = 0; i < achievementsList.length; i++) {
          final achievement = achievementsList[i];
          final reward = rewards[i];
          
          final claimData = {
            'achievementId': achievement.id,
            'coins': reward.coins,
            'diamonds': reward.diamonds,
            'xp': reward.xp,
            'claimedAt': DateTime.now().toIso8601String(),
          };
          
          // Sign data với checksum
          final signedData = _security.signData(claimData);
          batchData.add(signedData);
        }
        
        // Gửi 1 batch request duy nhất
        await _syncService.saveAchievementsBatchToFirebase(
          mssv: mssv,
          achievementsData: batchData,
        );
      } catch (e) {
        debugPrint('Failed to batch sync achievements: $e');
      }
    });
  }

  // ============ FIREBASE SYNC (BẢO MẬT) ============

  /// Sync achievement với data signing (checksum + device fingerprint)
  Future<void> _syncAchievementToFirebaseSecure(
    String mssv,
    String achievementId,
    AchievementReward reward,
  ) async {
    try {
      // Tạo data với checksum
      final claimData = {
        'achievementId': achievementId,
        'coins': reward.coins,
        'diamonds': reward.diamonds,
        'xp': reward.xp,
        'claimedAt': DateTime.now().toIso8601String(),
      };

      // Sign data với checksum + device fingerprint
      final signedData = _security.signData(claimData);

      await _syncService.saveAchievementToFirebaseSecure(
        mssv: mssv,
        achievementId: achievementId,
        signedData: signedData,
      );
    } catch (e) {
      debugPrint('Failed to sync achievement to Firebase: $e');
    }
  }

  Future<void> syncFromFirebase(String mssv) async {
    try {
      final claimedIds =
          await _syncService.getClaimedAchievementsFromFirebase(mssv);

      for (int i = 0; i < achievements.length; i++) {
        if (claimedIds.contains(achievements[i].id)) {
          achievements[i] = achievements[i].copyWith(
            isRewardClaimed: true,
            isUnlocked: true,
          );
        }
      }

      await _saveAchievements();
      _updateStats();
    } catch (e) {
      debugPrint('Failed to sync achievements from Firebase: $e');
    }
  }

  // ============ GETTERS ============

  List<Achievement> getByCategory(AchievementCategory category) {
    return achievements.where((a) => a.category == category).toList();
  }

  List<Achievement> get unlockedAchievements {
    return achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> get lockedAchievements {
    return achievements.where((a) => !a.isUnlocked).toList();
  }

  List<Achievement> get claimableAchievements {
    return achievements.where((a) => a.canClaimReward).toList();
  }

  List<Achievement> get nearCompletionAchievements {
    return achievements
        .where((a) => !a.isUnlocked && a.progress > 0.5)
        .toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));
  }

  AchievementReward get totalClaimableReward {
    int coins = 0;
    int diamonds = 0;
    int xp = 0;

    for (final achievement in claimableAchievements) {
      final reward = AchievementReward.forAchievement(achievement);
      coins += reward.coins;
      diamonds += reward.diamonds;
      xp += reward.xp;
    }

    return AchievementReward(coins: coins, diamonds: diamonds, xp: xp);
  }

  Future<void> resetAchievements() async {
    achievements.value = AchievementDefinitions.getAllDefinitions();
    await _saveAchievements();
    _updateStats();
  }
}
