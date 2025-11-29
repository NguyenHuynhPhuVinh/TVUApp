import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reward_calculator.dart';
import '../shared/models/player_stats.dart';
import '../shared/models/wallet_transaction.dart';
import '../../../infrastructure/storage/storage_service.dart';
import '../../academic/models/schedule_model.dart';
import 'game_security_guard.dart';
import 'game_sync_service.dart';

/// Service quản lý hệ thống game: coins, diamonds, level, XP
/// Đã refactor: Sử dụng GameSecurityGuard và GameSyncService
class GameService extends GetxService {
  late final SharedPreferences _prefs;
  late final GameSecurityGuard _guard;
  late final GameSyncService _syncService;

  static const String _statsKey = 'player_stats';
  static const String _transactionsKey = 'wallet_transactions';

  // ============ REWARD CONSTANTS (delegate to RewardCalculator) ============
  static int get coinsPerLesson => RewardCalculator.coinsPerLesson;
  static int get xpPerLesson => RewardCalculator.xpPerLesson;
  static int get diamondsPerLesson => RewardCalculator.diamondsPerLesson;
  static int get lessonsPerCredit => RewardCalculator.lessonsPerCredit;

  final stats = PlayerStats().obs;
  final transactions = <WalletTransaction>[].obs;

  // Delegate to guard
  RxBool get isLoading => _guard.isLoading;
  RxBool get isSecure => _guard.isSecure;
  RxList<String> get securityIssues => _guard.securityIssues;

