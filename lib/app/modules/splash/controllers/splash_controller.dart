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

      // Ưu tiên tải TKB học kỳ hiện tại trước
      await _loadCurrentSemesterSchedule(mssv);

      // Vào main ngay
      Get.offAllNamed(Routes.main);

      // Chạy nền các sync khác
      _syncInBackground(mssv);
    } catch (e) {
      print('Splash error: $e');
      if (_authService.isLoggedIn.value) {
        Get.offAllNamed(Routes.main);
      } else {
        Get.offAllNamed(Routes.login);
      }
    }
  }

  /// So sánh 2 map data, return true nếu khác nhau
  bool _isDataChanged(Map<String, dynamic>? newData, Map<String, dynamic>? oldData) {
    if (newData == null && oldData == null) return false;
    if (newData == null || oldData == null) return true;
    return jsonEncode(newData) != jsonEncode(oldData);
  }

  /// Tải TKB học kỳ hiện tại (ưu tiên cao nhất)
  Future<void> _loadCurrentSemesterSchedule(String mssv) async {
    try {
      final semestersResponse = await _apiService.getSemesters();
      if (semestersResponse == null || semestersResponse['data'] == null) {
        return;
      }

      final data = semestersResponse['data'];
      final currentSemester = data['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;

      await _localStorage.saveSemesters({'data': data});

      if (currentSemester > 0) {
        final scheduleResponse = await _apiService.getSchedule(currentSemester);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          await _localStorage.saveSchedule(
              currentSemester, scheduleResponse['data']);
        }
      }
    } catch (e) {
      print('Load current schedule error: $e');
    }
  }

  /// Sync các dữ liệu khác chạy nền
  Future<void> _syncInBackground(String mssv) async {
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

      // 7. Sync TKB các học kỳ còn lại
      await _syncRemainingSchedules(mssv);
    } catch (e) {
      print('Background sync error: $e');
    }
  }

  /// Sync TKB các học kỳ còn lại (chạy nền)
  Future<void> _syncRemainingSchedules(String mssv) async {
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

      // TKB học kỳ hiện tại - lấy từ API để so sánh với local
      if (currentSemester > 0) {
        final oldSchedule = _localStorage.getSchedule(currentSemester);
        final scheduleResponse = await _apiService.getSchedule(currentSemester);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          final newSchedule = scheduleResponse['data'];
          if (_isDataChanged(newSchedule, oldSchedule)) {
            await _localStorage.saveSchedule(currentSemester, newSchedule);
            await _firebaseService.saveSchedule(mssv, currentSemester, newSchedule);
          }
        }
      }

      // Semesters - lấy từ API để so sánh với local
      final oldSemesters = _localStorage.getSemesters();
      final semestersResponse = await _apiService.getSemesters();
      if (semestersResponse != null && semestersResponse['data'] != null) {
        final newSemestersData = {'data': semestersResponse['data']};
        if (_isDataChanged(newSemestersData, oldSemesters)) {
          await _localStorage.saveSemesters(newSemestersData);
          await _firebaseService.saveSemesters(mssv, newSemestersData);
        }
      }
    } catch (e) {
      print('Sync remaining schedules error: $e');
    }
  }
}
