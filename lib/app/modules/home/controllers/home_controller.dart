import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final studentName = ''.obs;
  final studentId = ''.obs;
  final className = ''.obs;
  final todaySchedule = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([
      loadStudentInfo(),
      loadTodaySchedule(),
    ]);
    isLoading.value = false;
  }

  Future<void> refreshData() async {
    await loadData();
  }

  Future<void> loadStudentInfo() async {
    try {
      final response = await _apiService.getStudentInfo();
      print('Student Info Response: $response');
      if (response != null && response['data'] != null) {
        final student = response['data'];
        studentName.value = student['ten_day_du'] ?? '';
        studentId.value = student['ma_sv'] ?? '';
        className.value = student['lop'] ?? '';
      }
    } catch (e) {
      print('Error loading student info: $e');
    }
  }

  Future<void> loadTodaySchedule() async {
    try {
      // Get current semester first
      final semesterResponse = await _apiService.getSemesters();
      if (semesterResponse == null || semesterResponse['data'] == null) return;
      
      final currentSemester = semesterResponse['data']['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;
      if (currentSemester == 0) return;
      
      final response = await _apiService.getSchedule(currentSemester);
      if (response != null && response['data'] != null) {
        final weeks = response['data']['ds_tuan_tkb'] as List? ?? [];
        final now = DateTime.now();
        final todayWeekday = now.weekday + 1; // API uses 2=Mon, 3=Tue, etc.
        
        final List<Map<String, dynamic>> todayItems = [];
        for (var week in weeks) {
          // Check if current date is in this week
          final startStr = week['ngay_bat_dau'] as String?;
          final endStr = week['ngay_ket_thuc'] as String?;
          if (startStr != null && endStr != null) {
            final parts1 = startStr.split('/');
            final parts2 = endStr.split('/');
            if (parts1.length == 3 && parts2.length == 3) {
              final start = DateTime(int.parse(parts1[2]), int.parse(parts1[1]), int.parse(parts1[0]));
              final end = DateTime(int.parse(parts2[2]), int.parse(parts2[1]), int.parse(parts2[0]));
              if (now.isAfter(start.subtract(const Duration(days: 1))) && now.isBefore(end.add(const Duration(days: 1)))) {
                final schedules = week['ds_thoi_khoa_bieu'] as List? ?? [];
                for (var schedule in schedules) {
                  if (schedule['thu_kieu_so'] == todayWeekday) {
                    todayItems.add(Map<String, dynamic>.from(schedule));
                  }
                }
                break;
              }
            }
          }
        }
        todayItems.sort((a, b) => (a['tiet_bat_dau'] ?? 0).compareTo(b['tiet_bat_dau'] ?? 0));
        todaySchedule.value = todayItems;
      }
    } catch (e) {
      print('Error loading today schedule: $e');
    }
  }
}