  Future<GameService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _guard = Get.find<GameSecurityGuard>();
    _syncService = Get.find<GameSyncService>();
    await _loadLocalStats();
    await _loadLocalTransactions();
    return this;
  }

  // ============ LOCAL STORAGE ============

  Future<void> _loadLocalStats() async {
    final str = _prefs.getString(_statsKey);
    if (str != null) {
      stats.value = PlayerStats.fromJson(jsonDecode(str));
    }
  }

  Future<void> _saveLocalStats() async {
    await _prefs.setString(_statsKey, jsonEncode(stats.value.toJson()));
  }

  Future<void> _loadLocalTransactions() async {
    final str = _prefs.getString(_transactionsKey);
    if (str != null) {
      final list = jsonDecode(str) as List;
      transactions.value =
          list.map((e) => WalletTransaction.fromJson(e)).toList();
    }
  }

  Future<void> _saveLocalTransactions() async {
    await _prefs.setString(
      _transactionsKey,
      jsonEncode(transactions.map((e) => e.toJson()).toList()),
    );
  }

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

  // ============ CORE HELPERS ============

  /// Helper: Update stats → Save local → Sync Firebase
  Future<void> _updateAndSync(
      PlayerStats newStats, String mssv) async {
    stats.value = newStats;
    await _saveLocalStats();
    await _syncService.syncToFirebase(mssv, stats.value);
  }

  bool get isInitialized => stats.value.isInitialized;

  // ============ FIREBASE SYNC (delegate to GameSyncService) ============

  Future<bool> syncFromFirebase(String mssv) async {
    final firebaseStats = await _syncService.syncFromFirebase(mssv);
    if (firebaseStats != null) {
      stats.value = firebaseStats;
      await _saveLocalStats();
      return true;
    }
    return false;
  }

  Future<bool> syncToFirebase(String mssv) async {
    return await _syncService.syncToFirebase(mssv, stats.value);
  }

  // ============ SERVER TIME VALIDATION ============

  Future<DateTime?> getServerTime(String mssv) =>
      _syncService.getServerTime(mssv);

  Future<bool> validateLocalTime(String mssv) =>
      _syncService.validateLocalTime(mssv);

  // ============ CHECK-IN SYNC ============

  Future<bool> saveCheckInToFirebase({
    required String mssv,
    required String checkInKey,
    required Map<String, dynamic> checkInData,
  }) =>
      _syncService.saveCheckInToFirebase(
        mssv: mssv,
        checkInKey: checkInKey,
        checkInData: checkInData,
      );

  Future<Map<String, dynamic>> getCheckInsFromFirebase(String mssv) =>
      _syncService.getCheckInsFromFirebase(mssv);

  Future<bool> hasCheckedInOnFirebase(String mssv, String checkInKey) =>
      _syncService.hasCheckedInOnFirebase(mssv, checkInKey);

  // ============ MISSED LESSONS SYNC ============

  Future<bool> saveMissedLessonToFirebase({
    required String mssv,
    required String missedKey,
    required Map<String, dynamic> missedData,
  }) =>
      _syncService.saveMissedLessonToFirebase(
        mssv: mssv,
        missedKey: missedKey,
        missedData: missedData,
      );

  Future<Map<String, dynamic>> getMissedLessonsFromFirebase(String mssv) =>
      _syncService.getMissedLessonsFromFirebase(mssv);

  Future<bool> hasMissedLessonOnFirebase(String mssv, String missedKey) =>
      _syncService.hasMissedLessonOnFirebase(mssv, missedKey);

  // ============ CALCULATE HELPERS ============

  int calculateTotalLessons() {
    final storage = Get.find<StorageService>();
    final allSchedules = storage.getAllSchedules();

    int totalLessons = 0;
    for (var scheduleData in allSchedules.values) {
      if (scheduleData is Map<String, dynamic>) {
        final weekList = scheduleData['ds_tuan_tkb'] as List? ?? [];
        final weeks = weekList.map((e) => ScheduleWeek.fromJson(e)).toList();
        for (var week in weeks) {
          for (var lesson in week.lessons) {
            totalLessons += lesson.soTiet;
          }
        }
      }
    }
    return totalLessons;
  }

  int calculateVirtualBalanceFromTuition(int tuitionPaid) {
    return RewardCalculator.calculateVirtualBalance(tuitionPaid);
  }

  static Map<String, int> calculateSubjectReward(int soTinChi) {
    return RewardCalculator.calculateSubjectReward(soTinChi);
  }

  static Map<String, int> calculateRankReward(int rankIndex) {
    return RewardCalculator.calculateRankReward(rankIndex);
  }

  // ============ INITIALIZE GAME ============

  Future<Map<String, dynamic>?> initializeGame({
    required String mssv,
    required int missedSessions,
  }) async {
    _guard.isLoading.value = true;

    try {
      // Check đã init chưa (Firebase là source of truth)
      final alreadyInitialized =
          await _syncService.checkAlreadyInitializedOnFirebase(mssv);
      if (alreadyInitialized) {
        debugPrint('⚠️ initializeGame blocked: Already initialized on Firebase');
        await syncFromFirebase(mssv);
        return null;
      }

      if (stats.value.isInitialized) {
        debugPrint('⚠️ initializeGame blocked: Already initialized locally');
        return null;
      }

      // Security check
      if (!_guard.isSecure.value) {
        await _guard.checkSecurity();
        if (!_guard.isSecure.value) {
          debugPrint('⚠️ initializeGame blocked: Security issues detected');
          return null;
        }
      }

      final totalLessons = calculateTotalLessons();
      final missedLessons = missedSessions * 4;
      final attendedLessons =
          (totalLessons - missedLessons).clamp(0, totalLessons);

      final attendanceReward = RewardCalculator.calculateAttendanceReward(
        attendedLessons: attendedLessons,
        totalLessons: totalLessons,
      );
      final earnedCoins = attendanceReward['coins']!;
      final earnedDiamonds = attendanceReward['diamonds']!;
      final earnedXp = attendanceReward['xp']!;

      final levelResult = RewardCalculator.calculateLevelFromXp(earnedXp);
      final level = levelResult['level']!;
      final remainingXp = levelResult['currentXp']!;

      final newStats = PlayerStats(
        coins: earnedCoins,
        diamonds: earnedDiamonds,
        level: level,
        currentXp: remainingXp,
        totalLessonsAttended: attendedLessons,
        totalLessonsMissed: missedLessons,
        isInitialized: true,
        initializedAt: DateTime.now(),
      );

      await _updateAndSync(newStats, mssv);

      return {
        'totalLessons': totalLessons,
        'attendedLessons': attendedLessons,
        'missedLessons': missedLessons,
        'earnedCoins': earnedCoins,
        'earnedDiamonds': earnedDiamonds,
        'earnedXp': earnedXp,
        'level': level,
        'attendanceRate': newStats.attendanceRate,
      };
    } finally {
      _guard.isLoading.value = false;
    }
  }

  // ============ ADD CURRENCY ============

  Future<bool> addCoins(int amount, String mssv) async {
    if (!_guard.validatePositiveAmount(amount, 'addCoins')) return false;

    return _guard.secureExecuteBool(
      actionName: 'addCoins',
      action: () async {
        await _updateAndSync(
          stats.value.copyWith(coins: stats.value.coins + amount),
          mssv,
        );
        return true;
      },
    );
  }

  Future<bool> addDiamonds(int amount, String mssv) async {
    if (!_guard.validatePositiveAmount(amount, 'addDiamonds')) return false;

    return _guard.secureExecuteBool(
      actionName: 'addDiamonds',
      action: () async {
        await _updateAndSync(
          stats.value.copyWith(diamonds: stats.value.diamonds + amount),
          mssv,
        );
        return true;
      },
    );
  }

  Future<Map<String, dynamic>?> addXp(int amount, String mssv) async {
    if (!_guard.validatePositiveAmount(amount, 'addXp')) return null;

    return _guard.secureExecute(
      actionName: 'addXp',
      action: () async {
        final levelResult = RewardCalculator.addXpAndCalculateLevel(
          currentXp: stats.value.currentXp,
          currentLevel: stats.value.level,
          addedXp: amount,
        );

        await _updateAndSync(
          stats.value.copyWith(
            currentXp: levelResult['newXp'],
            level: levelResult['newLevel'],
          ),
          mssv,
        );

        return {
          'leveledUp': levelResult['leveledUp'],
          'newLevel': levelResult['newLevel'],
          'currentXp': levelResult['newXp'],
        };
      },
    );
  }

  // ============ RECORD ATTENDANCE ============

  Future<Map<String, dynamic>?> recordAttendance({
    required String mssv,
    required int lessons,
    required bool attended,
  }) async {
    if (!_guard.validateLessons(lessons, 'recordAttendance')) return null;

    return _guard.secureExecute(
      actionName: 'recordAttendance',
      action: () async {
        if (attended) {
          final earnedCoins = lessons * coinsPerLesson;
          final earnedXp = lessons * xpPerLesson;
          final earnedDiamonds = lessons * diamondsPerLesson;

          final levelResult = RewardCalculator.addXpAndCalculateLevel(
            currentXp: stats.value.currentXp,
            currentLevel: stats.value.level,
            addedXp: earnedXp,
          );

          await _updateAndSync(
            stats.value.copyWith(
              totalLessonsAttended: stats.value.totalLessonsAttended + lessons,
              coins: stats.value.coins + earnedCoins,
              diamonds: stats.value.diamonds + earnedDiamonds,
              currentXp: levelResult['newXp'],
              level: levelResult['newLevel'],
            ),
            mssv,
          );

          return {
            'earnedCoins': earnedCoins,
            'earnedDiamonds': earnedDiamonds,
            'earnedXp': earnedXp,
            'leveledUp': levelResult['leveledUp'],
            'newLevel': levelResult['newLevel'],
            'currentXp': levelResult['newXp'],
          };
        } else {
          await _updateAndSync(
            stats.value.copyWith(
              totalLessonsMissed: stats.value.totalLessonsMissed + lessons,
            ),
            mssv,
          );
          return {'earnedCoins': 0, 'earnedXp': 0};
        }
      },
    );
  }

  Future<void> resetGame() async {
    stats.value = const PlayerStats();
    transactions.clear();
    await _prefs.remove(_statsKey);
    await _prefs.remove(_transactionsKey);
  }

  // ============ TUITION BONUS SYSTEM ============

  Future<Map<String, dynamic>?> claimTuitionBonus({
    required String mssv,
    required int tuitionPaid,
  }) async {
    final alreadyClaimed =
        await _syncService.checkTuitionBonusClaimedOnFirebase(mssv);
    if (alreadyClaimed || stats.value.tuitionBonusClaimed) {
      debugPrint('⚠️ claimTuitionBonus blocked: Already claimed');
      return null;
    }

    if (!_guard.validatePositiveAmount(tuitionPaid, 'claimTuitionBonus')) {
      return null;
    }

    return _guard.secureExecuteWithLoading(
      actionName: 'claimTuitionBonus',
      action: () async {
        final virtualBalance = calculateVirtualBalanceFromTuition(tuitionPaid);

        await _updateAndSync(
          stats.value.copyWith(
            virtualBalance: virtualBalance,
            totalTuitionPaid: tuitionPaid,
            tuitionBonusClaimed: true,
          ),
          mssv,
        );

        await _addTransaction(
          type: TransactionType.tuitionBonus,
          amount: virtualBalance,
          description: 'Nhận thưởng từ học phí đã đóng',
          metadata: {'tuitionPaid': tuitionPaid},
        );

        return {
          'tuitionPaid': tuitionPaid,
          'virtualBalance': virtualBalance,
        };
      },
    );
  }

  Future<Map<String, dynamic>?> claimTuitionBonusBySemester({
    required String mssv,
    required String semesterId,
    required int tuitionPaid,
  }) async {
    final alreadyClaimed =
        await _syncService.checkSemesterClaimedOnFirebase(mssv, semesterId);
    if (alreadyClaimed || stats.value.isSemesterClaimed(semesterId)) {
      debugPrint(
          '⚠️ claimTuitionBonusBySemester blocked: Semester $semesterId already claimed');
      return null;
    }

    if (!_guard.validatePositiveAmount(
        tuitionPaid, 'claimTuitionBonusBySemester')) {
      return null;
    }

    return _guard.secureExecuteWithLoading(
      actionName: 'claimTuitionBonusBySemester',
      action: () async {
        final bonusAmount = calculateVirtualBalanceFromTuition(tuitionPaid);
        final newClaimedSemesters = [
          ...stats.value.claimedTuitionSemesters,
          semesterId
        ];

        await _updateAndSync(
          stats.value.copyWith(
            virtualBalance: stats.value.virtualBalance + bonusAmount,
            totalTuitionPaid: stats.value.totalTuitionPaid + tuitionPaid,
            claimedTuitionSemesters: newClaimedSemesters,
          ),
          mssv,
        );

        await _addTransaction(
          type: TransactionType.tuitionBonus,
          amount: bonusAmount,
          description: 'Nhận thưởng học phí $semesterId',
          metadata: {'semesterId': semesterId, 'tuitionPaid': tuitionPaid},
        );

        return {
          'semesterId': semesterId,
          'tuitionPaid': tuitionPaid,
          'virtualBalance': bonusAmount,
        };
      },
    );
  }

  // ============ DIAMOND SHOP ============

  bool _isBuyingDiamonds = false;

  Future<Map<String, dynamic>?> buyDiamonds({
    required String mssv,
    required int diamondAmount,
    required int cost,
  }) async {
    if (diamondAmount <= 0 || cost <= 0) return null;
    if (stats.value.virtualBalance < cost) {
      debugPrint('⚠️ buyDiamonds blocked: Insufficient balance');
      return null;
    }

    return _guard.secureExecuteWithLock(
      actionName: 'buyDiamonds',
      isLocked: () => _isBuyingDiamonds,
      setLock: (v) => _isBuyingDiamonds = v,
      action: () async {
        await _updateAndSync(
          stats.value.copyWith(
            virtualBalance: stats.value.virtualBalance - cost,
            diamonds: stats.value.diamonds + diamondAmount,
          ),
          mssv,
        );

        await _addTransaction(
          type: TransactionType.buyDiamond,
          amount: -cost,
          description: 'Mua $diamondAmount diamond',
          metadata: {'diamonds': diamondAmount, 'cost': cost},
        );

        return {
          'diamondAmount': diamondAmount,
          'cost': cost,
          'newBalance': stats.value.virtualBalance,
          'newDiamonds': stats.value.diamonds,
        };
      },
    );
  }

  // ============ COIN SHOP ============

  bool _isBuyingCoins = false;

  Future<Map<String, dynamic>?> buyCoins({
    required String mssv,
    required int diamondAmount,
  }) async {
    if (diamondAmount <= 0) return null;
    if (stats.value.diamonds < diamondAmount) {
      debugPrint('⚠️ buyCoins blocked: Insufficient diamonds');
      return null;
    }

    return _guard.secureExecuteWithLock(
      actionName: 'buyCoins',
      isLocked: () => _isBuyingCoins,
      setLock: (v) => _isBuyingCoins = v,
      action: () async {
        final coinAmount = diamondAmount * 10000;

        await _updateAndSync(
          stats.value.copyWith(
            diamonds: stats.value.diamonds - diamondAmount,
            coins: stats.value.coins + coinAmount,
          ),
          mssv,
        );

        await _addTransaction(
          type: TransactionType.buyCoin,
          amount: coinAmount,
          description:
              'Đổi $diamondAmount diamond lấy ${coinAmount ~/ 1000}K coins',
          metadata: {'diamonds': diamondAmount, 'coins': coinAmount},
        );

        return {
          'diamondAmount': diamondAmount,
          'coinAmount': coinAmount,
          'newDiamonds': stats.value.diamonds,
          'newCoins': stats.value.coins,
        };
      },
    );
  }


  // ============ LESSON CHECK-IN SYSTEM ============

  static const Duration checkInEarlyWindow = Duration(minutes: 30);

  static DateTime calculateLessonStartTime(DateTime date, int tietBatDau) {
    int startHour;
    int startMinute = 0;

    if (tietBatDau <= 6) {
      startHour = 7;
      final tietOffset = tietBatDau - 1;
      final totalMinutes = tietOffset * 45;
      startHour += totalMinutes ~/ 60;
      startMinute = totalMinutes % 60;
    } else if (tietBatDau <= 12) {
      startHour = 13;
      final tietOffset = tietBatDau - 7;
      final totalMinutes = tietOffset * 45;
      startHour += totalMinutes ~/ 60;
      startMinute = totalMinutes % 60;
    } else {
      startHour = 18;
      final tietOffset = tietBatDau - 13;
      final totalMinutes = tietOffset * 45;
      startHour += totalMinutes ~/ 60;
      startMinute = totalMinutes % 60;
    }

    return DateTime(date.year, date.month, date.day, startHour, startMinute);
  }

  static DateTime calculateLessonEndTime(
      DateTime date, int tietBatDau, int soTiet) {
    final startTime = calculateLessonStartTime(date, tietBatDau);
    return startTime.add(Duration(minutes: soTiet * 45));
  }

  static DateTime calculateCheckInStartTime(DateTime date, int tietBatDau) {
    final lessonStart = calculateLessonStartTime(date, tietBatDau);
    return lessonStart.subtract(checkInEarlyWindow);
  }

  static DateTime calculateCheckInDeadline(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  bool canCheckIn(DateTime lessonDate, int tietBatDau, int soTiet) {
    final now = DateTime.now();
    final checkInStart = calculateCheckInStartTime(lessonDate, tietBatDau);
    final checkInDeadline = calculateCheckInDeadline(lessonDate);
    final endTime = calculateLessonEndTime(lessonDate, tietBatDau, soTiet);

    if (now.isBefore(checkInStart)) return false;
    if (now.isAfter(checkInDeadline)) return false;

    final initializedAt = stats.value.initializedAt;
    if (initializedAt != null) {
      if (endTime.isBefore(initializedAt)) return false;
    }

    return true;
  }

  Duration? getTimeUntilCheckIn(
      DateTime lessonDate, int tietBatDau, int soTiet) {
    final now = DateTime.now();
    final checkInStart = calculateCheckInStartTime(lessonDate, tietBatDau);
    final checkInDeadline = calculateCheckInDeadline(lessonDate);
    final endTime = calculateLessonEndTime(lessonDate, tietBatDau, soTiet);

    final initializedAt = stats.value.initializedAt;
    if (initializedAt != null && endTime.isBefore(initializedAt)) {
      return null;
    }

    if (now.isAfter(checkInDeadline)) return null;
    if (now.isAfter(checkInStart) || now.isAtSameMomentAs(checkInStart)) {
      return null;
    }

    return checkInStart.difference(now);
  }

  Future<Map<String, dynamic>?> checkInLesson({
    required String mssv,
    required int soTiet,
  }) async {
    if (!_guard.validateLessons(soTiet, 'checkInLesson')) return null;

    return _guard.secureExecute(
      actionName: 'checkInLesson',
      action: () async {
        final earnedCoins = soTiet * coinsPerLesson;
        final earnedXp = soTiet * xpPerLesson;
        final earnedDiamonds = soTiet * diamondsPerLesson;

        final levelResult = RewardCalculator.addXpAndCalculateLevel(
          currentXp: stats.value.currentXp,
          currentLevel: stats.value.level,
          addedXp: earnedXp,
        );

        await _updateAndSync(
          stats.value.copyWith(
            coins: stats.value.coins + earnedCoins,
            diamonds: stats.value.diamonds + earnedDiamonds,
            currentXp: levelResult['newXp'],
            level: levelResult['newLevel'],
            totalLessonsAttended: stats.value.totalLessonsAttended + soTiet,
          ),
          mssv,
        );

        return {
          'earnedCoins': earnedCoins,
          'earnedDiamonds': earnedDiamonds,
          'earnedXp': earnedXp,
          'soTiet': soTiet,
          'leveledUp': levelResult['leveledUp'],
          'newLevel': levelResult['newLevel'],
          'currentXp': levelResult['newXp'],
        };
      },
    );
  }

  /// Ghi nhận tiết bỏ lỡ và cập nhật thống kê
  Future<Map<String, dynamic>?> recordMissedLesson({
    required String mssv,
    required int soTiet,
  }) async {
    if (!_guard.validateLessons(soTiet, 'recordMissedLesson')) return null;

    return _guard.secureExecute(
      actionName: 'recordMissedLesson',
      action: () async {
        await _updateAndSync(
          stats.value.copyWith(
            totalLessonsMissed: stats.value.totalLessonsMissed + soTiet,
          ),
          mssv,
        );

        return {
          'soTiet': soTiet,
          'totalLessonsMissed': stats.value.totalLessonsMissed,
          'attendanceRate': stats.value.attendanceRate,
        };
      },
    );
  }

  // ============ SUBJECT REWARD SYSTEM ============

  bool _isClaimingSubject = false;

  Future<Map<String, dynamic>?> claimSubjectReward({
    required String mssv,
    required String maMon,
    required String tenMon,
    required int soTinChi,
  }) async {
    if (!_guard.validateCredits(soTinChi, 'claimSubjectReward')) return null;

    final alreadyClaimed =
        await _syncService.checkSubjectClaimedOnFirebase(mssv, maMon);
    if (alreadyClaimed || stats.value.isSubjectClaimed(maMon)) {
      debugPrint('⚠️ claimSubjectReward blocked: Subject $maMon already claimed');
      return null;
    }

    return _guard.secureExecuteWithLock(
      actionName: 'claimSubjectReward',
      isLocked: () => _isClaimingSubject,
      setLock: (v) => _isClaimingSubject = v,
      action: () async {
        final reward = calculateSubjectReward(soTinChi);
        final earnedCoins = reward['coins']!;
        final earnedXp = reward['xp']!;
        final earnedDiamonds = reward['diamonds']!;

        final levelResult = RewardCalculator.addXpAndCalculateLevel(
          currentXp: stats.value.currentXp,
          currentLevel: stats.value.level,
          addedXp: earnedXp,
        );

        final newClaimedSubjects = [...stats.value.claimedSubjects, maMon];

        await _updateAndSync(
          stats.value.copyWith(
            coins: stats.value.coins + earnedCoins,
            diamonds: stats.value.diamonds + earnedDiamonds,
            currentXp: levelResult['newXp'],
            level: levelResult['newLevel'],
            claimedSubjects: newClaimedSubjects,
          ),
          mssv,
        );

        return {
          'maMon': maMon,
          'tenMon': tenMon,
          'soTinChi': soTinChi,
          'earnedCoins': earnedCoins,
          'earnedDiamonds': earnedDiamonds,
          'earnedXp': earnedXp,
          'leveledUp': levelResult['leveledUp'],
          'newLevel': levelResult['newLevel'],
        };
      },
    );
  }

  bool isSubjectClaimed(String maMon) => stats.value.isSubjectClaimed(maMon);

  Future<Map<String, dynamic>?> claimAllSubjectRewards({
    required String mssv,
    required List<Map<String, dynamic>> subjects,
  }) async {
    if (subjects.isEmpty) return null;

    return _guard.secureExecuteWithLock(
      actionName: 'claimAllSubjectRewards',
      isLocked: () => _isClaimingSubject,
      setLock: (v) => _isClaimingSubject = v,
      action: () async {
        final claimedOnFirebase =
            await _syncService.getClaimedSubjectsFromFirebase(mssv);

        int totalCoins = 0;
        int totalDiamonds = 0;
        int totalXp = 0;
        List<String> newClaimedSubjects = [...stats.value.claimedSubjects];
        int claimedCount = 0;

        for (var subject in subjects) {
          final maMon = subject['maMon'] as String? ?? '';
          final soTinChi = subject['soTinChi'] as int? ?? 0;

          if (maMon.isEmpty || soTinChi <= 0) continue;
          if (claimedOnFirebase.contains(maMon)) continue;
          if (newClaimedSubjects.contains(maMon)) continue;

          final reward = calculateSubjectReward(soTinChi);
          totalCoins += reward['coins']!;
          totalDiamonds += reward['diamonds']!;
          totalXp += reward['xp']!;
          newClaimedSubjects.add(maMon);
          claimedCount++;
        }

        if (claimedCount == 0) return null;

        final levelResult = RewardCalculator.addXpAndCalculateLevel(
          currentXp: stats.value.currentXp,
          currentLevel: stats.value.level,
          addedXp: totalXp,
        );

        await _updateAndSync(
          stats.value.copyWith(
            coins: stats.value.coins + totalCoins,
            diamonds: stats.value.diamonds + totalDiamonds,
            currentXp: levelResult['newXp'],
            level: levelResult['newLevel'],
            claimedSubjects: newClaimedSubjects,
          ),
          mssv,
        );

        return {
          'claimedCount': claimedCount,
          'earnedCoins': totalCoins,
          'earnedDiamonds': totalDiamonds,
          'earnedXp': totalXp,
          'leveledUp': levelResult['leveledUp'],
          'newLevel': levelResult['newLevel'],
        };
      },
    );
  }

  // ============ RANK REWARD SYSTEM ============

  bool _isClaimingRankReward = false;

  Future<Map<String, dynamic>?> claimRankReward({
    required String mssv,
    required int rankIndex,
    required int currentRankIndex,
  }) async {
    if (rankIndex > currentRankIndex) {
      debugPrint('⚠️ claimRankReward blocked: Rank $rankIndex not unlocked');
      return null;
    }

    final alreadyClaimed =
        await _syncService.checkRankClaimedOnFirebase(mssv, rankIndex);
    if (alreadyClaimed || stats.value.isRankClaimed(rankIndex)) {
      debugPrint('⚠️ claimRankReward blocked: Rank $rankIndex already claimed');
      return null;
    }

    return _guard.secureExecuteWithLock(
      actionName: 'claimRankReward',
      isLocked: () => _isClaimingRankReward,
      setLock: (v) => _isClaimingRankReward = v,
      action: () async {
        final reward = calculateRankReward(rankIndex);
        final earnedCoins = reward['coins']!;
        final earnedXp = reward['xp']!;
        final earnedDiamonds = reward['diamonds']!;

        final levelResult = RewardCalculator.addXpAndCalculateLevel(
          currentXp: stats.value.currentXp,
          currentLevel: stats.value.level,
          addedXp: earnedXp,
        );

        final newClaimedRanks = [...stats.value.claimedRankRewards, rankIndex];

        await _updateAndSync(
          stats.value.copyWith(
            coins: stats.value.coins + earnedCoins,
            diamonds: stats.value.diamonds + earnedDiamonds,
            currentXp: levelResult['newXp'],
            level: levelResult['newLevel'],
            claimedRankRewards: newClaimedRanks,
          ),
          mssv,
        );

        return {
          'rankIndex': rankIndex,
          'earnedCoins': earnedCoins,
          'earnedXp': earnedXp,
          'earnedDiamonds': earnedDiamonds,
          'leveledUp': levelResult['leveledUp'],
          'newLevel': levelResult['newLevel'],
        };
      },
    );
  }

  Future<Map<String, dynamic>?> claimAllRankRewards({
    required String mssv,
    required int currentRankIndex,
  }) async {
    return _guard.secureExecuteWithLock(
      actionName: 'claimAllRankRewards',
      isLocked: () => _isClaimingRankReward,
      setLock: (v) => _isClaimingRankReward = v,
      action: () async {
        final claimedOnFirebase =
            await _syncService.getClaimedRanksFromFirebase(mssv);

        int totalCoins = 0;
        int totalXp = 0;
        int totalDiamonds = 0;
        List<int> newClaimedRanks = [...stats.value.claimedRankRewards];
        int claimedCount = 0;

        for (int i = 0; i <= currentRankIndex; i++) {
          if (claimedOnFirebase.contains(i)) continue;
          if (newClaimedRanks.contains(i)) continue;

          final reward = calculateRankReward(i);
          totalCoins += reward['coins']!;
          totalXp += reward['xp']!;
          totalDiamonds += reward['diamonds']!;
          newClaimedRanks.add(i);
          claimedCount++;
        }

        if (claimedCount == 0) return null;

        final levelResult = RewardCalculator.addXpAndCalculateLevel(
          currentXp: stats.value.currentXp,
          currentLevel: stats.value.level,
          addedXp: totalXp,
        );

        await _updateAndSync(
          stats.value.copyWith(
            coins: stats.value.coins + totalCoins,
            diamonds: stats.value.diamonds + totalDiamonds,
            currentXp: levelResult['newXp'],
            level: levelResult['newLevel'],
            claimedRankRewards: newClaimedRanks,
          ),
          mssv,
        );

        return {
          'claimedCount': claimedCount,
          'earnedCoins': totalCoins,
          'earnedXp': totalXp,
          'earnedDiamonds': totalDiamonds,
          'leveledUp': levelResult['leveledUp'],
          'newLevel': levelResult['newLevel'],
        };
      },
    );
  }

  bool isRankClaimed(int rankIndex) => stats.value.isRankClaimed(rankIndex);

  int countUnclaimedRanks(int currentRankIndex) {
    int count = 0;
    for (int i = 0; i <= currentRankIndex; i++) {
      if (!stats.value.isRankClaimed(i)) count++;
    }
    return count;
  }
}

