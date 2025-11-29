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
    syncCheckInsFromFirebase();
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
      for (var lesson in currentWeekLessons) {
        final key = _createCheckInKey(lesson);
        checkInStates[key] = _storage.hasCheckedIn(key);
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
}
