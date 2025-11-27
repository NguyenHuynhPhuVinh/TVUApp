import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_stats.dart';
import 'local_storage_service.dart';

/// Service quản lý hệ thống game: coins, diamonds, level, XP
class GameService extends GetxService {
  late final SharedPreferences _prefs;
  late final FirebaseFirestore _firestore;
  
  static const String _statsKey = 'player_stats';
  
  final stats = PlayerStats().obs;
  final isLoading = false.obs;

  Future<GameService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _firestore = FirebaseFirestore.instance;
    await _loadLocalStats();
    return this;
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

  /// Sync stats lên Firebase
  Future<bool> syncToFirebase(String mssv) async {
    if (mssv.isEmpty) return false;
    
    try {
      await _firestore.collection('students').doc(mssv).set({
        'gameStats': stats.value.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error syncing game stats to Firebase: $e');
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
      
      // Tính rewards dựa trên số tiết đã học
      // 1 tiết = 10 coins + 5 XP
      // Bonus diamond mỗi 100 tiết
      final earnedCoins = attendedLessons * 10;
      final earnedXp = attendedLessons * 5;
      final earnedDiamonds = attendedLessons ~/ 100;
      
      // Tính level từ XP
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
