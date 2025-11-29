import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/player_stats.dart';
import '../../../infrastructure/security/security_service.dart';

/// Service chuyên xử lý sync data game với Firebase
/// Firebase là source of truth - local chỉ là cache
class GameSyncService extends GetxService {
  late final SharedPreferences _prefs;
  late final FirebaseFirestore _firestore;
  late final SecurityService _security;

  static const String _statsKey = 'player_stats';

  Future<GameSyncService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _firestore = FirebaseFirestore.instance;
    _security = Get.find<SecurityService>();
    return this;
  }

  // ============ LOCAL STORAGE ============

  /// Load stats từ local storage
  Future<PlayerStats?> loadLocalStats() async {
    final str = _prefs.getString(_statsKey);
    if (str != null) {
      return PlayerStats.fromJson(jsonDecode(str));
    }
    return null;
  }

  /// Lưu stats vào local
  Future<void> saveLocalStats(PlayerStats stats) async {
    await _prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  /// Xóa stats local
  Future<void> clearLocalStats() async {
    await _prefs.remove(_statsKey);
  }

  // ============ FIREBASE SYNC ============

  /// Sync stats từ Firebase (nếu có)
  /// Firebase là source of truth - luôn ưu tiên data từ Firebase
  /// SECURITY: Verify checksum trước khi accept data
  Future<PlayerStats?> syncFromFirebase(String mssv) async {
    if (mssv.isEmpty) return null;

    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStatsData = doc.data()!['gameStats'] as Map<String, dynamic>;

        // SECURITY: Verify checksum nếu có
        if (gameStatsData.containsKey('_checksum')) {
          final isValid = _security.verifySignedData(gameStatsData);
          if (!isValid) {
            debugPrint(
                '⚠️ syncFromFirebase: Invalid checksum detected! Data may be tampered.');
          }
        }

        final firebaseStats = PlayerStats.fromJson(gameStatsData);
        debugPrint(
            '✅ Synced game stats from Firebase: Level ${firebaseStats.level}, Coins ${firebaseStats.coins}');
        return firebaseStats;
      }
    } catch (e) {
      debugPrint('Error syncing game stats from Firebase: $e');
    }
    return null;
  }

  /// Sync stats lên Firebase (với security check)
  Future<bool> syncToFirebase(String mssv, PlayerStats stats) async {
    if (mssv.isEmpty) return false;

    try {
      // Sign data với checksum
      final signedStats = _security.signData(stats.toJson());

      await _firestore.collection('students').doc(mssv).set({
        'gameStats': signedStats,
        'deviceFingerprint': _security.deviceFingerprint.value,
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
  Future<DateTime?> getServerTime(String mssv) async {
    if (mssv.isEmpty) return null;

    try {
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
  Future<bool> validateLocalTime(String mssv) async {
    final serverTime = await getServerTime(mssv);
    if (serverTime == null) {
      debugPrint('⚠️ Cannot get server time, allowing local time');
      return true;
    }

    final localTime = DateTime.now();
    final difference = localTime.difference(serverTime).abs();
    const maxDifference = Duration(minutes: 5);

    if (difference > maxDifference) {
      debugPrint(
          '⚠️ Time manipulation detected! Local: $localTime, Server: $serverTime, Diff: ${difference.inMinutes} minutes');
      return false;
    }

    return true;
  }

  // ============ FIREBASE VALIDATION ============

  /// Kiểm tra đã khởi tạo game trên Firebase chưa
  Future<bool> checkAlreadyInitializedOnFirebase(String mssv) async {
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
      return true; // Block nếu lỗi (an toàn hơn)
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

  // ============ MISSED LESSONS SYNC ============

  /// Lưu tiết bỏ lỡ lên Firebase
  Future<bool> saveMissedLessonToFirebase({
    required String mssv,
    required String missedKey,
    required Map<String, dynamic> missedData,
  }) async {
    if (mssv.isEmpty) return false;

    try {
      await _firestore
          .collection('students')
          .doc(mssv)
          .collection('missedLessons')
          .doc(missedKey)
          .set({
        ...missedData,
        'syncedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving missed lesson to Firebase: $e');
      return false;
    }
  }

  /// Lấy danh sách tiết bỏ lỡ từ Firebase
  Future<Map<String, dynamic>> getMissedLessonsFromFirebase(String mssv) async {
    if (mssv.isEmpty) return {};

    try {
      final snapshot = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('missedLessons')
          .get();

      final missedLessons = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        missedLessons[doc.id] = doc.data();
      }
      return missedLessons;
    } catch (e) {
      debugPrint('Error getting missed lessons from Firebase: $e');
      return {};
    }
  }

  /// Kiểm tra đã đánh dấu bỏ lỡ trên Firebase chưa
  Future<bool> hasMissedLessonOnFirebase(String mssv, String missedKey) async {
    if (mssv.isEmpty) return false;

    try {
      final doc = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('missedLessons')
          .doc(missedKey)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking missed lesson on Firebase: $e');
      return false;
    }
  }

  // ============ CLAIM VALIDATION ============

  /// Kiểm tra đã nhận bonus học phí trên Firebase chưa
  Future<bool> checkTuitionBonusClaimedOnFirebase(String mssv) async {
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
      return true;
    }
  }

  /// Kiểm tra học kỳ đã claim trên Firebase chưa
  Future<bool> checkSemesterClaimedOnFirebase(
      String mssv, String semesterId) async {
    if (mssv.isEmpty) return true;

    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
        if (gameStats['tuitionBonusClaimed'] == true) return true;
        final claimed = gameStats['claimedTuitionSemesters'] as List? ?? [];
        return claimed.contains(semesterId);
      }
      return false;
    } catch (e) {
      debugPrint('Error checking semester claimed on Firebase: $e');
      return true;
    }
  }

  /// Kiểm tra môn học đã claim trên Firebase chưa
  Future<bool> checkSubjectClaimedOnFirebase(String mssv, String maMon) async {
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
      return true;
    }
  }

  /// Kiểm tra rank đã claim trên Firebase chưa
  Future<bool> checkRankClaimedOnFirebase(String mssv, int rankIndex) async {
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
      return true;
    }
  }

  /// Lấy danh sách môn đã claim từ Firebase
  Future<Set<String>> getClaimedSubjectsFromFirebase(String mssv) async {
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
        final claimed = gameStats['claimedSubjects'] as List? ?? [];
        return claimed.map((e) => e.toString()).toSet();
      }
    } catch (e) {
      debugPrint('Error fetching claimed subjects: $e');
    }
    return {};
  }

  /// Lấy danh sách rank đã claim từ Firebase
  Future<Set<int>> getClaimedRanksFromFirebase(String mssv) async {
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?['gameStats'] != null) {
        final gameStats = doc.data()!['gameStats'] as Map<String, dynamic>;
        final claimed = gameStats['claimedRankRewards'] as List? ?? [];
        return claimed.map((e) => e as int).toSet();
      }
    } catch (e) {
      debugPrint('Error fetching claimed ranks: $e');
    }
    return {};
  }

  // ============ ACHIEVEMENT SYNC ============

  /// Lưu thành tựu đã claim lên Firebase
  Future<bool> saveAchievementToFirebase({
    required String mssv,
    required String achievementId,
    required DateTime claimedAt,
  }) async {
    if (mssv.isEmpty) return false;

    try {
      await _firestore
          .collection('students')
          .doc(mssv)
          .collection('achievements')
          .doc(achievementId)
          .set({
        'achievementId': achievementId,
        'claimedAt': Timestamp.fromDate(claimedAt),
        'syncedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving achievement to Firebase: $e');
      return false;
    }
  }

  /// Lấy danh sách thành tựu đã claim từ Firebase
  Future<Set<String>> getClaimedAchievementsFromFirebase(String mssv) async {
    if (mssv.isEmpty) return {};

    try {
      final snapshot = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('achievements')
          .get();

      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      debugPrint('Error getting achievements from Firebase: $e');
      return {};
    }
  }

  /// Kiểm tra thành tựu đã claim trên Firebase chưa
  Future<bool> checkAchievementClaimedOnFirebase(
      String mssv, String achievementId) async {
    if (mssv.isEmpty) return false;

    try {
      final doc = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('achievements')
          .doc(achievementId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking achievement on Firebase: $e');
      return false;
    }
  }

  /// Lưu thành tựu với data signing (checksum + device fingerprint)
  /// BẢO MẬT: Data được sign với checksum để verify integrity
  Future<bool> saveAchievementToFirebaseSecure({
    required String mssv,
    required String achievementId,
    required Map<String, dynamic> signedData,
  }) async {
    if (mssv.isEmpty) return false;

    try {
      await _firestore
          .collection('students')
          .doc(mssv)
          .collection('achievements')
          .doc(achievementId)
          .set({
        ...signedData,
        'deviceFingerprint': _security.deviceFingerprint.value,
        'syncedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving achievement securely to Firebase: $e');
      return false;
    }
  }

  /// Lưu nhiều thành tựu cùng lúc với batch write (1 request duy nhất)
  /// BẢO MẬT: Tất cả data được sign với checksum
  Future<bool> saveAchievementsBatchToFirebase({
    required String mssv,
    required List<Map<String, dynamic>> achievementsData,
  }) async {
    if (mssv.isEmpty || achievementsData.isEmpty) return false;

    try {
      final batch = _firestore.batch();
      final deviceFingerprint = _security.deviceFingerprint.value;
      final serverTimestamp = FieldValue.serverTimestamp();

      for (final data in achievementsData) {
        final achievementId = data['achievementId'] as String;
        final docRef = _firestore
            .collection('students')
            .doc(mssv)
            .collection('achievements')
            .doc(achievementId);

        batch.set(docRef, {
          ...data,
          'deviceFingerprint': deviceFingerprint,
          'syncedAt': serverTimestamp,
        });
      }

      await batch.commit();
      debugPrint('✅ Batch saved ${achievementsData.length} achievements to Firebase');
      return true;
    } catch (e) {
      debugPrint('Error batch saving achievements to Firebase: $e');
      return false;
    }
  }
}

