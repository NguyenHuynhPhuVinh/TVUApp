import 'dart:convert';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  // Progress cho UI
  final syncProgress = 0.0.obs;
  final syncStatus = ''.obs;
  final isFirstTimeSync = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!_authService.isLoggedIn.value) {
        Get.offAllNamed(Routes.login);
        return;
      }

      final mssv = _authService.username.value;
      if (mssv.isEmpty) {
        Get.offAllNamed(Routes.login);
        return;
      }

      // Check xem đây có phải lần đầu (chưa có data local) hay không
      final hasLocalData = _localStorage.getGrades() != null || 
                           _localStorage.getSemesters() != null;
      
      // Nếu vừa login xong (từ argument) hoặc chưa có data local -> sync hết
      final justLoggedIn = Get.arguments?['justLoggedIn'] == true;
      
      if (justLoggedIn || !hasLocalData) {
        isFirstTimeSync.value = true;
        await _fullSync(mssv);
      } else {
        // Đã có data -> load nhanh TKB hiện tại, sync nền
        final currentScheduleData = await _loadCurrentSemesterSchedule(mssv);
        Get.offAllNamed(Routes.main);
        _syncInBackground(mssv, currentScheduleData);
      }
    } catch (e) {
      print('Splash error: $e');
      if (_authService.isLoggedIn.value) {
        Get.offAllNamed(Routes.main);
      } else {
        Get.offAllNamed(Routes.login);
      }
    }
  }

  /// Full sync - chạy khi lần đầu login hoặc chưa có data
  Future<void> _fullSync(String mssv) async {
    try {
      // 1. Thông tin sinh viên
      syncStatus.value = 'Đang tải thông tin sinh viên...';
      syncProgress.value = 0.1;
      final studentInfoResponse = await _apiService.getStudentInfo();
      if (studentInfoResponse != null && studentInfoResponse['data'] != null) {
        await _localStorage.saveStudentInfo({'data': studentInfoResponse['data']});
      }

      // 2. Danh sách học kỳ + TKB tất cả học kỳ
      syncStatus.value = 'Đang tải thời khóa biểu...';
      syncProgress.value = 0.15;
      final allSchedulesData = await _loadAllSchedules(mssv);

      // 3. Điểm
      syncStatus.value = 'Đang tải điểm...';
      syncProgress.value = 0.35;
      Map<String, dynamic>? gradesData;
      final gradesResponse = await _apiService.getGrades();
      if (gradesResponse != null && gradesResponse['data'] != null) {
        gradesData = {'data': gradesResponse['data']};
        await _localStorage.saveGrades(gradesData);
      }

      // 4. CTDT
      syncStatus.value = 'Đang tải chương trình đào tạo...';
      syncProgress.value = 0.55;
      Map<String, dynamic>? curriculumData;
      final curriculumResponse = await _apiService.getCurriculum();
      if (curriculumResponse != null && curriculumResponse['data'] != null) {
        curriculumData = {'data': curriculumResponse['data']};
        await _localStorage.saveCurriculum(curriculumData);
      }

      // 5. Học phí
      syncStatus.value = 'Đang tải học phí...';
      syncProgress.value = 0.7;
      Map<String, dynamic>? tuitionData;
      final tuitionResponse = await _apiService.getTuition();
      if (tuitionResponse != null && tuitionResponse['data'] != null) {
        tuitionData = {'data': tuitionResponse['data']};
        await _localStorage.saveTuition(tuitionData);
      }

      // 6. Thông báo
      syncStatus.value = 'Đang tải thông báo...';
      syncProgress.value = 0.75;
      final notificationsResponse = await _apiService.getNotifications();
      if (notificationsResponse != null && notificationsResponse['data'] != null) {
        await _localStorage.saveNotifications({'data': notificationsResponse['data']});
      }

      // 7. Sync Firebase
      syncStatus.value = 'Đang đồng bộ dữ liệu...';
      syncProgress.value = 0.85;
      await _firebaseService.syncAllStudentData(
        mssv: mssv,
        grades: gradesData,
        curriculum: curriculumData,
        tuition: tuitionData,
      );

      // Sync tất cả TKB lên Firebase
      if (allSchedulesData != null) {
        for (var entry in allSchedulesData.entries) {
          final semester = int.tryParse(entry.key) ?? 0;
          if (semester > 0) {
            await _firebaseService.saveSchedule(mssv, semester, entry.value);
          }
        }
      }

      final semestersData = _localStorage.getSemesters();
      if (semestersData != null) {
        await _firebaseService.saveSemesters(mssv, semestersData);
      }

      syncProgress.value = 1.0;
      syncStatus.value = 'Hoàn tất!';
      
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(Routes.main);
    } catch (e) {
      print('Full sync error: $e');
      // Vẫn vào main dù có lỗi
      Get.offAllNamed(Routes.main);
    }
  }

  /// So sánh 2 map data, return true nếu khác nhau
  bool _isDataChanged(Map<String, dynamic>? newData, Map<String, dynamic>? oldData) {
    if (newData == null && oldData == null) return false;
    if (newData == null || oldData == null) return true;
    return jsonEncode(newData) != jsonEncode(oldData);
  }

  /// Tải TKB tất cả học kỳ (dùng cho lần đầu login)
  /// Returns: `Map<semesterId, scheduleData>`
  Future<Map<String, dynamic>?> _loadAllSchedules(String mssv) async {
    try {
      final semestersResponse = await _apiService.getSemesters();
      if (semestersResponse == null || semestersResponse['data'] == null) {
        return null;
      }

      final data = semestersResponse['data'];
      await _localStorage.saveSemesters({'data': data});

      final semesterList = data['ds_hoc_ky'] as List? ?? [];
      final Map<String, dynamic> allSchedules = {};

      for (int i = 0; i < semesterList.length; i++) {
        final semester = semesterList[i];
        final hocKy = semester['hoc_ky'] as int? ?? 0;
        if (hocKy == 0) continue;

        syncStatus.value = 'Đang tải TKB học kỳ ${i + 1}/${semesterList.length}...';
        syncProgress.value = 0.15 + (0.2 * (i + 1) / semesterList.length);

        final scheduleResponse = await _apiService.getSchedule(hocKy);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          await _localStorage.saveSchedule(hocKy, scheduleResponse['data']);
          allSchedules[hocKy.toString()] = scheduleResponse['data'];
        }
      }

      return allSchedules.isNotEmpty ? allSchedules : null;
    } catch (e) {
      print('Load all schedules error: $e');
      return null;
    }
  }

  /// Tải TKB học kỳ hiện tại (ưu tiên cao nhất)
  /// Returns: Map chứa oldSchedule và newSchedule để dùng cho sync sau
  Future<Map<String, dynamic>?> _loadCurrentSemesterSchedule(String mssv) async {
    try {
      final semestersResponse = await _apiService.getSemesters();
      if (semestersResponse == null || semestersResponse['data'] == null) {
        return null;
      }

      final data = semestersResponse['data'];
      final currentSemester = data['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;

      // Lưu old schedule trước khi ghi đè
      final oldSchedule = _localStorage.getSchedule(currentSemester);
      
      await _localStorage.saveSemesters({'data': data});

      if (currentSemester > 0) {
        final scheduleResponse = await _apiService.getSchedule(currentSemester);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          await _localStorage.saveSchedule(
              currentSemester, scheduleResponse['data']);
          
          // Return để dùng cho sync Firebase sau
          return {
            'currentSemester': currentSemester,
            'oldSchedule': oldSchedule,
            'newSchedule': scheduleResponse['data'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Load current schedule error: $e');
      return null;
    }
  }

  /// Sync các dữ liệu khác chạy nền
  Future<void> _syncInBackground(String mssv, Map<String, dynamic>? currentScheduleData) async {
    try {
      // 1. Thông tin sinh viên (chỉ lưu local)
      final studentInfoResponse = await _apiService.getStudentInfo();
      if (studentInfoResponse != null && studentInfoResponse['data'] != null) {
        await _localStorage.saveStudentInfo({'data': studentInfoResponse['data']});
      }

      // 2. Điểm - check thay đổi trước khi đẩy Firebase
      Map<String, dynamic>? gradesData;
      bool gradesChanged = false;
      final oldGrades = _localStorage.getGrades();
      final gradesResponse = await _apiService.getGrades();
      if (gradesResponse != null && gradesResponse['data'] != null) {
        gradesData = {'data': gradesResponse['data']};
        gradesChanged = _isDataChanged(gradesData, oldGrades);
        if (gradesChanged) {
          await _localStorage.saveGrades(gradesData);
        }
      }

      // 3. CTDT - check thay đổi
      Map<String, dynamic>? curriculumData;
      bool curriculumChanged = false;
      final oldCurriculum = _localStorage.getCurriculum();
      final curriculumResponse = await _apiService.getCurriculum();
      if (curriculumResponse != null && curriculumResponse['data'] != null) {
        curriculumData = {'data': curriculumResponse['data']};
        curriculumChanged = _isDataChanged(curriculumData, oldCurriculum);
        if (curriculumChanged) {
          await _localStorage.saveCurriculum(curriculumData);
        }
      }

      // 4. Học phí - check thay đổi
      Map<String, dynamic>? tuitionData;
      bool tuitionChanged = false;
      final oldTuition = _localStorage.getTuition();
      final tuitionResponse = await _apiService.getTuition();
      if (tuitionResponse != null && tuitionResponse['data'] != null) {
        tuitionData = {'data': tuitionResponse['data']};
        tuitionChanged = _isDataChanged(tuitionData, oldTuition);
        if (tuitionChanged) {
          await _localStorage.saveTuition(tuitionData);
        }
      }

      // 5. Thông báo (chỉ lưu local)
      final notificationsResponse = await _apiService.getNotifications();
      if (notificationsResponse != null && notificationsResponse['data'] != null) {
        await _localStorage.saveNotifications({'data': notificationsResponse['data']});
      }

      // 6. Chỉ đẩy Firebase nếu có thay đổi
      if (gradesChanged || curriculumChanged || tuitionChanged) {
        await _firebaseService.syncAllStudentData(
          mssv: mssv,
          grades: gradesChanged ? gradesData : null,
          curriculum: curriculumChanged ? curriculumData : null,
          tuition: tuitionChanged ? tuitionData : null,
        );
      }

      // 7. Sync TKB các học kỳ còn lại (truyền data đã load)
      await _syncRemainingSchedules(mssv, currentScheduleData);
    } catch (e) {
      print('Background sync error: $e');
    }
  }

  /// Sync TKB các học kỳ còn lại (chạy nền)
  Future<void> _syncRemainingSchedules(String mssv, Map<String, dynamic>? currentScheduleData) async {
    try {
      final semestersData = _localStorage.getSemesters();
      if (semestersData == null) return;

      final data = semestersData['data'];
      final semesterList = data['ds_hoc_ky'] as List? ?? [];
      final currentSemester = data['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;
      final savedSemesters = _localStorage.getSavedScheduleSemesters();

      for (var semester in semesterList) {
        final hocKy = semester['hoc_ky'] as int? ?? 0;
        if (hocKy == 0 || hocKy == currentSemester) continue;

        if (!savedSemesters.contains(hocKy)) {
          final scheduleResponse = await _apiService.getSchedule(hocKy);
          if (scheduleResponse != null && scheduleResponse['data'] != null) {
            await _localStorage.saveSchedule(hocKy, scheduleResponse['data']);
            await _firebaseService.saveSchedule(
                mssv, hocKy, scheduleResponse['data']);
          }
        }
      }

      // TKB học kỳ hiện tại - dùng data đã load, không gọi API lại
      if (currentScheduleData != null) {
        final oldSchedule = currentScheduleData['oldSchedule'];
        final newSchedule = currentScheduleData['newSchedule'];
        final semester = currentScheduleData['currentSemester'] as int;
        
        if (_isDataChanged(newSchedule, oldSchedule)) {
          await _firebaseService.saveSchedule(mssv, semester, newSchedule);
        }
      }

      // Semesters - push Firebase nếu có thay đổi (đã lưu local ở _loadCurrentSemesterSchedule)
      // Không cần gọi API lại vì đã có trong local
      await _firebaseService.saveSemesters(mssv, semestersData);
    } catch (e) {
      print('Sync remaining schedules error: $e');
    }
  }
}
