import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class GradesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final gradesBySemester = <Map<String, dynamic>>[].obs;
  final gpa10 = 0.0.obs;
  final gpa4 = 0.0.obs;
  final totalCredits = 0.obs;
  final selectedSemesterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadGrades();
  }

  Future<void> loadGrades() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getGrades();
      if (response != null && response['data'] != null) {
        final data = response['data'];
        
        gpa10.value = (data['dtb_tich_luy_he_10'] ?? 0).toDouble();
        gpa4.value = (data['dtb_tich_luy_he_4'] ?? 0).toDouble();
        totalCredits.value = data['so_tin_chi_dat'] ?? 0;
        
        final semesters = data['ds_diem_hocky'] as List? ?? [];
        gradesBySemester.value = semesters.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải điểm học tập');
    } finally {
      isLoading.value = false;
    }
  }

  void selectSemester(int index) {
    selectedSemesterIndex.value = index;
  }

  List<Map<String, dynamic>> get currentSemesterGrades {
    if (gradesBySemester.isEmpty) return [];
    final semester = gradesBySemester[selectedSemesterIndex.value];
    final grades = semester['ds_diem_mon_hoc'] as List? ?? [];
    return grades.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
