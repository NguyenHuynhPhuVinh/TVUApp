import 'package:get/get.dart';
import '../../../core/game_rules/check_in_manager.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/auth_service.dart';
import '../../home/controllers/home_controller.dart';

class ScheduleController extends GetxController {
  late final StorageService _storage;
  late final GameService _gameService;
  late final AuthService _authService;
  late final CheckInManager _checkInManager;

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
    _storage = Get.find<StorageService>();
    _gameService = Get.find<GameService>();
    _authService = Get.find<AuthService>();
    _checkInManager = CheckInManager(
      gameService: _gameService,
      storage: _storage,
    );
    loadSemesters();
    // Sync check-ins từ Firebase
    syncCheckInsFromFirebase();
  }

  void loadSemesters() {
    final semestersData = _storage.getSemesters();
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

    final scheduleData = _storage.getSchedule(selectedSemester.value!);
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

  /// Lấy semester và week hiện tại
  int get _currentSemester => selectedSemester.value ?? 0;
  int get _currentWeek {
    if (weeks.isEmpty || selectedWeekIndex.value >= weeks.length) return 0;
    return weeks[selectedWeekIndex.value]['tuan_hoc_ky'] ?? 0;
  }

  /// Tạo key duy nhất cho buổi học (delegate to CheckInManager)
  String _createCheckInKey(Map<String, dynamic> lesson) {
    return _checkInManager.createCheckInKey(
      lesson: lesson,
      semester: _currentSemester,
      week: _currentWeek,
    );
  }

  /// Lấy ngày của buổi học trong tuần hiện tại
  DateTime? _getLessonDate(Map<String, dynamic> lesson) {
    if (weeks.isEmpty || selectedWeekIndex.value >= weeks.length) return null;
    final week = weeks[selectedWeekIndex.value];
    final startDateStr = week['ngay_bat_dau'] as String?;
    final dayOfWeek = lesson['thu_kieu_so'] as int? ?? 2;
    return _checkInManager.getLessonDate(startDateStr, dayOfWeek);
  }

  /// Lấy trạng thái check-in của buổi học (sử dụng CheckInManager)
  CheckInResult _getCheckInStatus(Map<String, dynamic> lesson) {
    final lessonDate = _getLessonDate(lesson);
    if (lessonDate == null) {
      return CheckInResult(
        status: CheckInStatus.expired,
        checkInKey: _createCheckInKey(lesson),
      );
    }
    return _checkInManager.checkLessonStatus(
      lesson: lesson,
      lessonDate: lessonDate,
      semester: _currentSemester,
      week: _currentWeek,
    );
  }

  /// Kiểm tra có thể check-in buổi học không
  bool canCheckInLesson(Map<String, dynamic> lesson) {
    return _getCheckInStatus(lesson).canCheckIn;
  }

  /// Lấy thời gian còn lại đến khi có thể check-in
  Duration? getTimeUntilCheckIn(Map<String, dynamic> lesson) {
    return _getCheckInStatus(lesson).timeUntilCheckIn;
  }

  /// Kiểm tra buổi học có trước thời điểm khởi tạo game không
  bool isLessonBeforeGameInit(Map<String, dynamic> lesson) {
    return _getCheckInStatus(lesson).isBeforeGameInit;
  }

  /// Kiểm tra buổi học đã hết hạn điểm danh chưa
  bool isLessonExpired(Map<String, dynamic> lesson) {
    return _getCheckInStatus(lesson).isExpired;
  }

  /// Kiểm tra đã check-in buổi học chưa
  bool hasCheckedInLesson(Map<String, dynamic> lesson) {
    final key = _createCheckInKey(lesson);
    return checkInStates[key] ?? _storage.hasCheckedIn(key);
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
  /// 
  /// SECURITY: Có lock để ngăn race condition (double click)
  Future<Map<String, dynamic>?> checkInLesson(Map<String, dynamic> lesson) async {
    final key = _createCheckInKey(lesson);
    final mssv = _authService.username.value;
    
    // ========== BƯỚC 0: LOCK - Ngăn race condition ==========
    // Nếu đang check-in key này rồi, return null ngay
    if (checkingInKeys.contains(key)) {
      return null;
    }
    
    // Đánh dấu đang loading (lock)
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
      if (_storage.hasCheckedIn(key)) {
        return null;
      }
      
      // Kiểm tra có thể check-in không (thời gian local)
      if (!canCheckInLesson(lesson)) {
        return null;
      }

      // ========== SECURITY: VALIDATE SERVER TIME ==========
      // Ngăn chặn hack bằng cách chỉnh đồng hồ thiết bị
      final isTimeValid = await _gameService.validateLocalTime(mssv);
      if (!isTimeValid) {
        // Thời gian thiết bị bị chỉnh sai -> block check-in
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
      await _storage.saveLessonCheckIn(key, checkInData);
      
      // ========== BƯỚC 3: SYNC FIREBASE (Source of Truth) ==========
      await _gameService.saveCheckInToFirebase(
        mssv: mssv,
        checkInKey: key,
        checkInData: checkInData,
      );
      
      // Cập nhật state UI
      checkInStates[key] = true;
      
      // Notify HomeController để cập nhật badge
      _notifyHomeController();
      
      return rewards;
    } finally {
      // Bỏ loading
      checkingInKeys.remove(key);
    }
  }
  
  /// Notify HomeController để cập nhật badge điểm danh
  void _notifyHomeController() {
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().checkPendingCheckIn();
      }
    } catch (e) {
      // Ignore if HomeController not found
    }
  }

  /// Load trạng thái check-in cho tuần hiện tại
  void _loadCheckInStates() {
    try {
      checkInStates.clear();
      for (var lesson in currentWeekSchedule) {
        final key = _createCheckInKey(lesson);
        checkInStates[key] = _storage.hasCheckedIn(key);
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
        if (!_storage.hasCheckedIn(key)) {
          await _storage.saveLessonCheckIn(key, data);
        }
      }
      
      // Reload check-in states
      _loadCheckInStates();
    } catch (e) {
      // Ignore errors during sync
    }
  }
}
