import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../routes/app_routes.dart';

class SyncController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final progress = 0.0.obs;
  final currentStatus = 'Đang chuẩn bị...'.obs;

  @override
  void onInit() {
    super.onInit();
    _startSync();
  }

  Future<void> _startSync() async {
    final mssv = _authService.username.value;
    if (mssv.isEmpty) {
      Get.offAllNamed(Routes.login);
      return;
    }

    try {
      Map<String, dynamic>? gradesData;
      Map<String, dynamic>? curriculumData;
      Map<String, dynamic>? tuitionData;

      // 1. Tải thông tin sinh viên (chỉ lưu local)
      currentStatus.value = 'Đang tải thông tin sinh viên...';
      progress.value = 0.05;
      final studentInfoResponse = await _apiService.getStudentInfo();
      if (studentInfoResponse != null && studentInfoResponse['data'] != null) {
        await _localStorage.saveStudentInfo({'data': studentInfoResponse['data']});
      }

      // 2. Tải điểm
      currentStatus.value = 'Đang tải điểm học tập...';
      progress.value = 0.1;
      final gradesResponse = await _apiService.getGrades();
      if (gradesResponse != null && gradesResponse['data'] != null) {
        gradesData = {'data': gradesResponse['data']};
        await _localStorage.saveGrades(gradesData);
      }

      // 3. Tải CTDT
      currentStatus.value = 'Đang tải chương trình đào tạo...';
      progress.value = 0.15;
      final curriculumResponse = await _apiService.getCurriculum();
      if (curriculumResponse != null && curriculumResponse['data'] != null) {
        curriculumData = {'data': curriculumResponse['data']};
        await _localStorage.saveCurriculum(curriculumData);
      }

      // 4. Tải học phí
      currentStatus.value = 'Đang tải thông tin học phí...';
      progress.value = 0.2;
      final tuitionResponse = await _apiService.getTuition();
      if (tuitionResponse != null && tuitionResponse['data'] != null) {
        tuitionData = {'data': tuitionResponse['data']};
        await _localStorage.saveTuition(tuitionData);
      }

      // 5. Tải thông báo (chỉ lưu local)
      currentStatus.value = 'Đang tải thông báo...';
      progress.value = 0.25;
      final notificationsResponse = await _apiService.getNotifications();
      if (notificationsResponse != null && notificationsResponse['data'] != null) {
        await _localStorage.saveNotifications({'data': notificationsResponse['data']});
      }

      // 6. Đẩy điểm, CTDT, học phí lên Firebase
      currentStatus.value = 'Đang đồng bộ dữ liệu...';
      progress.value = 0.3;
      await _firebaseService.syncAllStudentData(
        mssv: mssv,
        grades: gradesData,
        curriculum: curriculumData,
        tuition: tuitionData,
      );

      // 5. Sync thời khóa biểu
      await _syncSchedules(mssv);

      progress.value = 1.0;
      currentStatus.value = 'Hoàn tất!';
      await Future.delayed(const Duration(milliseconds: 500));

      // Chuyển sang màn hình chính
      Get.offAllNamed(Routes.main);
    } catch (e) {
      print('Sync error: $e');
      currentStatus.value = 'Có lỗi xảy ra, đang chuyển trang...';
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.main);
    }
  }

  /// Sync thời khóa biểu
  /// - Lần đầu: tải TKB tất cả học kỳ
  /// - Lần sau: chỉ cập nhật học kỳ hiện tại + check học kỳ mới
  Future<void> _syncSchedules(String mssv) async {
    currentStatus.value = 'Đang tải danh sách học kỳ...';
    progress.value = 0.5;

    // Lấy danh sách học kỳ từ API
    final semestersResponse = await _apiService.getSemesters();
    if (semestersResponse == null || semestersResponse['data'] == null) {
      return;
    }

    final data = semestersResponse['data'];
    final semesterList = data['ds_hoc_ky'] as List? ?? [];
    final currentSemester = data['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;

    // Lưu danh sách học kỳ (local + Firebase)
    await _localStorage.saveSemesters({'data': data});
    await _firebaseService.saveSemesters(mssv, {'data': data});

    // Lấy danh sách học kỳ đã lưu local
    final savedSemesters = _localStorage.getSavedScheduleSemesters();
    final isFirstSync = savedSemesters.isEmpty;

    if (isFirstSync) {
      // Lần đầu: tải TKB tất cả học kỳ
      currentStatus.value = 'Đang tải thời khóa biểu (lần đầu)...';
      final totalSemesters = semesterList.length;

      for (int i = 0; i < totalSemesters; i++) {
        final semester = semesterList[i];
        final hocKy = semester['hoc_ky'] as int? ?? 0;
        if (hocKy == 0) continue;

        currentStatus.value = 'Đang tải TKB học kỳ ${i + 1}/$totalSemesters...';
        progress.value = 0.5 + (0.4 * (i + 1) / totalSemesters);

        final scheduleResponse = await _apiService.getSchedule(hocKy);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          // Lưu local + Firebase
          await _localStorage.saveSchedule(hocKy, scheduleResponse['data']);
          await _firebaseService.saveSchedule(
              mssv, hocKy, scheduleResponse['data']);
        }
      }
    } else {
      // Lần sau: chỉ cập nhật học kỳ hiện tại + check học kỳ mới
      currentStatus.value = 'Đang cập nhật thời khóa biểu...';
      progress.value = 0.6;

      // Tìm học kỳ mới (chưa có local)
      final newSemesters = <int>[];
      for (var semester in semesterList) {
        final hocKy = semester['hoc_ky'] as int? ?? 0;
        if (hocKy > 0 && !savedSemesters.contains(hocKy)) {
          newSemesters.add(hocKy);
        }
      }

      // Tải TKB học kỳ mới (nếu có)
      for (int i = 0; i < newSemesters.length; i++) {
        final hocKy = newSemesters[i];
        currentStatus.value = 'Đang tải TKB học kỳ mới...';
        progress.value = 0.6 + (0.2 * (i + 1) / newSemesters.length);

        final scheduleResponse = await _apiService.getSchedule(hocKy);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          // Lưu local + Firebase
          await _localStorage.saveSchedule(hocKy, scheduleResponse['data']);
          await _firebaseService.saveSchedule(
              mssv, hocKy, scheduleResponse['data']);
        }
      }

      // Cập nhật TKB học kỳ hiện tại (chỉ khi không phải học kỳ mới vừa tải)
      if (currentSemester > 0 && !newSemesters.contains(currentSemester)) {
        currentStatus.value = 'Đang cập nhật TKB học kỳ hiện tại...';
        progress.value = 0.9;

        final scheduleResponse = await _apiService.getSchedule(currentSemester);
        if (scheduleResponse != null && scheduleResponse['data'] != null) {
          // Lưu local + Firebase
          await _localStorage.saveSchedule(
              currentSemester, scheduleResponse['data']);
          await _firebaseService.saveSchedule(
              mssv, currentSemester, scheduleResponse['data']);
        }
      }
    }
  }
}
