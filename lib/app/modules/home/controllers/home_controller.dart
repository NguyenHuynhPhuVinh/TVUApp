import 'package:get/get.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../data/models/player_stats.dart';
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
  
  // Badge indicators
  final hasPendingCheckIn = false.obs;
  final hasUnclaimedTuitionBonus = false.obs;
  final hasUnclaimedCurriculumReward = false.obs;

  // Game stats - expose reactive stats directly
  PlayerStats get gameStats => _gameService.stats.value;
  int get coins => _gameService.stats.value.coins;
  int get diamonds => _gameService.stats.value.diamonds;
  int get level => _gameService.stats.value.level;
  int get currentXp => _gameService.stats.value.currentXp;
  int get xpForNextLevel => level * 100;

  @override
  void onInit() {
    super.onInit();
    loadData();
    
    // Listen game stats changes để cập nhật badge
    ever(_gameService.stats, (_) {
      checkUnclaimedTuitionBonus();
      checkUnclaimedCurriculumReward();
    });
  }

  void loadData() {
    loadStudentInfo();
    loadTodaySchedule();
    checkPendingCheckIn();
    checkUnclaimedTuitionBonus();
    checkUnclaimedCurriculumReward();
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

  /// Kiểm tra có buổi học nào có thể điểm danh hôm nay không
  void checkPendingCheckIn() {
    final now = DateTime.now();
    
    for (var lesson in todaySchedule) {
      final tietBatDau = lesson['tiet_bat_dau'] as int? ?? 1;
      final soTiet = lesson['so_tiet'] as int? ?? 1;
      
      // Tính thời gian có thể check-in (30p trước giờ học)
      final checkInStart = GameService.calculateCheckInStartTime(now, tietBatDau);
      final checkInDeadline = GameService.calculateCheckInDeadline(now);
      final endTime = GameService.calculateLessonEndTime(now, tietBatDau, soTiet);
      
      // Kiểm tra buổi học có sau thời điểm init game không
      final initializedAt = _gameService.stats.value.initializedAt;
      if (initializedAt != null && endTime.isBefore(initializedAt)) {
        continue; // Buổi học trước khi init game
      }
      
      // Kiểm tra có trong khoảng thời gian điểm danh không
      if (now.isAfter(checkInStart) && now.isBefore(checkInDeadline)) {
        // Kiểm tra đã điểm danh chưa
        final checkInKey = _createCheckInKey(lesson, now);
        if (!_localStorage.hasCheckedIn(checkInKey)) {
          hasPendingCheckIn.value = true;
          return;
        }
      }
    }
    hasPendingCheckIn.value = false;
  }

  /// Tạo key check-in cho buổi học
  String _createCheckInKey(Map<String, dynamic> lesson, DateTime date) {
    final semestersData = _localStorage.getSemesters();
    final currentSemester = semestersData?['data']?['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;
    
    // Tìm tuần hiện tại
    final scheduleData = _localStorage.getSchedule(currentSemester);
    int week = 0;
    if (scheduleData != null) {
      final weeks = scheduleData['ds_tuan_tkb'] as List? ?? [];
      for (var w in weeks) {
        final startStr = w['ngay_bat_dau'] as String?;
        final endStr = w['ngay_ket_thuc'] as String?;
        if (DateFormatter.isDateInRange(date, startStr, endStr)) {
          week = w['tuan_hoc_ky'] ?? 0;
          break;
        }
      }
    }
    
    final day = lesson['thu_kieu_so'] ?? 0;
    final tietBatDau = lesson['tiet_bat_dau'] ?? 0;
    final maMon = lesson['ma_mon'] ?? '';
    return '${currentSemester}_${week}_${day}_${tietBatDau}_$maMon';
  }

  /// Kiểm tra có học phí nào chưa claim bonus không
  void checkUnclaimedTuitionBonus() {
    final tuitionData = _localStorage.getTuition();
    if (tuitionData == null || tuitionData['data'] == null) {
      hasUnclaimedTuitionBonus.value = false;
      return;
    }

    final tuitionList = tuitionData['data']['ds_hoc_phi_hoc_ky'] as List? ?? [];
    
    for (var item in tuitionList) {
      // Dùng NumberFormatter để parse vì data có thể là String hoặc int
      final daThu = NumberFormatter.parseInt(item['da_thu']);
      final semesterId = item['ten_hoc_ky']?.toString() ?? '';
      
      // Nếu đã đóng tiền và chưa claim bonus
      if (daThu > 0 && semesterId.isNotEmpty) {
        if (!_gameService.stats.value.isSemesterClaimed(semesterId)) {
          hasUnclaimedTuitionBonus.value = true;
          return;
        }
      }
    }
    hasUnclaimedTuitionBonus.value = false;
  }

  /// Kiểm tra có môn học nào đạt chưa nhận thưởng không
  void checkUnclaimedCurriculumReward() {
    final curriculumData = _localStorage.getCurriculum();
    if (curriculumData == null || curriculumData['data'] == null) {
      hasUnclaimedCurriculumReward.value = false;
      return;
    }

    final semList = curriculumData['data']['ds_CTDT_hocky'] as List? ?? [];
    
    for (var semester in semList) {
      final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
      for (var sub in subjects) {
        final isCompleted = sub['mon_da_dat'] == 'x';
        final maMon = sub['ma_mon'] as String? ?? '';
        
        // Nếu môn đã đạt và chưa claim reward
        if (isCompleted && maMon.isNotEmpty) {
          if (!_gameService.stats.value.isSubjectClaimed(maMon)) {
            hasUnclaimedCurriculumReward.value = true;
            return;
          }
        }
      }
    }
    hasUnclaimedCurriculumReward.value = false;
  }
}
