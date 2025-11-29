import 'package:get/get.dart';

import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/check_in_manager.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../infrastructure/storage/storage_service.dart';
import '../../models/schedule_model.dart';
import '../../models/semester_model.dart';

class ScheduleController extends GetxController {
  late final StorageService _storage;
  late final GameService _gameService;
  late final AuthService _authService;
  late final CheckInManager _checkInManager;

  final selectedWeekIndex = 0.obs;
  final weeks = <ScheduleWeek>[].obs;
  final currentWeekLessons = <ScheduleLesson>[].obs;
  final semesters = <Semester>[].obs;
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
    _initSync();
  }

  Future<void> _initSync() async {
    await syncCheckInsFromFirebase();
    await syncMissedLessonsFromFirebase();
    // Tự động detect và đánh dấu tiết bỏ lỡ
    await autoDetectMissedLessons();
  }

  void loadSemesters() {
    final semestersData = _storage.getSemesters();
    if (semestersData != null && semestersData['data'] != null) {
      final data = semestersData['data'];
      final semesterList = data['ds_hoc_ky'] as List? ?? [];
      semesters.value =
          semesterList.map((e) => Semester.fromJson(e)).toList();
      currentSemester.value = data['hoc_ky_theo_ngay_hien_tai'] ?? 0;

      if (semesters.isNotEmpty) {
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
      weeks.value = weekList.map((e) => ScheduleWeek.fromJson(e)).toList();

      if (weeks.isNotEmpty) {
        final currentWeekMap =
            _checkInManager.findCurrentWeek(weekList);
        int currentWeekIdx = 0;
        if (currentWeekMap != null) {
          currentWeekIdx = weeks.indexWhere(
            (w) => w.tuanHocKy == currentWeekMap['tuan_hoc_ky'],
          );
          if (currentWeekIdx < 0) currentWeekIdx = 0;
        }
        selectWeek(currentWeekIdx);
      }
    }
  }

  void selectWeek(int index) {
    if (index >= 0 && index < weeks.length) {
      selectedWeekIndex.value = index;
      currentWeekLessons.value = weeks[index].lessons;
      _loadCheckInStates();
    }
  }

  /// Lấy danh sách buổi học theo ngày (sử dụng Model)
  List<ScheduleLesson> getScheduleByDay(int day) {
    return currentWeekLessons.where((l) => l.thuKieuSo == day).toList()
      ..sort((a, b) => a.tietBatDau.compareTo(b.tietBatDau));
  }

  void changeSemester(int? newSemester) {
    if (newSemester != null) {
      selectedSemester.value = newSemester;
      loadSchedule();
    }
  }

  String getSemesterName(int hocKy) {
    final found = semesters.firstWhereOrNull((s) => s.hocKy == hocKy);
    return found?.tenHocKy ?? 'Học kỳ $hocKy';
  }

  // ============ LESSON CHECK-IN ============

  int get _currentSemester => selectedSemester.value ?? 0;
  int get _currentWeek {
    if (weeks.isEmpty || selectedWeekIndex.value >= weeks.length) return 0;
    return weeks[selectedWeekIndex.value].tuanHocKy;
  }

  ScheduleWeek? get _currentWeekData {
    if (weeks.isEmpty || selectedWeekIndex.value >= weeks.length) return null;
    return weeks[selectedWeekIndex.value];
  }

  /// Tạo key duy nhất cho buổi học
  String _createCheckInKey(ScheduleLesson lesson) {
    return '${_currentSemester}_${_currentWeek}_${lesson.thuKieuSo}_${lesson.tietBatDau}_${lesson.maMon}';
  }

  /// Lấy ngày của buổi học trong tuần hiện tại
  DateTime? _getLessonDate(ScheduleLesson lesson) {
    final week = _currentWeekData;
    if (week == null) return null;
    return _checkInManager.getLessonDate(week.ngayBatDau, lesson.thuKieuSo);
  }

  /// Lấy trạng thái check-in của buổi học (sử dụng Model)
  CheckInResult _getCheckInStatus(ScheduleLesson lesson) {
    final lessonDate = _getLessonDate(lesson);
    if (lessonDate == null) {
      return CheckInResult(
        status: CheckInStatus.expired,
        checkInKey: _createCheckInKey(lesson),
      );
    }
    return _checkInManager.checkLessonStatusFromModel(
      lesson: lesson,
      lessonDate: lessonDate,
      semester: _currentSemester,
      week: _currentWeek,
    );
  }

  bool canCheckInLesson(ScheduleLesson lesson) {
    return _getCheckInStatus(lesson).canCheckIn;
  }

  Duration? getTimeUntilCheckIn(ScheduleLesson lesson) {
    return _getCheckInStatus(lesson).timeUntilCheckIn;
  }

  bool isLessonBeforeGameInit(ScheduleLesson lesson) {
    return _getCheckInStatus(lesson).isBeforeGameInit;
  }

  bool isLessonExpired(ScheduleLesson lesson) {
    return _getCheckInStatus(lesson).isExpired;
  }

  bool hasCheckedInLesson(ScheduleLesson lesson) {
    final key = _createCheckInKey(lesson);
    return checkInStates[key] ?? _storage.hasCheckedIn(key);
  }

  bool isCheckingIn(ScheduleLesson lesson) {
    final key = _createCheckInKey(lesson);
    return checkingInKeys.contains(key);
  }


  /// Check-in buổi học và nhận thưởng
  /// TUÂN THỦ 3 BƯỚC: 1. Check Firebase → 2. Lưu Local → 3. Sync Firebase
  /// Firebase là SOURCE OF TRUTH - Local chỉ là cache
  Future<Map<String, dynamic>?> checkInLesson(ScheduleLesson lesson) async {
    final key = _createCheckInKey(lesson);
    final mssv = _authService.username.value;

    // BƯỚC 0: LOCK - Ngăn race condition
    if (checkingInKeys.contains(key)) return null;
    checkingInKeys.add(key);

    try {
      // BƯỚC 1: CHECK FIREBASE (Source of Truth)
      final alreadyCheckedInOnFirebase =
          await _gameService.hasCheckedInOnFirebase(mssv, key);
      if (alreadyCheckedInOnFirebase) {
        checkInStates[key] = true;
        return null;
      }

      if (_storage.hasCheckedIn(key)) return null;
      if (!canCheckInLesson(lesson)) return null;

      // SECURITY: VALIDATE SERVER TIME
      final isTimeValid = await _gameService.validateLocalTime(mssv);
      if (!isTimeValid) return null;

      // Gọi game service để nhận thưởng
      final rewards = await _gameService.checkInLesson(
        mssv: mssv,
        soTiet: lesson.soTiet,
      );

      if (rewards == null) return null;

      final checkInData = {
        'checkedAt': DateTime.now().toIso8601String(),
        'soTiet': lesson.soTiet,
        'tenMon': lesson.tenMon,
        'maMon': lesson.maMon,
        'rewards': rewards,
      };

      // BƯỚC 2: LƯU LOCAL (Cache)
      await _storage.saveLessonCheckIn(key, checkInData);

      // BƯỚC 3: SYNC FIREBASE (Source of Truth)
      await _gameService.saveCheckInToFirebase(
        mssv: mssv,
        checkInKey: key,
        checkInData: checkInData,
      );

      checkInStates[key] = true;
      return rewards;
    } finally {
      checkingInKeys.remove(key);
    }
  }

  void _loadCheckInStates() {
    try {
      checkInStates.clear();
      missedStates.clear();
      for (var lesson in currentWeekLessons) {
        final key = _createCheckInKey(lesson);
        checkInStates[key] = _storage.hasCheckedIn(key);
        missedStates[key] = _storage.hasMissedLesson(key);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> syncCheckInsFromFirebase() async {
    final mssv = _authService.username.value;
    if (mssv.isEmpty) return;

    try {
      final firebaseCheckIns =
          await _gameService.getCheckInsFromFirebase(mssv);

      for (var entry in firebaseCheckIns.entries) {
        final key = entry.key;
        final data = entry.value as Map<String, dynamic>;
        if (!_storage.hasCheckedIn(key)) {
          await _storage.saveLessonCheckIn(key, data);
        }
      }
      _loadCheckInStates();
    } catch (e) {
      // Ignore errors
    }
  }

  // ============ MISSED LESSONS ============

  final missedStates = <String, bool>{}.obs;
  final markingMissedKeys = <String>{}.obs;

  /// Kiểm tra buổi học đã được đánh dấu bỏ lỡ chưa
  bool hasMarkedAsMissed(ScheduleLesson lesson) {
    final key = _createCheckInKey(lesson);
    return missedStates[key] ?? _storage.hasMissedLesson(key);
  }

  /// Kiểm tra đang đánh dấu bỏ lỡ
  bool isMarkingMissed(ScheduleLesson lesson) {
    final key = _createCheckInKey(lesson);
    return markingMissedKeys.contains(key);
  }

  /// Đánh dấu buổi học là bỏ lỡ và cập nhật thống kê
  /// TUÂN THỦ 3 BƯỚC: 1. Check Firebase → 2. Lưu Local → 3. Sync Firebase
  Future<Map<String, dynamic>?> markLessonAsMissed(ScheduleLesson lesson) async {
    final key = _createCheckInKey(lesson);
    final mssv = _authService.username.value;

    // BƯỚC 0: LOCK - Ngăn race condition
    if (markingMissedKeys.contains(key)) return null;
    markingMissedKeys.add(key);

    try {
      // BƯỚC 1: CHECK FIREBASE (Source of Truth)
      // Kiểm tra đã check-in hoặc đã đánh dấu bỏ lỡ chưa
      final alreadyCheckedIn =
          await _gameService.hasCheckedInOnFirebase(mssv, key);
      if (alreadyCheckedIn) {
        checkInStates[key] = true;
        return null;
      }

      final alreadyMissed =
          await _gameService.hasMissedLessonOnFirebase(mssv, key);
      if (alreadyMissed) {
        missedStates[key] = true;
        return null;
      }

      // Kiểm tra local
      if (_storage.hasCheckedIn(key)) return null;
      if (_storage.hasMissedLesson(key)) return null;

      // Gọi game service để cập nhật thống kê
      final result = await _gameService.recordMissedLesson(
        mssv: mssv,
        soTiet: lesson.soTiet,
      );

      if (result == null) return null;

      final missedData = {
        'missedAt': DateTime.now().toIso8601String(),
        'soTiet': lesson.soTiet,
        'tenMon': lesson.tenMon,
        'maMon': lesson.maMon,
        'tietBatDau': lesson.tietBatDau,
        'thuKieuSo': lesson.thuKieuSo,
      };

      // BƯỚC 2: LƯU LOCAL (Cache)
      await _storage.saveMissedLesson(key, missedData);

      // BƯỚC 3: SYNC FIREBASE (Source of Truth)
      await _gameService.saveMissedLessonToFirebase(
        mssv: mssv,
        missedKey: key,
        missedData: missedData,
      );

      missedStates[key] = true;
      return result;
    } finally {
      markingMissedKeys.remove(key);
    }
  }

  /// Sync missed lessons từ Firebase
  Future<void> syncMissedLessonsFromFirebase() async {
    final mssv = _authService.username.value;
    if (mssv.isEmpty) return;

    try {
      final firebaseMissed =
          await _gameService.getMissedLessonsFromFirebase(mssv);

      for (var entry in firebaseMissed.entries) {
        final key = entry.key;
        final data = entry.value as Map<String, dynamic>;
        if (!_storage.hasMissedLesson(key)) {
          await _storage.saveMissedLesson(key, data);
        }
      }
      _loadMissedStates();
    } catch (e) {
      // Ignore errors
    }
  }

  void _loadMissedStates() {
    try {
      missedStates.clear();
      for (var lesson in currentWeekLessons) {
        final key = _createCheckInKey(lesson);
        missedStates[key] = _storage.hasMissedLesson(key);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Tự động detect và đánh dấu các tiết đã hết hạn mà chưa check-in
  /// Chạy khi app khởi động hoặc khi load schedule
  Future<void> autoDetectMissedLessons() async {
    if (!_gameService.isInitialized) return;

    final mssv = _authService.username.value;
    if (mssv.isEmpty) return;

    // Duyệt qua tất cả các tuần đã qua trong học kỳ hiện tại
    final scheduleData = _storage.getSchedule(currentSemester.value);
    if (scheduleData == null) return;

    final weekList = scheduleData['ds_tuan_tkb'] as List? ?? [];
    final allWeeks = weekList.map((e) => ScheduleWeek.fromJson(e)).toList();

    for (var week in allWeeks) {
      await _detectMissedLessonsInWeek(
        week: week,
        semester: currentSemester.value,
        mssv: mssv,
      );
    }

    _loadCheckInStates();
  }

  /// Detect tiết bỏ lỡ trong một tuần cụ thể
  Future<void> _detectMissedLessonsInWeek({
    required ScheduleWeek week,
    required int semester,
    required String mssv,
  }) async {
    for (var lesson in week.lessons) {
      final key = '${semester}_${week.tuanHocKy}_${lesson.thuKieuSo}_${lesson.tietBatDau}_${lesson.maMon}';

      // Bỏ qua nếu đã check-in hoặc đã đánh dấu bỏ lỡ
      if (_storage.hasCheckedIn(key)) continue;
      if (_storage.hasMissedLesson(key)) continue;

      // Lấy ngày của buổi học
      final lessonDate = _checkInManager.getLessonDate(week.ngayBatDau, lesson.thuKieuSo);
      if (lessonDate == null) continue;

      // Kiểm tra trạng thái
      final result = _checkInManager.checkLessonStatusFromModel(
        lesson: lesson,
        lessonDate: lessonDate,
        semester: semester,
        week: week.tuanHocKy,
      );

      // Nếu đã hết hạn và chưa check-in → tự động đánh dấu bỏ lỡ
      if (result.isExpired) {
        await _autoMarkAsMissed(
          key: key,
          lesson: lesson,
          mssv: mssv,
        );
      }
    }
  }

  /// Tự động đánh dấu tiết bỏ lỡ (không cần user action)
  Future<void> _autoMarkAsMissed({
    required String key,
    required ScheduleLesson lesson,
    required String mssv,
  }) async {
    // Double check Firebase
    final alreadyCheckedIn = await _gameService.hasCheckedInOnFirebase(mssv, key);
    if (alreadyCheckedIn) {
      await _storage.saveLessonCheckIn(key, {'syncedFromFirebase': true});
      return;
    }

    final alreadyMissed = await _gameService.hasMissedLessonOnFirebase(mssv, key);
    if (alreadyMissed) {
      await _storage.saveMissedLesson(key, {'syncedFromFirebase': true});
      return;
    }

    // Ghi nhận tiết bỏ lỡ
    await _gameService.recordMissedLesson(
      mssv: mssv,
      soTiet: lesson.soTiet,
    );

    final missedData = {
      'missedAt': DateTime.now().toIso8601String(),
      'autoDetected': true,
      'soTiet': lesson.soTiet,
      'tenMon': lesson.tenMon,
      'maMon': lesson.maMon,
      'tietBatDau': lesson.tietBatDau,
      'thuKieuSo': lesson.thuKieuSo,
    };

    // Lưu local
    await _storage.saveMissedLesson(key, missedData);

    // Sync Firebase
    await _gameService.saveMissedLessonToFirebase(
      mssv: mssv,
      missedKey: key,
      missedData: missedData,
    );

    missedStates[key] = true;
  }
}
