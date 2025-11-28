import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_stats.dart';
import 'local_storage_service.dart';
import 'security_service.dart';

/// Service quản lý hệ thống game: coins, diamonds, level, XP
class GameService extends GetxService {
  late final SharedPreferences _prefs;
  late final FirebaseFirestore _firestore;
  late final SecurityService _security;
  
  static const String _statsKey = 'player_stats';
  
  final stats = PlayerStats().obs;
  final isLoading = false.obs;
  final isSecure = true.obs;
  final securityIssues = <String>[].obs;

  Future<GameService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _firestore = FirebaseFirestore.instance;
    _security = Get.find<SecurityService>();
    await _loadLocalStats();
    await _checkSecurity();
    return this;
  }

  /// Kiểm tra security khi khởi động
  Future<void> _checkSecurity() async {
    final result = await _security.performSecurityCheck();
    isSecure.value = result.isSecure;
    securityIssues.value = result.issues;
    
    if (!result.isSecure) {
      debugPrint('⚠️ Security issues detected: ${result.issues}');
    }
  }

  /// Load stats từ local storage
  Future<void> _loadLocalStats() async {
    final str = _prefs.getString(_statsKey);
    if (str != null) {
      stats.value = PlayerStats.fromJson(jsonDecode(str));
    }
  }

  /// Lưu stats vào local
  Future<void> _saveLocalStats() async {
    await _prefs.setString(_statsKey, jsonEncode(stats.value.toJson()));
  }

  /// Kiểm tra đã khởi tạo game chưa
  bool get isInitialized => stats.value.isInitialized;

  /// Sync stats từ Firebase (nếu có)
  Future<bool> syncFromFirebase(String mssv) async {
    if (mssv.isEmpty) return false;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        stats.value = PlayerStats.fromJson(doc.data()!['gameStats']);
        await _saveLocalStats();
        return true;
      }
    } catch (e) {
      print('Error syncing game stats from Firebase: $e');
    }
    return false;
  }

  /// Sync stats lên Firebase (với security check)
  Future<bool> syncToFirebase(String mssv) async {
    if (mssv.isEmpty) return false;
    
    try {
      // Sign data với checksum
      final signedStats = _security.signData(stats.value.toJson());
      
      await _firestore.collection('students').doc(mssv).set({
        'gameStats': signedStats,
        'deviceFingerprint': _security.deviceFingerprint.value,
        'isSecureDevice': isSecure.value,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error syncing game stats to Firebase: $e');
      return false;
    }
  }

  /// Tính tổng số tiết từ TKB tất cả học kỳ
  int calculateTotalLessons() {
    final localStorage = Get.find<LocalStorageService>();
    final allSchedules = localStorage.getAllSchedules();
    
    int totalLessons = 0;
    
    for (var scheduleData in allSchedules.values) {
      if (scheduleData is Map<String, dynamic>) {
        final weeks = scheduleData['ds_tuan_tkb'] as List? ?? [];
        for (var week in weeks) {
          final schedules = week['ds_thoi_khoa_bieu'] as List? ?? [];
          for (var schedule in schedules) {
            final soTiet = schedule['so_tiet'] as int? ?? 0;
            totalLessons += soTiet;
          }
        }
      }
    }
    
    return totalLessons;
  }

  /// Khởi tạo game lần đầu với số buổi nghỉ
  /// Returns: Map chứa rewards để hiển thị animation
  Future<Map<String, dynamic>> initializeGame({
    required String mssv,
    required int missedSessions, // Số buổi nghỉ (1 buổi = 4 tiết)
  }) async {
    isLoading.value = true;
    
    try {
      final totalLessons = calculateTotalLessons();
      final missedLessons = missedSessions * 4; // 1 buổi = 4 tiết
      final attendedLessons = (totalLessons - missedLessons).clamp(0, totalLessons);
      
      // ============ BẢNG THƯỞNG CHỐT HẠ ============
      // 1 buổi (4 tiết):
      //   - 1,000,000 coins (1M)
      //   - 5,000 XP
      //   - 1,650 diamonds (~11 lần quay gacha)
      //
      // 4 năm (~6000 tiết, chuyên cần >= 90%):
      //   - Coins: 2.25 TỶ
      //   - XP: 11.25M → Level ~1,500
      //   - Diamonds: 3.7M → ~24,700 lần quay
      //
      // Bonus chuyên cần: +50% (>=90%), +25% (>=80%)
      // =============================================
      final attendanceRate = totalLessons > 0 ? (attendedLessons / totalLessons) * 100 : 100.0;
      var earnedCoins = attendedLessons * 250000;
      var earnedDiamonds = attendedLessons * 413;
      var earnedXp = attendedLessons * 1250;
      
      if (attendanceRate >= 90) {
        earnedCoins = (earnedCoins * 1.5).round(); // Bonus 50%
        earnedDiamonds = (earnedDiamonds * 1.5).round(); // Bonus 50%
        earnedXp = (earnedXp * 1.5).round(); // Bonus 50%
      } else if (attendanceRate >= 80) {
        earnedCoins = (earnedCoins * 1.25).round(); // Bonus 25%
        earnedDiamonds = (earnedDiamonds * 1.25).round(); // Bonus 25%
        earnedXp = (earnedXp * 1.25).round(); // Bonus 25%
      }
      
      // Tính level từ XP (mỗi level cần level * 100 XP)
      int level = 1;
      int remainingXp = earnedXp;
      while (remainingXp >= level * 100) {
        remainingXp -= level * 100;
        level++;
      }
      
      // Cập nhật stats
      stats.value = PlayerStats(
        coins: earnedCoins,
        diamonds: earnedDiamonds,
        level: level,
        currentXp: remainingXp,
        totalLessonsAttended: attendedLessons,
        totalLessonsMissed: missedLessons,
        isInitialized: true,
      );
      
      await _saveLocalStats();
      await syncToFirebase(mssv);
      
      return {
        'totalLessons': totalLessons,
        'attendedLessons': attendedLessons,
        'missedLessons': missedLessons,
        'earnedCoins': earnedCoins,
        'earnedDiamonds': earnedDiamonds,
        'earnedXp': earnedXp,
        'level': level,
        'attendanceRate': stats.value.attendanceRate,
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Thêm coins
  Future<void> addCoins(int amount, String mssv) async {
    stats.value = stats.value.copyWith(
      coins: stats.value.coins + amount,
    );
    await _saveLocalStats();
    await syncToFirebase(mssv);
  }

  /// Thêm diamonds
  Future<void> addDiamonds(int amount, String mssv) async {
    stats.value = stats.value.copyWith(
      diamonds: stats.value.diamonds + amount,
    );
    await _saveLocalStats();
    await syncToFirebase(mssv);
  }

  /// Thêm XP và tự động lên level
  Future<Map<String, dynamic>> addXp(int amount, String mssv) async {
    int newXp = stats.value.currentXp + amount;
    int newLevel = stats.value.level;
    bool leveledUp = false;
    
    while (newXp >= newLevel * 100) {
      newXp -= newLevel * 100;
      newLevel++;
      leveledUp = true;
    }
    
    stats.value = stats.value.copyWith(
      currentXp: newXp,
      level: newLevel,
    );
    
    await _saveLocalStats();
    await syncToFirebase(mssv);
    
    return {
      'leveledUp': leveledUp,
      'newLevel': newLevel,
      'currentXp': newXp,
    };
  }

  /// Ghi nhận 1 buổi học (khi check-in hoặc hoàn thành)
  Future<Map<String, dynamic>> recordAttendance({
    required String mssv,
    required int lessons, // Số tiết
    required bool attended, // Có đi học không
  }) async {
    if (attended) {
      final earnedCoins = lessons * 10;
      final earnedXp = lessons * 5;
      
      stats.value = stats.value.copyWith(
        totalLessonsAttended: stats.value.totalLessonsAttended + lessons,
        coins: stats.value.coins + earnedCoins,
      );
      
      await _saveLocalStats();
      final xpResult = await addXp(earnedXp, mssv);
      
      return {
        'earnedCoins': earnedCoins,
        'earnedXp': earnedXp,
        ...xpResult,
      };
    } else {
      stats.value = stats.value.copyWith(
        totalLessonsMissed: stats.value.totalLessonsMissed + lessons,
      );
      await _saveLocalStats();
      await syncToFirebase(mssv);
      
      return {'earnedCoins': 0, 'earnedXp': 0};
    }
  }

  /// Reset game (cho testing)
  Future<void> resetGame() async {
    stats.value = const PlayerStats();
    await _prefs.remove(_statsKey);
  }
}
