import 'package:get/get.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/auth_service.dart';

class ScheduleController extends GetxController {
  late final LocalStorageService _localStorage;
  late final GameService _gameService;
  late final AuthService _authService;

  final selectedWeekIndex = 0.obs;
  final weeks = <Map<String, dynamic>>[].obs;
  final currentWeekSchedule = <Map<String, dynamic>>[].obs;
  final semesters = <Map<String, dynamic>>[].obs;
  final selectedSemester = Rxn<int>();
  final currentSemester = 0.obs;
  final checkInStates = <String, bool>{}.obs;
  final checkingInKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _localStorage = Get.find<LocalStorageService>();
    _gameService = Get.find<GameService>();
    _authService = Get.find<AuthService>();
    loadSemesters();
    // Sync check-ins từ Firebase
    syncCheckInsFromFirebase();
  }

  void loadSemesters() {
    final semestersData = _localStorage.getSemesters();
    if (semestersData != null && semestersData['data'] != null) {
      final data = semestersData['data'];
      final semesterList = data['ds_hoc_ky'] as List? ?? [];
      semesters.value = semesterList.map((e) => Map<String, dynamic>.from(e)).toList();
      currentSemester.value = data['hoc_ky_theo_ngay_hien_tai'] ?? 0;

      if (semesters.isNotEmpty) {
        // Set default to current semester
        selectedSemester.value = currentSemester.value;
        loadSchedule();
      }
    }
  }

  void loadSchedule() {
    if (selectedSemester.value == null) return;

    final scheduleData = _localStorage.getSchedule(selectedSemester.value!);
    if (scheduleData != null) {
      final weekList = scheduleData['ds_tuan_tkb'] as List? ?? [];
      weeks.value = weekList.map((e) => Map<String, dynamic>.from(e)).toList();

      if (weeks.isNotEmpty) {
        // Find current week
        final now = DateTime.now();
        int currentWeekIdx = 0;
        for (int i = 0; i < weeks.length; i++) {
          final startStr = weeks[i]['ngay_bat_dau'] as String?;
          final endStr = weeks[i]['ngay_ket_thuc'] as String?;
          if (DateFormatter.isDateInRange(now, startStr, endStr)) {
            currentWeekIdx = i;
            break;
          }
        }
        selectWeek(currentWeekIdx);
      }
    }
  }

  void selectWeek(int index) {
    if (index >= 0 && index < weeks.length) {
      selectedWeekIndex.value = index;
      final schedules = weeks[index]['ds_thoi_khoa_bieu'] as List? ?? [];
      currentWeekSchedule.value = schedules.map((e) => Map<String, dynamic>.from(e)).toList();
      _loadCheckInStates();
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

  // ============ LESSON CHECK-IN ============

  /// Tạo key duy nhất cho buổi học
  String _createCheckInKey(Map<String, dynamic> lesson) {
    final semester = selectedSemester.value ?? 0;
    int week = 0;
    if (weeks.isNotEmpty && selectedWeekIndex.value < weeks.length) {
      week = weeks[selectedWeekIndex.value]['tuan_hoc_ky'] ?? 0;
    }
    final day = lesson['thu_kieu_so'] ?? 0;
    final tietBatDau = lesson['tiet_bat_dau'] ?? 0;
    final maMon = lesson['ma_mon'] ?? '';
    return '${semester}_${week}_${day}_${tietBatDau}_$maMon';
  }

  /// Lấy ngày của buổi học trong tuần hiện tại
  DateTime? _getLessonDate(Map<String, dynamic> lesson) {
    if (weeks.isEmpty || selectedWeekIndex.value >= weeks.length) return null;
    
    final week = weeks[selectedWeekIndex.value];
    final startDateStr = week['ngay_bat_dau'] as String?;
    final startDate = DateFormatter.parseVietnamese(startDateStr);
    if (startDate == null) return null;
    
    // thu_kieu_so: 2 = Thứ 2, 3 = Thứ 3, ..., 8 = CN
    final dayOfWeek = lesson['thu_kieu_so'] as int? ?? 2;
    // Thứ 2 = 0 offset, Thứ 3 = 1 offset, ...
    final dayOffset = dayOfWeek - 2;
    
    return startDate.add(Duration(days: dayOffset));
  }

  /// Kiểm tra có thể check-in buổi học không
  bool canCheckInLesson(Map<String, dynamic> lesson) {
    final lessonDate = _getLessonDate(lesson);
    if (lessonDate == null) return false;
    
    final tietBatDau = lesson['tiet_bat_dau'] as int? ?? 1;
    final soTiet = lesson['so_tiet'] as int? ?? 1;
    
    return _gameService.canCheckIn(lessonDate, tietBatDau, soTiet);
  }

  /// Lấy thời gian còn lại đến khi có thể check-in
  Duration? getTimeUntilCheckIn(Map<String, dynamic> lesson) {
    final lessonDate = _getLessonDate(lesson);
    if (lessonDate == null) return null;
    
    final tietBatDau = lesson['tiet_bat_dau'] as int? ?? 1;
    final soTiet = lesson['so_tiet'] as int? ?? 1;
    
    return _gameService.getTimeUntilCheckIn(lessonDate, tietBatDau, soTiet);
  }

  /// Kiểm tra đã check-in buổi học chưa
  bool hasCheckedInLesson(Map<String, dynamic> lesson) {
    final key = _createCheckInKey(lesson);
    return checkInStates[key] ?? _localStorage.hasCheckedIn(key);
  }

  /// Kiểm tra đang check-in buổi học không
  bool isCheckingIn(Map<String, dynamic> lesson) {
    final key = _createCheckInKey(lesson);
    return checkingInKeys.contains(key);
  }

  /// Check-in buổi học và nhận thưởng
  /// TUÂN THỦ 3 BƯỚC: 1. Check Firebase → 2. Lưu Local → 3. Sync Firebase
  /// Firebase là SOURCE OF TRUTH - Local chỉ là cache
  /// Returns: Map rewards nếu thành công, null nếu thất bại
  Future<Map<String, dynamic>?> checkInLesson(Map<String, dynamic> lesson) async {
    final key = _createCheckInKey(lesson);
    final mssv = _authService.username.value;
    
    // Đánh dấu đang loading
    checkingInKeys.add(key);
    
    try {
      // ========== BƯỚC 1: CHECK FIREBASE (Source of Truth) ==========
      // Kiểm tra trên Firebase trước - ngăn chặn hack bằng xóa local data
      final alreadyCheckedInOnFirebase = await _gameService.hasCheckedInOnFirebase(mssv, key);
      if (alreadyCheckedInOnFirebase) {
        // Đã check-in trên Firebase -> cập nhật local cache và return
        checkInStates[key] = true;
        return null;
      }
      
      // Kiểm tra local cache (để UX nhanh hơn nếu đã sync)
      if (_localStorage.hasCheckedIn(key)) {
        return null;
      }
      
      // Kiểm tra có thể check-in không (thời gian)
      if (!canCheckInLesson(lesson)) {
        return null;
      }
      
      final soTiet = lesson['so_tiet'] as int? ?? 1;
      
      // Gọi game service để nhận thưởng (bao gồm security check)
      final rewards = await _gameService.checkInLesson(
        mssv: mssv,
        soTiet: soTiet,
      );
      
      // Nếu security check fail, rewards sẽ null
      if (rewards == null) {
        return null;
      }
      
      final checkInData = {
        'checkedAt': DateTime.now().toIso8601String(),
        'soTiet': soTiet,
        'tenMon': lesson['ten_mon'],
        'maMon': lesson['ma_mon'],
        'rewards': rewards,
      };
      
      // ========== BƯỚC 2: LƯU LOCAL (Cache) ==========
      await _localStorage.saveLessonCheckIn(key, checkInData);
      
      // ========== BƯỚC 3: SYNC FIREBASE (Source of Truth) ==========
      await _gameService.saveCheckInToFirebase(
        mssv: mssv,
        checkInKey: key,
        checkInData: checkInData,
      );
      
      // Cập nhật state UI
      checkInStates[key] = true;
      
      return rewards;
    } finally {
      // Bỏ loading
      checkingInKeys.remove(key);
    }
  }

  /// Load trạng thái check-in cho tuần hiện tại
  void _loadCheckInStates() {
    try {
      checkInStates.clear();
      for (var lesson in currentWeekSchedule) {
        final key = _createCheckInKey(lesson);
        checkInStates[key] = _localStorage.hasCheckedIn(key);
      }
    } catch (e) {
      // Ignore errors during loading check-in states
    }
  }

  /// Sync check-ins từ Firebase về local
  Future<void> syncCheckInsFromFirebase() async {
    final mssv = _authService.username.value;
    if (mssv.isEmpty) return;

    try {
      final firebaseCheckIns = await _gameService.getCheckInsFromFirebase(mssv);
      
      for (var entry in firebaseCheckIns.entries) {
        final key = entry.key;
        final data = entry.value as Map<String, dynamic>;
        
        // Nếu local chưa có, lưu vào local
        if (!_localStorage.hasCheckedIn(key)) {
          await _localStorage.saveLessonCheckIn(key, data);
        }
      }
      
      // Reload check-in states
      _loadCheckInStates();
    } catch (e) {
      // Ignore errors during sync
    }
  }
}
