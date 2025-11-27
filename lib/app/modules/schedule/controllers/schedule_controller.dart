import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class ScheduleController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final selectedWeekIndex = 0.obs;
  final weeks = <Map<String, dynamic>>[].obs;
  final currentWeekSchedule = <Map<String, dynamic>>[].obs;
  final semester = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    semester.value = '${now.year}${now.month > 6 ? 1 : 2}';
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getSchedule(semester.value);
      if (response != null && response['data'] != null) {
        final weekList = response['data']['ds_tuan_tkb'] as List? ?? [];
        weeks.value = weekList.map((e) => Map<String, dynamic>.from(e)).toList();
        
        if (weeks.isNotEmpty) {
          selectWeek(0);
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
    return currentWeekSchedule.where((s) => s['thu'] == day).toList();
  }

  void changeSemester(String newSemester) {
    semester.value = newSemester;
    loadSchedule();
  }
}
