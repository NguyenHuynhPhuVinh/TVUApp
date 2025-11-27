import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class ScheduleController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final selectedWeekIndex = 0.obs;
  final weeks = <Map<String, dynamic>>[].obs;
  final currentWeekSchedule = <Map<String, dynamic>>[].obs;
  final semesters = <Map<String, dynamic>>[].obs;
  final selectedSemester = Rxn<int>();
  final currentSemester = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSemesters();
  }

  Future<void> loadSemesters() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getSemesters();
      if (response != null && response['data'] != null) {
        final data = response['data'];
        final semesterList = data['ds_hoc_ky'] as List? ?? [];
        semesters.value = semesterList.map((e) => Map<String, dynamic>.from(e)).toList();
        currentSemester.value = data['hoc_ky_theo_ngay_hien_tai'] ?? 0;
        
        if (semesters.isNotEmpty) {
          // Set default to current semester
          selectedSemester.value = currentSemester.value;
          await loadSchedule();
        }
      }
    } catch (e) {
      print('Error loading semesters: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSchedule() async {
    if (selectedSemester.value == null) return;
    
    isLoading.value = true;
    try {
      final response = await _apiService.getSchedule(selectedSemester.value!);
      if (response != null && response['data'] != null) {
        final weekList = response['data']['ds_tuan_tkb'] as List? ?? [];
        weeks.value = weekList.map((e) => Map<String, dynamic>.from(e)).toList();
        
        if (weeks.isNotEmpty) {
          // Find current week
          final now = DateTime.now();
          int currentWeekIdx = 0;
          for (int i = 0; i < weeks.length; i++) {
            final startStr = weeks[i]['ngay_bat_dau'] as String?;
            final endStr = weeks[i]['ngay_ket_thuc'] as String?;
            if (startStr != null && endStr != null) {
              final parts1 = startStr.split('/');
              final parts2 = endStr.split('/');
              if (parts1.length == 3 && parts2.length == 3) {
                final start = DateTime(int.parse(parts1[2]), int.parse(parts1[1]), int.parse(parts1[0]));
                final end = DateTime(int.parse(parts2[2]), int.parse(parts2[1]), int.parse(parts2[0]));
                if (now.isAfter(start.subtract(const Duration(days: 1))) && now.isBefore(end.add(const Duration(days: 1)))) {
                  currentWeekIdx = i;
                  break;
                }
              }
            }
          }
          selectWeek(currentWeekIdx);
        }
      }
    } catch (e) {
      print('Error loading schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectWeek(int index) {
    if (index >= 0 && index < weeks.length) {
      selectedWeekIndex.value = index;
      final schedules = weeks[index]['ds_thoi_khoa_bieu'] as List? ?? [];
      currentWeekSchedule.value = schedules.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  List<Map<String, dynamic>> getScheduleByDay(int day) {
    return currentWeekSchedule.where((s) => s['thu_kieu_so'] == day).toList()
      ..sort((a, b) => (a['tiet_bat_dau'] ?? 0).compareTo(b['tiet_bat_dau'] ?? 0));
  }

  void changeSemester(int? newSemester) {
    if (newSemester != null) {
      selectedSemester.value = newSemester;
      loadSchedule();
    }
  }

  String getSemesterName(int hocKy) {
    final found = semesters.firstWhereOrNull((s) => s['hoc_ky'] == hocKy);
    return found?['ten_hoc_ky'] ?? 'Học kỳ $hocKy';
  }
}
