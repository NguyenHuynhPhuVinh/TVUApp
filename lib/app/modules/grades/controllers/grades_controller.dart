import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class GradesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final gradesBySemester = <Map<String, dynamic>>[].obs;
  final selectedSemesterIndex = 0.obs;

  // Tích lũy từ học kỳ đang chọn
  String get gpa10 => currentSemester?['dtb_tich_luy_he_10']?.toString() ?? '0';
  String get gpa4 => currentSemester?['dtb_tich_luy_he_4']?.toString() ?? '0';
  String get totalCredits => currentSemester?['so_tin_chi_dat_tich_luy']?.toString() ?? '0';
  String get semesterGpa10 => currentSemester?['dtb_hk_he10']?.toString() ?? '';
  String get semesterGpa4 => currentSemester?['dtb_hk_he4']?.toString() ?? '';
  String get semesterCredits => currentSemester?['so_tin_chi_dat_hk']?.toString() ?? '';
  String get classification => currentSemester?['xep_loai_tkb_hk']?.toString() ?? '';

  Map<String, dynamic>? get currentSemester {
    if (gradesBySemester.isEmpty) return null;
    return gradesBySemester[selectedSemesterIndex.value];
  }

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
        final semesters = data['ds_diem_hocky'] as List? ?? [];
        gradesBySemester.value = semesters.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error loading grades: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectSemester(int index) {
    selectedSemesterIndex.value = index;
  }

  List<Map<String, dynamic>> get currentSemesterGrades {
    if (currentSemester == null) return [];
    final grades = currentSemester!['ds_diem_mon_hoc'] as List? ?? [];
    return grades.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
