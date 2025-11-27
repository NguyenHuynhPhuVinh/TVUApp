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
      final now = DateTime.now();
      final semester = '${now.year}${now.month > 6 ? 1 : 2}';
      
      final response = await _apiService.getSchedule(semester);
      if (response != null && response['data'] != null) {
        final weeks = response['data']['ds_tuan_tkb'] as List? ?? [];
        final today = DateTime.now().weekday;
        
        final List<Map<String, dynamic>> todayItems = [];
        for (var week in weeks) {
          final schedules = week['ds_thoi_khoa_bieu'] as List? ?? [];
          for (var schedule in schedules) {
            if (schedule['thu'] == today) {
              todayItems.add(Map<String, dynamic>.from(schedule));
            }
          }
        }
        todaySchedule.value = todayItems;
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
