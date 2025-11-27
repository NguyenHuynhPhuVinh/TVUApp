import 'package:get/get.dart';
import '../../../data/services/local_storage_service.dart';

class CurriculumController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final semesters = <Map<String, dynamic>>[].obs;
  final selectedSemesterIndex = 0.obs;
  final majorName = ''.obs;

  // Thống kê
  int get totalCredits {
    int total = 0;
    for (var sem in semesters) {
      final subjects = sem['ds_CTDT_mon_hoc'] as List? ?? [];
      for (var sub in subjects) {
        total += int.tryParse(sub['so_tin_chi']?.toString() ?? '0') ?? 0;
      }
    }
    return total;
  }

  int get completedCredits {
    int total = 0;
    for (var sem in semesters) {
      final subjects = sem['ds_CTDT_mon_hoc'] as List? ?? [];
      for (var sub in subjects) {
        if (sub['mon_da_dat'] == 'x') {
          total += int.tryParse(sub['so_tin_chi']?.toString() ?? '0') ?? 0;
        }
      }
    }
    return total;
  }

  int get totalSubjects {
    int total = 0;
    for (var sem in semesters) {
      final subjects = sem['ds_CTDT_mon_hoc'] as List? ?? [];
      total += subjects.length;
    }
    return total;
  }

  int get completedSubjects {
    int total = 0;
    for (var sem in semesters) {
      final subjects = sem['ds_CTDT_mon_hoc'] as List? ?? [];
      for (var sub in subjects) {
        if (sub['mon_da_dat'] == 'x') total++;
      }
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    loadCurriculum();
  }

  void loadCurriculum() {
    final curriculumData = _localStorage.getCurriculum();
    if (curriculumData != null && curriculumData['data'] != null) {
      final data = curriculumData['data'];

      // Lấy tên ngành
      final majors = data['ds_nganh_sinh_vien'] as List? ?? [];
      if (majors.isNotEmpty) {
        majorName.value = majors[0]['ten_nganh'] ?? '';
      }

      // Lấy danh sách học kỳ
      final semList = data['ds_CTDT_hocky'] as List? ?? [];
      semesters.value = semList.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  void selectSemester(int index) {
    selectedSemesterIndex.value = index;
  }

  List<Map<String, dynamic>> get currentSemesterSubjects {
    if (semesters.isEmpty) return [];
    final semester = semesters[selectedSemesterIndex.value];
    final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
    return subjects.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
