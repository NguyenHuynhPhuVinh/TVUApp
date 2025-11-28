import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_stats.dart';
import '../models/wallet_transaction.dart';
import 'local_storage_service.dart';
import 'security_service.dart';

/// Service quản lý hệ thống game: coins, diamonds, level, XP
class GameService extends GetxService {
  late final SharedPreferences _prefs;
  late final FirebaseFirestore _firestore;
  late final SecurityService _security;
  
  static const String _statsKey = 'player_stats';
  static const String _transactionsKey = 'wallet_transactions';
  
  final stats = PlayerStats().obs;
  final transactions = <WalletTransaction>[].obs;
  final isLoading = false.obs;
  final isSecure = true.obs;
  final securityIssues = <String>[].obs;

  Future<GameService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _firestore = FirebaseFirestore.instance;
    _security = Get.find<SecurityService>();
    await _loadLocalStats();
    await _loadLocalTransactions();
    await _checkSecurity();
    return this;
  }

  /// Load transactions từ local storage
  Future<void> _loadLocalTransactions() async {
    final str = _prefs.getString(_transactionsKey);
    if (str != null) {
      final list = jsonDecode(str) as List;
      transactions.value = list.map((e) => WalletTransaction.fromJson(e)).toList();
    }
  }

  /// Lưu transactions vào local
  Future<void> _saveLocalTransactions() async {
    await _prefs.setString(
      _transactionsKey,
      jsonEncode(transactions.map((e) => e.toJson()).toList()),
    );
  }

  /// Thêm transaction mới
  Future<void> _addTransaction({
    required TransactionType type,
    required int amount,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final transaction = WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      description: description,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
    transactions.insert(0, transaction);
    await _saveLocalTransactions();
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
  /// Firebase là source of truth - luôn ưu tiên data từ Firebase
  /// SECURITY: Verify checksum trước khi accept data
  Future<bool> syncFromFirebase(String mssv) async {
    if (mssv.isEmpty) return false;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStatsData = doc.data()!['gameStats'] as Map<String, dynamic>;
        
        // SECURITY: Verify checksum nếu có
        // Nếu data có checksum nhưng không valid -> có thể bị tamper
        if (gameStatsData.containsKey('_checksum')) {
          final isValid = _security.verifySignedData(gameStatsData);
          if (!isValid) {
            debugPrint('⚠️ syncFromFirebase: Invalid checksum detected! Data may be tampered.');
            // Vẫn load data nhưng log warning (có thể do đổi device)
            // Trong production có thể block hoàn toàn
          }
        }
        
        final firebaseStats = PlayerStats.fromJson(gameStatsData);
        
        // Firebase là source of truth - luôn dùng data từ Firebase
        // Điều này ngăn chặn hack bằng cách xóa app data
        stats.value = firebaseStats;
        await _saveLocalStats();
        
        debugPrint('✅ Synced game stats from Firebase: Level ${firebaseStats.level}, Coins ${firebaseStats.coins}');
        return true;
      }
    } catch (e) {
      debugPrint('Error syncing game stats from Firebase: $e');
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

  // ============ SERVER TIME VALIDATION ============

  /// Lấy thời gian từ Firebase Server (chống hack đồng hồ)
  /// Sử dụng lastUpdated timestamp từ document của user
  /// Returns: DateTime từ server, null nếu lỗi hoặc chưa có data
  Future<DateTime?> getServerTime(String mssv) async {
    if (mssv.isEmpty) return null;

    try {
      // Cập nhật timestamp và đọc lại
      await _firestore.collection('students').doc(mssv).set({
        '_timeCheck': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final doc = await _firestore.collection('students').doc(mssv).get();
      final timestamp = doc.data()?['_timeCheck'] as Timestamp?;
      return timestamp?.toDate();
    } catch (e) {
      debugPrint('Error getting server time: $e');
      return null;
    }
  }

  /// So sánh thời gian local với server (cho phép sai lệch 5 phút)
  /// Returns: true nếu thời gian hợp lệ, false nếu bị chỉnh đồng hồ
  Future<bool> validateLocalTime(String mssv) async {
    final serverTime = await getServerTime(mssv);
    if (serverTime == null) {
      // Không lấy được server time -> cho phép (offline mode)
      debugPrint('⚠️ Cannot get server time, allowing local time');
      return true;
    }

    final localTime = DateTime.now();
    final difference = localTime.difference(serverTime).abs();
    final maxDifference = const Duration(minutes: 5);

    if (difference > maxDifference) {
      debugPrint(
          '⚠️ Time manipulation detected! Local: $localTime, Server: $serverTime, Diff: ${difference.inMinutes} minutes');
      return false;
    }

    return true;
  }

  // ============ FIREBASE VALIDATION ============

  /// Kiểm tra đã khởi tạo game trên Firebase chưa
  /// SECURITY: Ngăn chặn init nhiều lần để nhận rewards duplicate
  Future<bool> _checkAlreadyInitializedOnFirebase(String mssv) async {
    // SECURITY: Nếu không có mssv, block init (return true = đã init)
    if (mssv.isEmpty) return true;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
        return gameStats['isInitialized'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking initialized on Firebase: $e');
      // Nếu lỗi, return true để block init (an toàn hơn)
      return true;
    }
  }

  // ============ CHECK-IN SYNC ============

  /// Lưu check-in lên Firebase
  Future<bool> saveCheckInToFirebase({
    required String mssv,
    required String checkInKey,
    required Map<String, dynamic> checkInData,
  }) async {
    if (mssv.isEmpty) return false;
    
    try {
      await _firestore
          .collection('students')
          .doc(mssv)
          .collection('checkIns')
          .doc(checkInKey)
          .set({
        ...checkInData,
        'syncedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving check-in to Firebase: $e');
      return false;
    }
  }

  /// Lấy danh sách check-ins từ Firebase
  Future<Map<String, dynamic>> getCheckInsFromFirebase(String mssv) async {
    if (mssv.isEmpty) return {};
    
    try {
      final snapshot = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('checkIns')
          .get();
      
      final checkIns = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        checkIns[doc.id] = doc.data();
      }
      return checkIns;
    } catch (e) {
      debugPrint('Error getting check-ins from Firebase: $e');
      return {};
    }
  }

  /// Kiểm tra đã check-in trên Firebase chưa
  Future<bool> hasCheckedInOnFirebase(String mssv, String checkInKey) async {
    if (mssv.isEmpty) return false;
    
    try {
      final doc = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('checkIns')
          .doc(checkInKey)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking check-in on Firebase: $e');
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
  /// 
  /// SECURITY: Chỉ cho phép init 1 lần duy nhất
  Future<Map<String, dynamic>?> initializeGame({
    required String mssv,
    required int missedSessions, // Số buổi nghỉ (1 buổi = 4 tiết)
  }) async {
    isLoading.value = true;
    
    try {
      // ========== BƯỚC 0: CHECK ĐÃ INIT CHƯA (Firebase là source of truth) ==========
      // CRITICAL: Ngăn chặn init nhiều lần để nhận rewards duplicate
      final alreadyInitialized = await _checkAlreadyInitializedOnFirebase(mssv);
      if (alreadyInitialized) {
        debugPrint('⚠️ initializeGame blocked: Already initialized on Firebase');
        // Sync lại từ Firebase để đảm bảo data đúng
        await syncFromFirebase(mssv);
        return null;
      }
      
      // Double check local (backup)
      if (stats.value.isInitialized) {
        debugPrint('⚠️ initializeGame blocked: Already initialized locally');
        return null;
      }
      
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
      // 1 tiết:
      //   - 250,000 coins
      //   - 2,500 XP
      //   - 413 diamonds
      //
      // 1 buổi (4 tiết):
      //   - 1,000,000 coins (1M)
      //   - 10,000 XP
      //   - 1,652 diamonds (~11 lần quay gacha)
      //
      // 4 năm (~6000 tiết, chuyên cần >= 90%):
      //   - Coins: 2.25 TỶ
      //   - XP: 22.5M → Level ~2,100
      //   - Diamonds: 3.7M → ~24,700 lần quay
      //
      // Bonus chuyên cần: +50% (>=90%), +25% (>=80%)
      // =============================================
      final attendanceRate = totalLessons > 0 ? (attendedLessons / totalLessons) * 100 : 100.0;
      var earnedCoins = attendedLessons * 250000;
      var earnedDiamonds = attendedLessons * 413;
      var earnedXp = attendedLessons * 2500;
      
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
  /// SECURITY: Validate amount > 0
  Future<bool> addCoins(int amount, String mssv) async {
    // 0. Validate amount - ngăn chặn số âm
    if (amount <= 0) {
      debugPrint('⚠️ addCoins blocked: Invalid amount $amount');
      return false;
    }
    
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
  /// SECURITY: Validate amount > 0
  Future<bool> addDiamonds(int amount, String mssv) async {
    // 0. Validate amount - ngăn chặn số âm
    if (amount <= 0) {
      debugPrint('⚠️ addDiamonds blocked: Invalid amount $amount');
      return false;
    }
    
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
  /// SECURITY: Validate amount > 0
  Future<Map<String, dynamic>?> addXp(int amount, String mssv) async {
    // 0. Validate amount - ngăn chặn số âm
    if (amount <= 0) {
      debugPrint('⚠️ addXp blocked: Invalid amount $amount');
      return null;
    }
    
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
  /// SECURITY: Validate lessons và check security
  Future<Map<String, dynamic>?> recordAttendance({
    required String mssv,
    required int lessons, // Số tiết
    required bool attended, // Có đi học không
  }) async {
    // 0. Validate lessons - ngăn chặn giá trị bất thường
    if (lessons <= 0 || lessons > 12) { // Max 12 tiết/buổi
      debugPrint('⚠️ recordAttendance blocked: Invalid lessons $lessons');
      return null;
    }
    
    // 1. Security check
    if (!isSecure.value) {
      await _checkSecurity();
      if (!isSecure.value) {
        debugPrint('⚠️ recordAttendance blocked: Security issues detected');
        return null;
      }
    }
    
    if (attended) {
      // Tính thưởng: mỗi tiết = 250,000 coins + 2,500 XP + 413 diamonds
      final earnedCoins = lessons * 250000;
      final earnedXp = lessons * 2500;
      final earnedDiamonds = lessons * 413;
      
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
        diamonds: stats.value.diamonds + earnedDiamonds,
        currentXp: newXp,
        level: newLevel,
      );
      
      // 4. Lưu local
      await _saveLocalStats();
      
      // 5. Sync Firebase
      await syncToFirebase(mssv);
      
      return {
        'earnedCoins': earnedCoins,
        'earnedDiamonds': earnedDiamonds,
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
    transactions.clear();
    await _prefs.remove(_statsKey);
    await _prefs.remove(_transactionsKey);
  }

  // ============ TUITION BONUS SYSTEM ============

  /// Tính tiền ảo từ học phí đã đóng
  /// Quy đổi: 1 VND = 1 tiền ảo (1:1)
  int calculateVirtualBalanceFromTuition(int tuitionPaid) {
    return tuitionPaid;
  }

  /// Kiểm tra đã nhận bonus học phí trên Firebase chưa
  Future<bool> _checkTuitionBonusClaimedOnFirebase(String mssv) async {
    if (mssv.isEmpty) return true;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
        return gameStats['tuitionBonusClaimed'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking tuition bonus on Firebase: $e');
      return true; // Block nếu lỗi (an toàn hơn)
    }
  }

  /// Nhận bonus từ học phí đã đóng
  /// Flow: Check Firebase → Validate → Update local → Sync Firebase
  Future<Map<String, dynamic>?> claimTuitionBonus({
    required String mssv,
    required int tuitionPaid, // Số tiền đã đóng (VND)
  }) async {
    isLoading.value = true;
    
    try {
      // 1. Check đã claim trên Firebase chưa
      final alreadyClaimed = await _checkTuitionBonusClaimedOnFirebase(mssv);
      if (alreadyClaimed || stats.value.tuitionBonusClaimed) {
        debugPrint('⚠️ claimTuitionBonus blocked: Already claimed');
        return null;
      }
      
      // 2. Security check
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) {
          debugPrint('⚠️ claimTuitionBonus blocked: Security issues');
          return null;
        }
      }
      
      // 3. Validate amount
      if (tuitionPaid <= 0) {
        debugPrint('⚠️ claimTuitionBonus blocked: Invalid amount');
        return null;
      }
      
      // 4. Tính tiền ảo
      final virtualBalance = calculateVirtualBalanceFromTuition(tuitionPaid);
      
      // 5. Update stats
      stats.value = stats.value.copyWith(
        virtualBalance: virtualBalance,
        totalTuitionPaid: tuitionPaid,
        tuitionBonusClaimed: true,
      );
      
      // 6. Lưu local
      await _saveLocalStats();
      
      // 7. Thêm transaction
      await _addTransaction(
        type: TransactionType.tuitionBonus,
        amount: virtualBalance,
        description: 'Nhận thưởng từ học phí đã đóng',
        metadata: {'tuitionPaid': tuitionPaid},
      );
      
      // 8. Sync Firebase
      await syncToFirebase(mssv);
      
      return {
        'tuitionPaid': tuitionPaid,
        'virtualBalance': virtualBalance,
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Kiểm tra học kỳ đã claim trên Firebase chưa
  Future<bool> _checkSemesterClaimedOnFirebase(String mssv, String semesterId) async {
    if (mssv.isEmpty) return true;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
        // Nếu đã claim full thì tất cả học kỳ đều đã claim
        if (gameStats['tuitionBonusClaimed'] == true) return true;
        final claimed = gameStats['claimedTuitionSemesters'] as List? ?? [];
        return claimed.contains(semesterId);
      }
      return false;
    } catch (e) {
      debugPrint('Error checking semester claimed on Firebase: $e');
      return true; // Block nếu lỗi
    }
  }

  /// Nhận bonus từ học phí theo từng học kỳ
  /// Flow: Check Firebase → Validate → Update local → Sync Firebase
  Future<Map<String, dynamic>?> claimTuitionBonusBySemester({
    required String mssv,
    required String semesterId, // ID học kỳ (ten_hoc_ky)
    required int tuitionPaid, // Số tiền đã đóng học kỳ này (VND)
  }) async {
    isLoading.value = true;
    
    try {
      // 1. Check đã claim học kỳ này chưa (Firebase là source of truth)
      final alreadyClaimed = await _checkSemesterClaimedOnFirebase(mssv, semesterId);
      if (alreadyClaimed || stats.value.isSemesterClaimed(semesterId)) {
        debugPrint('⚠️ claimTuitionBonusBySemester blocked: Semester $semesterId already claimed');
        return null;
      }
      
      // 2. Security check
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) {
          debugPrint('⚠️ claimTuitionBonusBySemester blocked: Security issues');
          return null;
        }
      }
      
      // 3. Validate amount
      if (tuitionPaid <= 0) {
        debugPrint('⚠️ claimTuitionBonusBySemester blocked: Invalid amount');
        return null;
      }
      
      // 4. Tính tiền ảo (1:1)
      final bonusAmount = calculateVirtualBalanceFromTuition(tuitionPaid);
      
      // 5. Update stats
      final newClaimedSemesters = [...stats.value.claimedTuitionSemesters, semesterId];
      stats.value = stats.value.copyWith(
        virtualBalance: stats.value.virtualBalance + bonusAmount,
        totalTuitionPaid: stats.value.totalTuitionPaid + tuitionPaid,
        claimedTuitionSemesters: newClaimedSemesters,
      );
      
      // 6. Lưu local
      await _saveLocalStats();
      
      // 7. Thêm transaction
      await _addTransaction(
        type: TransactionType.tuitionBonus,
        amount: bonusAmount,
        description: 'Nhận thưởng học phí $semesterId',
        metadata: {'semesterId': semesterId, 'tuitionPaid': tuitionPaid},
      );
      
      // 8. Sync Firebase
      await syncToFirebase(mssv);
      
      return {
        'semesterId': semesterId,
        'tuitionPaid': tuitionPaid,
        'virtualBalance': bonusAmount,
      };
    } finally {
      isLoading.value = false;
    }
  }

  // ============ DIAMOND SHOP ============

  bool _isBuyingDiamonds = false; // Lock ngăn race condition

  /// Mua diamond bằng tiền ảo
  /// Tỷ giá chuẩn game online: giá theo gói, gói lớn có bonus
  Future<Map<String, dynamic>?> buyDiamonds({
    required String mssv,
    required int diamondAmount,
    required int cost, // Giá tiền ảo
  }) async {
    // 0. Check lock - ngăn double click
    if (_isBuyingDiamonds) {
      debugPrint('⚠️ buyDiamonds blocked: Already processing');
      return null;
    }
    _isBuyingDiamonds = true;
    isLoading.value = true;
    
    try {
      // 1. Security check
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) return null;
      }
      
      // 2. Validate input
      if (diamondAmount <= 0 || cost <= 0) return null;
      
      if (stats.value.virtualBalance < cost) {
        debugPrint('⚠️ buyDiamonds blocked: Insufficient balance');
        return null;
      }
      
      // 3. Update stats (local cache)
      stats.value = stats.value.copyWith(
        virtualBalance: stats.value.virtualBalance - cost,
        diamonds: stats.value.diamonds + diamondAmount,
      );
      
      // 4. Lưu local
      await _saveLocalStats();
      
      // 5. Thêm transaction
      await _addTransaction(
        type: TransactionType.buyDiamond,
        amount: -cost,
        description: 'Mua $diamondAmount diamond',
        metadata: {'diamonds': diamondAmount, 'cost': cost},
      );
      
      // 6. Sync Firebase (source of truth)
      await syncToFirebase(mssv);
      
      return {
        'diamondAmount': diamondAmount,
        'cost': cost,
        'newBalance': stats.value.virtualBalance,
        'newDiamonds': stats.value.diamonds,
      };
    } finally {
      _isBuyingDiamonds = false; // Release lock
      isLoading.value = false;
    }
  }

  // ============ COIN SHOP ============

  bool _isBuyingCoins = false; // Lock ngăn race condition

  /// Mua coin bằng diamond
  /// Tỷ giá: 1 diamond = 10,000 coins
  Future<Map<String, dynamic>?> buyCoins({
    required String mssv,
    required int diamondAmount,
  }) async {
    // 0. Check lock - ngăn double click
    if (_isBuyingCoins) {
      debugPrint('⚠️ buyCoins blocked: Already processing');
      return null;
    }
    _isBuyingCoins = true;
    isLoading.value = true;
    
    try {
      // 1. Security check
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) return null;
      }
      
      // 2. Validate input
      if (diamondAmount <= 0) return null;
      if (stats.value.diamonds < diamondAmount) {
        debugPrint('⚠️ buyCoins blocked: Insufficient diamonds');
        return null;
      }
      
      final coinAmount = diamondAmount * 10000; // 1 diamond = 10,000 coins
      
      // 3. Update stats (local cache)
      stats.value = stats.value.copyWith(
        diamonds: stats.value.diamonds - diamondAmount,
        coins: stats.value.coins + coinAmount,
      );
      
      // 4. Lưu local
      await _saveLocalStats();
      
      // 5. Thêm transaction
      await _addTransaction(
        type: TransactionType.buyCoin,
        amount: coinAmount,
        description: 'Đổi $diamondAmount diamond lấy ${coinAmount ~/ 1000}K coins',
        metadata: {'diamonds': diamondAmount, 'coins': coinAmount},
      );
      
      // 6. Sync Firebase (source of truth)
      await syncToFirebase(mssv);
      
      return {
        'diamondAmount': diamondAmount,
        'coinAmount': coinAmount,
        'newDiamonds': stats.value.diamonds,
        'newCoins': stats.value.coins,
      };
    } finally {
      _isBuyingCoins = false; // Release lock
      isLoading.value = false;
    }
  }

  // ============ LESSON CHECK-IN SYSTEM ============
  
  /// Thời gian cho phép điểm danh trước giờ học (30 phút)
  static const Duration checkInEarlyWindow = Duration(minutes: 30);
  
  /// Tính thời gian bắt đầu buổi học dựa trên tiết bắt đầu
  /// Sáng: 7h00 bắt đầu, mỗi tiết 45 phút
  /// Chiều: 13h00 bắt đầu
  /// Tối: 18h00 bắt đầu
  static DateTime calculateLessonStartTime(DateTime date, int tietBatDau) {
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
    
    return DateTime(date.year, date.month, date.day, startHour, startMinute);
  }
  
  /// Tính thời gian kết thúc buổi học dựa trên tiết bắt đầu và số tiết
  /// Sáng: 7h00 bắt đầu, mỗi tiết 45 phút
  /// Chiều: 13h00 bắt đầu
  /// Tối: 18h00 bắt đầu
  static DateTime calculateLessonEndTime(DateTime date, int tietBatDau, int soTiet) {
    final startTime = calculateLessonStartTime(date, tietBatDau);
    // Tính thời gian kết thúc = thời gian bắt đầu + (số tiết * 45 phút)
    return startTime.add(Duration(minutes: soTiet * 45));
  }
  
  /// Tính thời gian có thể bắt đầu điểm danh (30 phút trước giờ học)
  static DateTime calculateCheckInStartTime(DateTime date, int tietBatDau) {
    final lessonStart = calculateLessonStartTime(date, tietBatDau);
    return lessonStart.subtract(checkInEarlyWindow);
  }
  
  /// Tính deadline điểm danh (23:59:59 ngày hôm đó)
  static DateTime calculateCheckInDeadline(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Kiểm tra có thể check-in buổi học không
  /// Được check-in từ 30 phút trước giờ học đến hết ngày hôm đó
  /// VÀ buổi học phải sau thời điểm khởi tạo game
  /// 
  /// SECURITY: Kiểm tra cả thời gian local và initializedAt
  bool canCheckIn(DateTime lessonDate, int tietBatDau, int soTiet) {
    final now = DateTime.now();
    final checkInStart = calculateCheckInStartTime(lessonDate, tietBatDau);
    final checkInDeadline = calculateCheckInDeadline(lessonDate);
    final endTime = calculateLessonEndTime(lessonDate, tietBatDau, soTiet);
    
    // Kiểm tra đã đến thời gian điểm danh chưa (30p trước giờ học)
    if (now.isBefore(checkInStart)) return false;
    
    // Kiểm tra đã qua deadline chưa (hết ngày hôm đó)
    if (now.isAfter(checkInDeadline)) return false;
    
    // SECURITY: Buổi học phải kết thúc SAU thời điểm khởi tạo game
    // Ngăn chặn check-in các buổi học trong quá khứ (trước khi init game)
    final initializedAt = stats.value.initializedAt;
    if (initializedAt != null) {
      if (endTime.isBefore(initializedAt)) return false;
    }
    
    return true;
  }

  /// Lấy thời gian còn lại đến khi có thể check-in
  /// Trả về null nếu đã có thể check-in, đã quá deadline, hoặc buổi học trước thời điểm khởi tạo
  Duration? getTimeUntilCheckIn(DateTime lessonDate, int tietBatDau, int soTiet) {
    final now = DateTime.now();
    final checkInStart = calculateCheckInStartTime(lessonDate, tietBatDau);
    final checkInDeadline = calculateCheckInDeadline(lessonDate);
    final endTime = calculateLessonEndTime(lessonDate, tietBatDau, soTiet);
    
    // SECURITY: Buổi học phải sau thời điểm khởi tạo game
    final initializedAt = stats.value.initializedAt;
    if (initializedAt != null && endTime.isBefore(initializedAt)) {
      return null; // Buổi học trước khi khởi tạo game, không thể check-in
    }
    
    // Đã quá deadline
    if (now.isAfter(checkInDeadline)) return null;
    
    // Đã có thể check-in
    if (now.isAfter(checkInStart) || now.isAtSameMomentAs(checkInStart)) return null;
    
    return checkInStart.difference(now);
  }

  /// Check-in buổi học và nhận thưởng
  /// Returns: Map chứa rewards, null nếu security check fail
  /// 
  /// SECURITY: Validate soTiet và check security
  Future<Map<String, dynamic>?> checkInLesson({
    required String mssv,
    required int soTiet,
  }) async {
    // 0. Validate soTiet - ngăn chặn giá trị bất thường
    if (soTiet <= 0 || soTiet > 12) { // Max 12 tiết/buổi
      debugPrint('⚠️ Check-in blocked: Invalid soTiet $soTiet');
      return null;
    }
    
    // 1. Security check trước khi cho phép nhận thưởng
    if (!isSecure.value) {
      await _checkSecurity();
      if (!isSecure.value) {
        debugPrint('⚠️ Check-in blocked: Security issues detected');
        return null;
      }
    }
    
    // 2. Tính thưởng: mỗi tiết = 250,000 coins + 2,500 XP + 413 diamonds
    final earnedCoins = soTiet * 250000;
    final earnedXp = soTiet * 2500;
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

  // ============ SUBJECT REWARD SYSTEM (CTDT) ============

  /// Tính reward cho môn học đạt dựa trên số tín chỉ
  /// 1 TC = 15 tiết LT + 30 tiết TH = 45 tiết
  /// 1 TC = 45 × (250,000 coins + 2,500 XP + 413 diamonds)
  /// = 11,250,000 coins + 112,500 XP + 18,585 diamonds
  /// 4 năm (~140 TC): 1.575 TỶ coins + 15.75M XP + 2.6M diamonds
  static Map<String, int> calculateSubjectReward(int soTinChi) {
    return {
      'coins': soTinChi * 11250000,
      'xp': soTinChi * 112500,
      'diamonds': soTinChi * 18585,
    };
  }

  /// Kiểm tra môn học đã claim trên Firebase chưa
  Future<bool> _checkSubjectClaimedOnFirebase(String mssv, String maMon) async {
    if (mssv.isEmpty) return true;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
        final claimed = gameStats['claimedSubjects'] as List? ?? [];
        return claimed.contains(maMon);
      }
      return false;
    } catch (e) {
      debugPrint('Error checking subject claimed on Firebase: $e');
      return true; // Block nếu lỗi (an toàn hơn)
    }
  }

  bool _isClaimingSubject = false; // Lock ngăn race condition

  /// Nhận reward cho môn học đạt trong CTDT
  /// Flow: Check Firebase → Security → Validate → Update local → Sync Firebase
  Future<Map<String, dynamic>?> claimSubjectReward({
    required String mssv,
    required String maMon,
    required String tenMon,
    required int soTinChi,
  }) async {
    // 0. Check lock - ngăn double click
    if (_isClaimingSubject) {
      debugPrint('⚠️ claimSubjectReward blocked: Already processing');
      return null;
    }
    _isClaimingSubject = true;
    isLoading.value = true;
    
    try {
      // 1. Check đã claim trên Firebase chưa (source of truth)
      final alreadyClaimed = await _checkSubjectClaimedOnFirebase(mssv, maMon);
      if (alreadyClaimed || stats.value.isSubjectClaimed(maMon)) {
        debugPrint('⚠️ claimSubjectReward blocked: Subject $maMon already claimed');
        return null;
      }
      
      // 2. Security check
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) {
          debugPrint('⚠️ claimSubjectReward blocked: Security issues');
          return null;
        }
      }
      
      // 3. Validate input
      if (soTinChi <= 0 || soTinChi > 20) {
        debugPrint('⚠️ claimSubjectReward blocked: Invalid soTinChi $soTinChi');
        return null;
      }
      
      // 4. Tính reward
      final reward = calculateSubjectReward(soTinChi);
      final earnedCoins = reward['coins']!;
      final earnedXp = reward['xp']!;
      final earnedDiamonds = reward['diamonds']!;
      
      // 5. Tính XP và level mới
      int newXp = stats.value.currentXp + earnedXp;
      int newLevel = stats.value.level;
      bool leveledUp = false;
      
      while (newXp >= newLevel * 100) {
        newXp -= newLevel * 100;
        newLevel++;
        leveledUp = true;
      }
      
      // 6. Update stats
      final newClaimedSubjects = [...stats.value.claimedSubjects, maMon];
      stats.value = stats.value.copyWith(
        coins: stats.value.coins + earnedCoins,
        diamonds: stats.value.diamonds + earnedDiamonds,
        currentXp: newXp,
        level: newLevel,
        claimedSubjects: newClaimedSubjects,
      );
      
      // 7. Lưu local
      await _saveLocalStats();
      
      // 8. Sync Firebase (không thêm transaction vì không liên quan TVUCash)
      await syncToFirebase(mssv);
      
      return {
        'maMon': maMon,
        'tenMon': tenMon,
        'soTinChi': soTinChi,
        'earnedCoins': earnedCoins,
        'earnedDiamonds': earnedDiamonds,
        'earnedXp': earnedXp,
        'leveledUp': leveledUp,
        'newLevel': newLevel,
      };
    } finally {
      _isClaimingSubject = false; // Release lock
      isLoading.value = false;
    }
  }

  /// Kiểm tra môn học đã claim chưa (local check)
  bool isSubjectClaimed(String maMon) {
    return stats.value.isSubjectClaimed(maMon);
  }

  /// Nhận reward cho nhiều môn học cùng lúc (batch)
  /// Chỉ sync Firebase 1 lần cuối để tăng tốc
  Future<Map<String, dynamic>?> claimAllSubjectRewards({
    required String mssv,
    required List<Map<String, dynamic>> subjects, // [{maMon, tenMon, soTinChi}]
  }) async {
    if (_isClaimingSubject) return null;
    if (subjects.isEmpty) return null;
    
    _isClaimingSubject = true;
    isLoading.value = true;
    
    try {
      // 1. Security check 1 lần
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) return null;
      }
      
      // 2. Lấy danh sách đã claim từ Firebase 1 lần
      Set<String> claimedOnFirebase = {};
      try {
        final doc = await _firestore.collection('students').doc(mssv).get();
        if (doc.exists && doc.data()?['gameStats'] != null) {
          final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
          final claimed = gameStats['claimedSubjects'] as List? ?? [];
          claimedOnFirebase = claimed.map((e) => e.toString()).toSet();
        }
      } catch (e) {
        debugPrint('Error fetching claimed subjects: $e');
      }
      
      // 3. Tính tổng reward và lọc môn chưa claim
      int totalCoins = 0;
      int totalDiamonds = 0;
      int totalXp = 0;
      List<String> newClaimedSubjects = [...stats.value.claimedSubjects];
      int claimedCount = 0;
      
      for (var subject in subjects) {
        final maMon = subject['maMon'] as String? ?? '';
        final soTinChi = subject['soTinChi'] as int? ?? 0;
        
        // Skip nếu đã claim
        if (maMon.isEmpty || soTinChi <= 0) continue;
        if (claimedOnFirebase.contains(maMon)) continue;
        if (newClaimedSubjects.contains(maMon)) continue;
        
        // Tính reward
        final reward = calculateSubjectReward(soTinChi);
        totalCoins += reward['coins']!;
        totalDiamonds += reward['diamonds']!;
        totalXp += reward['xp']!;
        newClaimedSubjects.add(maMon);
        claimedCount++;
      }
      
      if (claimedCount == 0) return null;
      
      // 4. Tính level mới
      int newXp = stats.value.currentXp + totalXp;
      int newLevel = stats.value.level;
      bool leveledUp = false;
      
      while (newXp >= newLevel * 100) {
        newXp -= newLevel * 100;
        newLevel++;
        leveledUp = true;
      }
      
      // 5. Update stats 1 lần
      stats.value = stats.value.copyWith(
        coins: stats.value.coins + totalCoins,
        diamonds: stats.value.diamonds + totalDiamonds,
        currentXp: newXp,
        level: newLevel,
        claimedSubjects: newClaimedSubjects,
      );
      
      // 6. Lưu local 1 lần
      await _saveLocalStats();
      
      // 7. Sync Firebase 1 lần
      await syncToFirebase(mssv);
      
      return {
        'claimedCount': claimedCount,
        'earnedCoins': totalCoins,
        'earnedDiamonds': totalDiamonds,
        'earnedXp': totalXp,
        'leveledUp': leveledUp,
        'newLevel': newLevel,
      };
    } finally {
      _isClaimingSubject = false;
      isLoading.value = false;
    }
  }

  // ============ RANK REWARD SYSTEM ============

  bool _isClaimingRankReward = false; // Lock ngăn race condition

  /// Tính reward cho rank dựa trên tier và level (GPA-based)
  /// Rank càng cao (GPA càng cao) → reward tăng CỰC MẠNH (3^tierIndex)
  /// 
  /// 8 tiers: Wood → Stone → Bronze → Silver → Gold → Platinum → Amethyst → Onyx
  /// Mỗi tier có 7 levels (I → VII)
  /// 
  /// Base reward (Wood I): 10M coins + 41,300 diamonds
  /// Tier multiplier: 3^tierIndex (1, 3, 9, 27, 81, 243, 729, 2187)
  /// Level bonus: +100% mỗi level
  /// 
  /// Ví dụ:
  /// - Wood I (rank 0): 10M coins, 41K diamonds
  /// - Bronze I (rank 14): 90M coins, 372K diamonds
  /// - Gold I (rank 28): 810M coins, 3.3M diamonds
  /// - Onyx I (rank 49): 21.87 TỶ coins, 90M diamonds
  /// - Onyx VII (rank 55): 153 TỶ coins, 634M diamonds 🔥
  static Map<String, int> calculateRankReward(int rankIndex) {
    final tierIndex = rankIndex ~/ 7;
    final level = (rankIndex % 7) + 1;
    
    // SUPER Exponential tier multiplier: 3^tierIndex
    // Wood=1, Stone=3, Bronze=9, Silver=27, Gold=81, Platinum=243, Amethyst=729, Onyx=2187
    int tierMultiplier = 1;
    for (int i = 0; i < tierIndex; i++) {
      tierMultiplier *= 3;
    }
    
    final baseCoins = 10000000 * tierMultiplier; // 10M base
    final baseDiamonds = 41300 * tierMultiplier; // 41.3K base
    
    // Level bonus: +100% mỗi level (1x, 2x, 3x, 4x, 5x, 6x, 7x)
    final levelMultiplier = level.toDouble();
    
    return {
      'coins': (baseCoins * levelMultiplier).round(),
      'diamonds': (baseDiamonds * levelMultiplier).round(),
    };
  }

  /// Kiểm tra rank đã claim trên Firebase chưa
  Future<bool> _checkRankClaimedOnFirebase(String mssv, int rankIndex) async {
    if (mssv.isEmpty) return true;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
        final claimed = gameStats['claimedRankRewards'] as List? ?? [];
        return claimed.contains(rankIndex);
      }
      return false;
    } catch (e) {
      debugPrint('Error checking rank claimed on Firebase: $e');
      return true; // Block nếu lỗi (an toàn hơn)
    }
  }

  /// Nhận reward cho 1 rank
  /// Flow: Check Firebase → Security → Validate → Update local → Sync Firebase
  Future<Map<String, dynamic>?> claimRankReward({
    required String mssv,
    required int rankIndex,
    required int currentRankIndex, // Rank hiện tại của user
  }) async {
    // 0. Check lock - ngăn double click
    if (_isClaimingRankReward) {
      debugPrint('⚠️ claimRankReward blocked: Already processing');
      return null;
    }
    _isClaimingRankReward = true;
    isLoading.value = true;
    
    try {
      // 1. Validate: chỉ claim được rank đã đạt
      if (rankIndex > currentRankIndex) {
        debugPrint('⚠️ claimRankReward blocked: Rank $rankIndex not unlocked');
        return null;
      }
      
      // 2. Check đã claim trên Firebase chưa (source of truth)
      final alreadyClaimed = await _checkRankClaimedOnFirebase(mssv, rankIndex);
      if (alreadyClaimed || stats.value.isRankClaimed(rankIndex)) {
        debugPrint('⚠️ claimRankReward blocked: Rank $rankIndex already claimed');
        return null;
      }
      
      // 3. Security check
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) {
          debugPrint('⚠️ claimRankReward blocked: Security issues');
          return null;
        }
      }
      
      // 4. Tính reward
      final reward = calculateRankReward(rankIndex);
      final earnedCoins = reward['coins']!;
      final earnedDiamonds = reward['diamonds']!;
      
      // 5. Update stats
      final newClaimedRanks = [...stats.value.claimedRankRewards, rankIndex];
      stats.value = stats.value.copyWith(
        coins: stats.value.coins + earnedCoins,
        diamonds: stats.value.diamonds + earnedDiamonds,
        claimedRankRewards: newClaimedRanks,
      );
      
      // 6. Lưu local
      await _saveLocalStats();
      
      // 7. Sync Firebase
      await syncToFirebase(mssv);
      
      return {
        'rankIndex': rankIndex,
        'earnedCoins': earnedCoins,
        'earnedDiamonds': earnedDiamonds,
      };
    } finally {
      _isClaimingRankReward = false;
      isLoading.value = false;
    }
  }

  /// Nhận reward cho tất cả rank đã đạt nhưng chưa claim
  /// Chỉ sync Firebase 1 lần cuối để tăng tốc
  Future<Map<String, dynamic>?> claimAllRankRewards({
    required String mssv,
    required int currentRankIndex,
  }) async {
    if (_isClaimingRankReward) return null;
    
    _isClaimingRankReward = true;
    isLoading.value = true;
    
    try {
      // 1. Security check 1 lần
      if (!isSecure.value) {
        await _checkSecurity();
        if (!isSecure.value) return null;
      }
      
      // 2. Lấy danh sách đã claim từ Firebase 1 lần
      Set<int> claimedOnFirebase = {};
      try {
        final doc = await _firestore.collection('students').doc(mssv).get();
        if (doc.exists && doc.data()?['gameStats'] != null) {
          final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
          final claimed = gameStats['claimedRankRewards'] as List? ?? [];
          claimedOnFirebase = claimed.map((e) => e as int).toSet();
        }
      } catch (e) {
        debugPrint('Error fetching claimed ranks: $e');
      }
      
      // 3. Tính tổng reward và lọc rank chưa claim
      int totalCoins = 0;
      int totalDiamonds = 0;
      List<int> newClaimedRanks = [...stats.value.claimedRankRewards];
      int claimedCount = 0;
      
      for (int i = 0; i <= currentRankIndex; i++) {
        // Skip nếu đã claim
        if (claimedOnFirebase.contains(i)) continue;
        if (newClaimedRanks.contains(i)) continue;
        
        // Tính reward
        final reward = calculateRankReward(i);
        totalCoins += reward['coins']!;
        totalDiamonds += reward['diamonds']!;
        newClaimedRanks.add(i);
        claimedCount++;
      }
      
      if (claimedCount == 0) return null;
      
      // 4. Update stats 1 lần
      stats.value = stats.value.copyWith(
        coins: stats.value.coins + totalCoins,
        diamonds: stats.value.diamonds + totalDiamonds,
        claimedRankRewards: newClaimedRanks,
      );
      
      // 5. Lưu local 1 lần
      await _saveLocalStats();
      
      // 6. Sync Firebase 1 lần
      await syncToFirebase(mssv);
      
      return {
        'claimedCount': claimedCount,
        'earnedCoins': totalCoins,
        'earnedDiamonds': totalDiamonds,
      };
    } finally {
      _isClaimingRankReward = false;
      isLoading.value = false;
    }
  }

  /// Kiểm tra rank đã claim chưa (local check)
  bool isRankClaimed(int rankIndex) {
    return stats.value.isRankClaimed(rankIndex);
  }

  /// Đếm số rank chưa claim
  int countUnclaimedRanks(int currentRankIndex) {
    int count = 0;
    for (int i = 0; i <= currentRankIndex; i++) {
      if (!stats.value.isRankClaimed(i)) count++;
    }
    return count;
  }
}
