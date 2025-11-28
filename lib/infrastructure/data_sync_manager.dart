import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'network/api_service.dart';
import '../features/auth/data/auth_service.dart';
import 'firebase/firebase_service.dart';
import '../features/gamification/core/game_service.dart';
import 'storage/storage_service.dart';

/// Callback để cập nhật progress UI
typedef SyncProgressCallback = void Function(double progress, String status);

/// Kết quả sync
class SyncResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;

  const SyncResult({
    required this.success,
    this.error,
    this.data,
  });

  factory SyncResult.ok([Map<String, dynamic>? data]) =>
      SyncResult(success: true, data: data);

  factory SyncResult.fail(String error) =>
      SyncResult(success: false, error: error);
}

/// Manager tập trung logic sync data
/// Tách từ SplashController để dễ bảo trì và tái sử dụng
class DataSyncManager extends GetxService {
  late final ApiService _api;
  late final StorageService _storage;
  late final FirebaseService _firebase;
  late final GameService _game;
  late final AuthService _auth;

  Future<DataSyncManager> init() async {
    _api = Get.find<ApiService>();
    _storage = Get.find<StorageService>();
    _firebase = Get.find<FirebaseService>();
    _game = Get.find<GameService>();
    _auth = Get.find<AuthService>();
    return this;
  }

  String get _mssv => _auth.username.value;

  // ============ FULL SYNC ============

  /// Full sync - chạy khi lần đầu login hoặc chưa có data
  /// [onProgress] - Callback để cập nhật UI progress
  Future<SyncResult> performFullSync({
    SyncProgressCallback? onProgress,
  }) async {
    if (_mssv.isEmpty) return SyncResult.fail('MSSV is empty');

    try {
      // 1. Thông tin sinh viên
      onProgress?.call(0.1, 'Đang tải thông tin sinh viên...');
      await _syncStudentInfo();

      // 2. Danh sách học kỳ + TKB tất cả học kỳ
      onProgress?.call(0.15, 'Đang tải thời khóa biểu...');
      final allSchedulesData = await _loadAllSchedules(
        onProgress: (p, s) => onProgress?.call(0.15 + (0.2 * p), s),
      );

      // 3. Điểm
      onProgress?.call(0.35, 'Đang tải điểm...');
      final gradesData = await _syncGrades();

      // 4. CTDT
      onProgress?.call(0.55, 'Đang tải chương trình đào tạo...');
      final curriculumData = await _syncCurriculum();

      // 5. Học phí
      onProgress?.call(0.7, 'Đang tải học phí...');
      final tuitionData = await _syncTuition();

      // 6. Thông báo
      onProgress?.call(0.75, 'Đang tải thông báo...');
      await _syncNotifications();

      // 7. Sync Firebase
      onProgress?.call(0.85, 'Đang đồng bộ dữ liệu...');
      await _firebase.syncAllStudentData(
        mssv: _mssv,
        grades: gradesData,
        curriculum: curriculumData,
        tuition: tuitionData,
      );

      // 7.1 Sync check-ins từ Firebase về local
      await _syncCheckInsFromFirebase();

      // Sync tất cả TKB lên Firebase
      if (allSchedulesData != null) {
        for (var entry in allSchedulesData.entries) {
          final semester = int.tryParse(entry.key) ?? 0;
          if (semester > 0) {
            await _firebase.saveSchedule(_mssv, semester, entry.value);
          }
        }
      }

      final semestersData = _storage.getSemesters();
      if (semestersData != null) {
        await _firebase.saveSemesters(_mssv, semestersData);
      }

      onProgress?.call(1.0, 'Hoàn tất!');

      // Sync game stats từ Firebase
      await _game.syncFromFirebase(_mssv);

      return SyncResult.ok({
        'isInitialized': _game.isInitialized,
      });
    } catch (e) {
      debugPrint('Full sync error: $e');
      return SyncResult.fail(e.toString());
    }
  }

  // ============ QUICK LOAD ============

  /// Quick load - chỉ load TKB học kỳ hiện tại, sync nền sau
  /// Returns: Map chứa data để dùng cho background sync
  Future<Map<String, dynamic>?> performQuickLoad() async {
    if (_mssv.isEmpty) return null;

    try {
      final currentScheduleData = await _loadCurrentSemesterSchedule();

      // Sync game stats từ Firebase (source of truth)
      await _game.syncFromFirebase(_mssv);

      // Sync check-ins từ Firebase về local
      await _syncCheckInsFromFirebase();

      return currentScheduleData;
    } catch (e) {
      debugPrint('Quick load error: $e');
      return null;
    }
  }

  /// Background sync - chạy sau khi quick load
  Future<void> performBackgroundSync(
      Map<String, dynamic>? currentScheduleData) async {
    if (_mssv.isEmpty) return;

    try {
      // 1. Thông tin sinh viên
      await _syncStudentInfo();

      // 2. Điểm - check thay đổi
      final oldGrades = _storage.getGrades();
      final gradesData = await _syncGrades();
      final gradesChanged = _isDataChanged(gradesData, oldGrades);

      // 3. CTDT - check thay đổi
      final oldCurriculum = _storage.getCurriculum();
      final curriculumData = await _syncCurriculum();
      final curriculumChanged = _isDataChanged(curriculumData, oldCurriculum);

      // 4. Học phí - check thay đổi
      final oldTuition = _storage.getTuition();
      final tuitionData = await _syncTuition();
      final tuitionChanged = _isDataChanged(tuitionData, oldTuition);

      // 5. Thông báo
      await _syncNotifications();

      // 6. Chỉ đẩy Firebase nếu có thay đổi
      if (gradesChanged || curriculumChanged || tuitionChanged) {
        await _firebase.syncAllStudentData(
          mssv: _mssv,
          grades: gradesChanged ? gradesData : null,
          curriculum: curriculumChanged ? curriculumData : null,
          tuition: tuitionChanged ? tuitionData : null,
        );
      }

      // 7. Sync TKB các học kỳ còn lại
      await _syncRemainingSchedules(currentScheduleData);
    } catch (e) {
      debugPrint('Background sync error: $e');
    }
  }

