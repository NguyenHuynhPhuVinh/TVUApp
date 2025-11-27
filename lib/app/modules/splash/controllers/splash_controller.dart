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

  /// Tải TKB học kỳ hiện tại (ưu tiên cao nhất)
  Future<void> _loadCurrentSemesterSchedule(String mssv) async {
    try {
      // Lấy danh sách học kỳ
      final semestersResponse = await _apiService.getSemesters();
      if (semestersResponse == null || semestersResponse['data'] == null) {
        return;
      }

      final data = semestersResponse['data'];
      final currentSemester = data['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;

      // Lưu danh sách học kỳ
      await _localStorage.saveSemesters({'data': data});

      if (currentSemester > 0) {
        // Tải TKB học kỳ hiện tại
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
      // 1. Thông tin sinh viên
      final studentInfoResponse = await _apiService.getStudentInfo();
      if (studentInfoResponse != null && studentInfoResponse['data'] != null) {
        await _localStorage.saveStudentInfo({'data': studentInfoResponse['data']});
      }

      // 2. Điểm
      Map<String, dynamic>? gradesData;
      final gradesResponse = await _apiService.getGrades();
      if (gradesResponse != null && gradesResponse['data'] != null) {
        gradesData = {'data': gradesResponse['data']};
        await _localStorage.saveGrades(gradesData);
      }

      // 3. CTDT
      Map<String, dynamic>? curriculumData;
      final curriculumResponse = await _apiService.getCurriculum();
      if (curriculumResponse != null && curriculumResponse['data'] != null) {
        curriculumData = {'data': curriculumResponse['data']};
        await _localStorage.saveCurriculum(curriculumData);
      }

      // 4. Học phí
      Map<String, dynamic>? tuitionData;
      final tuitionResponse = await _apiService.getTuition();
      if (tuitionResponse != null && tuitionResponse['data'] != null) {
        tuitionData = {'data': tuitionResponse['data']};
        await _localStorage.saveTuition(tuitionData);
      }

      // 5. Thông báo
      final notificationsResponse = await _apiService.getNotifications();
      if (notificationsResponse != null && notificationsResponse['data'] != null) {
        await _localStorage.saveNotifications({'data': notificationsResponse['data']});
      }

      // 6. Đẩy lên Firebase
      await _firebaseService.syncAllStudentData(
        mssv: mssv,
        grades: gradesData,
        curriculum: curriculumData,
        tuition: tuitionData,
      );

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

        // Chỉ tải nếu chưa có hoặc cần cập nhật
        if (!savedSemesters.contains(hocKy)) {
          final scheduleResponse = await _apiService.getSchedule(hocKy);
          if (scheduleResponse != null && scheduleResponse['data'] != null) {
            await _localStorage.saveSchedule(hocKy, scheduleResponse['data']);
            await _firebaseService.saveSchedule(
                mssv, hocKy, scheduleResponse['data']);
          }
        }
      }

      // Đẩy TKB học kỳ hiện tại lên Firebase (đã tải ở splash)
      if (currentSemester > 0) {
        final currentSchedule = _localStorage.getSchedule(currentSemester);
        if (currentSchedule != null) {
          await _firebaseService.saveSchedule(mssv, currentSemester, currentSchedule);
        }
      }

      // Lưu semesters lên Firebase
      await _firebaseService.saveSemesters(mssv, semestersData);
    } catch (e) {
      print('Sync remaining schedules error: $e');
    }
  }
}
