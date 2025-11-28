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

  /// Khởi tạo game lần đầu với số buổi nghỉ (tuân thủ 3 bước: security → local → firebase)
  /// Returns: Map chứa rewards để hiển thị animation, null nếu security fail
  Future<Map<String, dynamic>?> initializeGame({
    required String mssv,
    required int missedSessions, // Số buổi nghỉ (1 buổi = 4 tiết)
  }) async {
    isLoading.value = true;
    
    try {
      // 1. Security check
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) {
          debugPrint('⚠️ initializeGame blocked: Security issues detected');
          return null;
        }
      }
      
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
      
      // 2. Cập nhật stats (lưu thời điểm khởi tạo)
      stats.value = PlayerStats(
        coins: earnedCoins,
        diamonds: earnedDiamonds,
        level: level,
        currentXp: remainingXp,
        totalLessonsAttended: attendedLessons,
        totalLessonsMissed: missedLessons,
        isInitialized: true,
        initializedAt: DateTime.now(),
      );
      
      // 3. Lưu local
      await _saveLocalStats();
      
      // 4. Sync Firebase
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

  /// Thêm coins (tuân thủ 3 bước: security → local → firebase)
  Future<bool> addCoins(int amount, String mssv) async {
    // 1. Security check
    if (!isSecure.value) {
      await _checkSecurity();
      if (!isSecure.value) {
        debugPrint('⚠️ addCoins blocked: Security issues detected');
        return false;
      }
    }
    
    // 2. Cập nhật stats và lưu local
    stats.value = stats.value.copyWith(
      coins: stats.value.coins + amount,
    );
    await _saveLocalStats();
    
    // 3. Sync Firebase
    await syncToFirebase(mssv);
    return true;
  }

  /// Thêm diamonds (tuân thủ 3 bước: security → local → firebase)
  Future<bool> addDiamonds(int amount, String mssv) async {
    // 1. Security check
    if (!isSecure.value) {
      await _checkSecurity();
      if (!isSecure.value) {
        debugPrint('⚠️ addDiamonds blocked: Security issues detected');
        return false;
      }
    }
    
    // 2. Cập nhật stats và lưu local
    stats.value = stats.value.copyWith(
      diamonds: stats.value.diamonds + amount,
    );
    await _saveLocalStats();
    
    // 3. Sync Firebase
    await syncToFirebase(mssv);
    return true;
  }

  /// Thêm XP và tự động lên level (tuân thủ 3 bước: security → local → firebase)
  Future<Map<String, dynamic>?> addXp(int amount, String mssv) async {
    // 1. Security check
    if (!isSecure.value) {
      await _checkSecurity();
      if (!isSecure.value) {
        debugPrint('⚠️ addXp blocked: Security issues detected');
        return null;
      }
    }
    
    // 2. Tính toán và cập nhật stats
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
    
    // 3. Lưu local
    await _saveLocalStats();
    
    // 4. Sync Firebase
    await syncToFirebase(mssv);
    
    return {
      'leveledUp': leveledUp,
      'newLevel': newLevel,
      'currentXp': newXp,
    };
  }

  /// Ghi nhận 1 buổi học (tuân thủ 3 bước: security → local → firebase)
  Future<Map<String, dynamic>?> recordAttendance({
    required String mssv,
    required int lessons, // Số tiết
    required bool attended, // Có đi học không
  }) async {
    // 1. Security check
    if (!isSecure.value) {
      await _checkSecurity();
      if (!isSecure.value) {
        debugPrint('⚠️ recordAttendance blocked: Security issues detected');
        return null;
      }
    }
    
    if (attended) {
      final earnedCoins = lessons * 10;
      final earnedXp = lessons * 5;
      
      // 2. Tính XP và level
      int newXp = stats.value.currentXp + earnedXp;
      int newLevel = stats.value.level;
      bool leveledUp = false;
      
      while (newXp >= newLevel * 100) {
        newXp -= newLevel * 100;
        newLevel++;
        leveledUp = true;
      }
      
      // 3. Cập nhật stats
      stats.value = stats.value.copyWith(
        totalLessonsAttended: stats.value.totalLessonsAttended + lessons,
        coins: stats.value.coins + earnedCoins,
        currentXp: newXp,
        level: newLevel,
      );
      
      // 4. Lưu local
      await _saveLocalStats();
      
      // 5. Sync Firebase
      await syncToFirebase(mssv);
      
      return {
        'earnedCoins': earnedCoins,
        'earnedXp': earnedXp,
        'leveledUp': leveledUp,
        'newLevel': newLevel,
        'currentXp': newXp,
      };
    } else {
      // 2. Cập nhật stats (nghỉ học)
      stats.value = stats.value.copyWith(
        totalLessonsMissed: stats.value.totalLessonsMissed + lessons,
      );
      
      // 3. Lưu local
      await _saveLocalStats();
      
      // 4. Sync Firebase
      await syncToFirebase(mssv);
      
      return {'earnedCoins': 0, 'earnedXp': 0};
    }
  }

  /// Reset game (cho testing)
  Future<void> resetGame() async {
    stats.value = const PlayerStats();
    await _prefs.remove(_statsKey);
  }

  // ============ LESSON CHECK-IN SYSTEM ============
  
  /// Tính thời gian kết thúc buổi học dựa trên tiết bắt đầu và số tiết
  /// Sáng: 7h00 bắt đầu, mỗi tiết 45 phút
  /// Chiều: 13h00 bắt đầu
  /// Tối: 18h00 bắt đầu
  static DateTime calculateLessonEndTime(DateTime date, int tietBatDau, int soTiet) {
    int startHour;
    int startMinute = 0;
    
    // Xác định ca học và tiết bắt đầu trong ca
    if (tietBatDau <= 6) {
      // Ca sáng: tiết 1-6, bắt đầu 7h00
      startHour = 7;
      // Tính offset từ tiết 1
      final tietOffset = tietBatDau - 1;
      final totalMinutes = tietOffset * 45;
      startHour += totalMinutes ~/ 60;
      startMinute = totalMinutes % 60;
    } else if (tietBatDau <= 12) {
      // Ca chiều: tiết 7-12, bắt đầu 13h00
      startHour = 13;
      final tietOffset = tietBatDau - 7;
      final totalMinutes = tietOffset * 45;
      startHour += totalMinutes ~/ 60;
      startMinute = totalMinutes % 60;
    } else {
      // Ca tối: tiết 13+, bắt đầu 18h00
      startHour = 18;
      final tietOffset = tietBatDau - 13;
      final totalMinutes = tietOffset * 45;
      startHour += totalMinutes ~/ 60;
      startMinute = totalMinutes % 60;
    }
    
    // Tính thời gian kết thúc = thời gian bắt đầu + (số tiết * 45 phút)
    final startTime = DateTime(date.year, date.month, date.day, startHour, startMinute);
    final endTime = startTime.add(Duration(minutes: soTiet * 45));
    
    return endTime;
  }

  /// Kiểm tra có thể check-in buổi học không
  /// Chỉ được check-in sau khi buổi học kết thúc VÀ buổi học phải sau thời điểm khởi tạo game
  bool canCheckIn(DateTime lessonDate, int tietBatDau, int soTiet) {
    final now = DateTime.now();
    final endTime = calculateLessonEndTime(lessonDate, tietBatDau, soTiet);
    
    // Kiểm tra buổi học đã kết thúc chưa
    if (!now.isAfter(endTime)) return false;
    
    // Kiểm tra buổi học có sau thời điểm khởi tạo game không
    final initializedAt = stats.value.initializedAt;
    if (initializedAt != null) {
      // Buổi học phải kết thúc SAU thời điểm khởi tạo game
      if (endTime.isBefore(initializedAt)) return false;
    }
    
    return true;
  }

  /// Lấy thời gian còn lại đến khi có thể check-in
  /// Trả về null nếu đã có thể check-in hoặc buổi học trước thời điểm khởi tạo
  Duration? getTimeUntilCheckIn(DateTime lessonDate, int tietBatDau, int soTiet) {
    final now = DateTime.now();
    final endTime = calculateLessonEndTime(lessonDate, tietBatDau, soTiet);
    
    // Kiểm tra buổi học có sau thời điểm khởi tạo game không
    final initializedAt = stats.value.initializedAt;
    if (initializedAt != null && endTime.isBefore(initializedAt)) {
      return null; // Buổi học trước khi khởi tạo game, không thể check-in
    }
    
    if (now.isAfter(endTime)) return null;
    return endTime.difference(now);
  }

  /// Check-in buổi học và nhận thưởng
  /// Returns: Map chứa rewards, null nếu security check fail
  Future<Map<String, dynamic>?> checkInLesson({
    required String mssv,
    required int soTiet,
  }) async {
    // 1. Security check trước khi cho phép nhận thưởng
    if (!isSecure.value) {
      await _checkSecurity();
      if (!isSecure.value) {
        debugPrint('⚠️ Check-in blocked: Security issues detected');
        return null;
      }
    }
    
    // 2. Tính thưởng: mỗi tiết = 250,000 coins + 1,250 XP + 413 diamonds
    final earnedCoins = soTiet * 250000;
    final earnedXp = soTiet * 1250;
    final earnedDiamonds = soTiet * 413;
    
    // 3. Tính XP và level mới
    int newXp = stats.value.currentXp + earnedXp;
    int newLevel = stats.value.level;
    bool leveledUp = false;
    
    while (newXp >= newLevel * 100) {
      newXp -= newLevel * 100;
      newLevel++;
      leveledUp = true;
    }
    
    // 4. Cập nhật stats
    stats.value = stats.value.copyWith(
      coins: stats.value.coins + earnedCoins,
      diamonds: stats.value.diamonds + earnedDiamonds,
      currentXp: newXp,
      level: newLevel,
      totalLessonsAttended: stats.value.totalLessonsAttended + soTiet,
    );
    
    // 5. Lưu local
    await _saveLocalStats();
    
    // 6. Sync lên Firebase với signed data
    await syncToFirebase(mssv);
    
    return {
      'earnedCoins': earnedCoins,
      'earnedDiamonds': earnedDiamonds,
      'earnedXp': earnedXp,
      'soTiet': soTiet,
      'leveledUp': leveledUp,
      'newLevel': newLevel,
      'currentXp': newXp,
    };
  }
}