  // ============ PRIVATE HELPERS ============

  Future<void> _syncStudentInfo() async {
    final response = await _api.getStudentInfo();
    if (response != null && response['data'] != null) {
      await _storage.saveStudentInfo({'data': response['data']});
    }
  }

  Future<Map<String, dynamic>?> _syncGrades() async {
    final response = await _api.getGrades();
    if (response != null && response['data'] != null) {
      final data = {'data': response['data']};
      await _storage.saveGrades(data);
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _syncCurriculum() async {
    final response = await _api.getCurriculum();
    if (response != null && response['data'] != null) {
      final data = {'data': response['data']};
      await _storage.saveCurriculum(data);
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _syncTuition() async {
    final response = await _api.getTuition();
    if (response != null && response['data'] != null) {
      final data = {'data': response['data']};
      await _storage.saveTuition(data);
      return data;
    }
    return null;
  }

  Future<void> _syncNotifications() async {
    final response = await _api.getNotifications();
    if (response != null && response['data'] != null) {
      await _storage.saveNotifications({'data': response['data']});
    }
  }

  Future<void> _syncCheckInsFromFirebase() async {
    final firebaseCheckIns = await _game.getCheckInsFromFirebase(_mssv);
    if (firebaseCheckIns.isNotEmpty) {
      await _storage.mergeCheckInsFromFirebase(firebaseCheckIns);
    }
  }

  /// Tải TKB tất cả học kỳ
  Future<Map<String, dynamic>?> _loadAllSchedules({
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      final semestersResponse = await _api.getSemesters();
      if (semestersResponse == null || semestersResponse['data'] == null) {
        return null;
      }

      final data = semestersResponse['data'];
      await _storage.saveSemesters({'data': data});

      final semesterList = data['ds_hoc_ky'] as List? ?? [];
      final Map<String, dynamic> allSchedules = {};

      for (int i = 0; i < semesterList.length; i++) {
        final semester = semesterList[i];
        final hocKy = semester['hoc_ky'] as int? ?? 0;
        if (hocKy == 0) continue;

        onProgress?.call(
          (i + 1) / semesterList.length,
          'Đang tải TKB học kỳ ${i + 1}/${semesterList.length}...',
        );

        final scheduleResponse = await _api.getSchedule(hocKy);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          await _storage.saveSchedule(hocKy, scheduleResponse['data']);
          allSchedules[hocKy.toString()] = scheduleResponse['data'];
        }
      }

      return allSchedules.isNotEmpty ? allSchedules : null;
    } catch (e) {
      debugPrint('Load all schedules error: $e');
      return null;
    }
  }

  /// Tải TKB học kỳ hiện tại
  Future<Map<String, dynamic>?> _loadCurrentSemesterSchedule() async {
    try {
      final semestersResponse = await _api.getSemesters();
      if (semestersResponse == null || semestersResponse['data'] == null) {
        return null;
      }

      final data = semestersResponse['data'];
      final currentSemester = data['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;

      final oldSchedule = _storage.getSchedule(currentSemester);
      await _storage.saveSemesters({'data': data});

      if (currentSemester > 0) {
        final scheduleResponse = await _api.getSchedule(currentSemester);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          await _storage.saveSchedule(currentSemester, scheduleResponse['data']);

          return {
            'currentSemester': currentSemester,
            'oldSchedule': oldSchedule,
            'newSchedule': scheduleResponse['data'],
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Load current schedule error: $e');
      return null;
    }
  }

  /// Sync TKB các học kỳ còn lại
  Future<void> _syncRemainingSchedules(
      Map<String, dynamic>? currentScheduleData) async {
    try {
      final semestersData = _storage.getSemesters();
      if (semestersData == null) return;

      final data = semestersData['data'];
      final semesterList = data['ds_hoc_ky'] as List? ?? [];
      final currentSemester = data['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;
      final savedSemesters = _storage.getSavedScheduleSemesters();

      for (var semester in semesterList) {
        final hocKy = semester['hoc_ky'] as int? ?? 0;
        if (hocKy == 0 || hocKy == currentSemester) continue;

        if (!savedSemesters.contains(hocKy)) {
          final scheduleResponse = await _api.getSchedule(hocKy);
          if (scheduleResponse != null && scheduleResponse['data'] != null) {
            await _storage.saveSchedule(hocKy, scheduleResponse['data']);
            await _firebase.saveSchedule(_mssv, hocKy, scheduleResponse['data']);
          }
        }
      }

      // TKB học kỳ hiện tại - dùng data đã load
      if (currentScheduleData != null) {
        final oldSchedule = currentScheduleData['oldSchedule'];
        final newSchedule = currentScheduleData['newSchedule'];
        final semester = currentScheduleData['currentSemester'] as int;

        if (_isDataChanged(newSchedule, oldSchedule)) {
          await _firebase.saveSchedule(_mssv, semester, newSchedule);
        }
      }

      await _firebase.saveSemesters(_mssv, semestersData);
    } catch (e) {
      debugPrint('Sync remaining schedules error: $e');
    }
  }

  /// So sánh 2 map data
  bool _isDataChanged(
      Map<String, dynamic>? newData, Map<String, dynamic>? oldData) {
    if (newData == null && oldData == null) return false;
    if (newData == null || oldData == null) return true;
    return jsonEncode(newData) != jsonEncode(oldData);
  }
}
