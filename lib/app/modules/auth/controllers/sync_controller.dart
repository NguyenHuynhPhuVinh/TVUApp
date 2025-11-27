import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../routes/app_routes.dart';

class SyncController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

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

      // 1. Tải điểm
      currentStatus.value = 'Đang tải điểm học tập...';
      progress.value = 0.2;
      final gradesResponse = await _apiService.getGrades();
      if (gradesResponse != null && gradesResponse['data'] != null) {
        gradesData = {'data': gradesResponse['data']};
      }
      progress.value = 0.4;

      // 2. Tải CTDT
      currentStatus.value = 'Đang tải chương trình đào tạo...';
      final curriculumResponse = await _apiService.getCurriculum();
      if (curriculumResponse != null && curriculumResponse['data'] != null) {
        curriculumData = {'data': curriculumResponse['data']};
      }
      progress.value = 0.6;

      // 3. Tải học phí
      currentStatus.value = 'Đang tải thông tin học phí...';
      final tuitionResponse = await _apiService.getTuition();
      if (tuitionResponse != null && tuitionResponse['data'] != null) {
        tuitionData = {'data': tuitionResponse['data']};
      }
      progress.value = 0.8;

      // 4. Đẩy lên Firebase (CHỈ điểm, CTDT, học phí - KHÔNG lưu info cá nhân)
      currentStatus.value = 'Đang đồng bộ lên Firebase...';
      await _firebaseService.syncAllStudentData(
        mssv: mssv,
        grades: gradesData,
        curriculum: curriculumData,
        tuition: tuitionData,
      );
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
}
