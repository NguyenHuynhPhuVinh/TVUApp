import 'package:get/get.dart';
import '../../../core/game_rules/check_in_manager.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/rank_helper.dart';
import '../../../data/models/player_stats.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/storage_service.dart';

class HomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();
  final GameService _gameService = Get.find<GameService>();
  late final CheckInManager _checkInManager;

  final studentName = ''.obs;
  final studentId = ''.obs;
  final className = ''.obs;
  final todaySchedule = <Map<String, dynamic>>[].obs;
  
  // Badge indicators
  final hasPendingCheckIn = false.obs;
  final hasUnclaimedTuitionBonus = false.obs;
  final hasUnclaimedCurriculumReward = false.obs;
  final hasUnclaimedRankReward = false.obs;

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
    _checkInManager = CheckInManager(
      gameService: _gameService,
      storage: _storage,
    );
    loadData();
    
    // Listen game stats changes để cập nhật badge
    ever(_gameService.stats, (_) {
      checkUnclaimedTuitionBonus();
      checkUnclaimedCurriculumReward();
      checkUnclaimedRankReward();
    });
  }

  void loadData() {
    loadStudentInfo();
    loadTodaySchedule();
    checkPendingCheckIn();
    checkUnclaimedTuitionBonus();
    checkUnclaimedCurriculumReward();
    checkUnclaimedRankReward();
  }

  void loadStudentInfo() {
    // Lấy MSSV từ auth service
    studentId.value = _authService.username.value;
    
    // Lấy thông tin sinh viên từ local
    final studentInfoData = _storage.getStudentInfo();
    if (studentInfoData != null && studentInfoData['data'] != null) {
      final student = studentInfoData['data'];
      studentName.value = student['ten_day_du'] ?? '';
      className.value = student['lop'] ?? '';
    }
  }

  void loadTodaySchedule() {
    final semestersData = _storage.getSemesters();
    if (semestersData == null || semestersData['data'] == null) return;

    final currentSemester =
        semestersData['data']['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;
    if (currentSemester == 0) return;

    final scheduleData = _storage.getSchedule(currentSemester);
    if (scheduleData != null) {
      final weeks = scheduleData['ds_tuan_tkb'] as List? ?? [];

      // Sử dụng CheckInManager để tìm tuần hiện tại
      final currentWeek = _checkInManager.findCurrentWeek(weeks);
      if (currentWeek == null) {
        todaySchedule.value = [];
        return;
      }

      final now = DateTime.now();
      final todayWeekday = now.weekday + 1; // API uses 2=Mon, 3=Tue, etc.

      final schedules = currentWeek['ds_thoi_khoa_bieu'] as List? ?? [];
      final todayItems = schedules
          .where((s) => s['thu_kieu_so'] == todayWeekday)
          .map((s) => Map<String, dynamic>.from(s))
          .toList();

      todayItems.sort(
          (a, b) => (a['tiet_bat_dau'] ?? 0).compareTo(b['tiet_bat_dau'] ?? 0));
      todaySchedule.value = todayItems;
    }
  }

  /// Kiểm tra có buổi học nào có thể điểm danh hôm nay không
  /// Sử dụng CheckInManager để tập trung logic
  void checkPendingCheckIn() {
    final semestersData = _storage.getSemesters();
    final currentSemester = semestersData?['data']?['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;
    
    // Tìm tuần hiện tại
    final scheduleData = _storage.getSchedule(currentSemester);
    if (scheduleData == null) {
      hasPendingCheckIn.value = false;
      return;
    }
    
    final weeks = scheduleData['ds_tuan_tkb'] as List? ?? [];
    final currentWeek = _checkInManager.findCurrentWeek(weeks);
    final weekNumber = _checkInManager.getWeekNumber(currentWeek);
    
    hasPendingCheckIn.value = _checkInManager.hasPendingCheckIn(
      todaySchedule: todaySchedule,
      currentSemester: currentSemester,
      currentWeek: weekNumber,
    );
  }

  /// Kiểm tra có học phí nào chưa claim bonus không
  void checkUnclaimedTuitionBonus() {
    final tuitionData = _storage.getTuition();
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
    final curriculumData = _storage.getCurriculum();
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

  /// Kiểm tra có rank nào chưa nhận thưởng không
  void checkUnclaimedRankReward() {
    final gradesData = _storage.getGrades();
    if (gradesData == null || gradesData['data'] == null) {
      hasUnclaimedRankReward.value = false;
      return;
    }

    // Tính rank index từ GPA
    final semesters = gradesData['data']['ds_diem_hocky'] as List? ?? [];
    if (semesters.isEmpty) {
      hasUnclaimedRankReward.value = false;
      return;
    }

    final latestSemester = semesters.first as Map<String, dynamic>;
    final gpa10Str = latestSemester['dtb_tich_luy_he_10']?.toString() ?? '0';
    final gpa = double.tryParse(gpa10Str) ?? 0;
    final rankIndex = RankHelper.getRankIndexFromGpa(gpa);

    // Kiểm tra có rank nào chưa claim không
    hasUnclaimedRankReward.value = _gameService.countUnclaimedRanks(rankIndex) > 0;
  }
}
