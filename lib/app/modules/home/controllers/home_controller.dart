import 'package:get/get.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/local_storage_service.dart';

class HomeController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  final AuthService _authService = Get.find<AuthService>();
  final GameService _gameService = Get.find<GameService>();

  final studentName = ''.obs;
  final studentId = ''.obs;
  final className = ''.obs;
  final todaySchedule = <Map<String, dynamic>>[].obs;

  // Game stats
  int get coins => _gameService.stats.value.coins;
  int get diamonds => _gameService.stats.value.diamonds;
  int get level => _gameService.stats.value.level;
  int get currentXp => _gameService.stats.value.currentXp;
  int get xpForNextLevel => level * 100;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    loadStudentInfo();
    loadTodaySchedule();
  }

  void loadStudentInfo() {
    // Lấy MSSV từ auth service
    studentId.value = _authService.username.value;
    
    // Lấy thông tin sinh viên từ local
    final studentInfoData = _localStorage.getStudentInfo();
    if (studentInfoData != null && studentInfoData['data'] != null) {
      final student = studentInfoData['data'];
      studentName.value = student['ten_day_du'] ?? '';
      className.value = student['lop'] ?? '';
    }
  }

  void loadTodaySchedule() {
    final semestersData = _localStorage.getSemesters();
    if (semestersData == null || semestersData['data'] == null) return;

    final currentSemester = semestersData['data']['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;
    if (currentSemester == 0) return;

    final scheduleData = _localStorage.getSchedule(currentSemester);
    if (scheduleData != null) {
      final weeks = scheduleData['ds_tuan_tkb'] as List? ?? [];
      final now = DateTime.now();
      final todayWeekday = now.weekday + 1; // API uses 2=Mon, 3=Tue, etc.

      final List<Map<String, dynamic>> todayItems = [];
      for (var week in weeks) {
        // Check if current date is in this week
        final startStr = week['ngay_bat_dau'] as String?;
        final endStr = week['ngay_ket_thuc'] as String?;
        if (DateFormatter.isDateInRange(now, startStr, endStr)) {
          final schedules = week['ds_thoi_khoa_bieu'] as List? ?? [];
          for (var schedule in schedules) {
            if (schedule['thu_kieu_so'] == todayWeekday) {
              todayItems.add(Map<String, dynamic>.from(schedule));
            }
          }
          break;
        }
      }
      todayItems.sort((a, b) => (a['tiet_bat_dau'] ?? 0).compareTo(b['tiet_bat_dau'] ?? 0));
      todaySchedule.value = todayItems;
    }
  }
}
