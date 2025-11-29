import 'package:get/get.dart';

import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/check_in_manager.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../features/gamification/shared/models/player_stats.dart';
import '../../../../features/gamification/core/rank_helper.dart';
import '../../../../features/user/models/student_model.dart';
import '../../../../infrastructure/storage/storage_service.dart';
import '../../../academic/models/curriculum_model.dart';
import '../../../academic/models/grade_model.dart';
import '../../../academic/models/schedule_model.dart';
import '../../../academic/models/tuition_semester.dart';

class HomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();
  final GameService _gameService = Get.find<GameService>();
  late final CheckInManager _checkInManager;

  final studentInfo = Rxn<StudentInfo>();
  final todaySchedule = <ScheduleLesson>[].obs;

  // Badge indicators
  final hasPendingCheckIn = false.obs;
  final hasUnclaimedTuitionBonus = false.obs;
  final hasUnclaimedCurriculumReward = false.obs;
  final hasUnclaimedRankReward = false.obs;

  // Getters for student info
  String get studentName => studentInfo.value?.tenDayDu ?? '';
  String get studentId => studentInfo.value?.mssv ?? _authService.username.value;
  String get className => studentInfo.value?.lop ?? '';

  // Game stats
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

    ever(_gameService.stats, (_) {
      checkPendingCheckIn();
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
    final studentInfoData = _storage.getStudentInfo();
    if (studentInfoData != null && studentInfoData['data'] != null) {
      studentInfo.value = StudentInfo.fromJson(studentInfoData['data']);
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
      final currentWeek = _checkInManager.findCurrentWeek(weeks);
      if (currentWeek == null) {
        todaySchedule.value = [];
        return;
      }

      final now = DateTime.now();
      final todayWeekday = now.weekday + 1;

      final week = ScheduleWeek.fromJson(currentWeek);
      todaySchedule.value = week.getLessonsByDay(todayWeekday);
    }
  }


  void checkPendingCheckIn() {
    final semestersData = _storage.getSemesters();
    final currentSemester =
        semestersData?['data']?['hoc_ky_theo_ngay_hien_tai'] as int? ?? 0;

    final scheduleData = _storage.getSchedule(currentSemester);
    if (scheduleData == null) {
      hasPendingCheckIn.value = false;
      return;
    }

    final weeks = scheduleData['ds_tuan_tkb'] as List? ?? [];
    final currentWeek = _checkInManager.findCurrentWeek(weeks);
    final weekNumber = _checkInManager.getWeekNumber(currentWeek);

    // Convert ScheduleLesson to Map for CheckInManager
    final todayScheduleMap =
        todaySchedule.map((l) => l.toJson()).toList();

    hasPendingCheckIn.value = _checkInManager.hasPendingCheckIn(
      todaySchedule: todayScheduleMap,
      currentSemester: currentSemester,
      currentWeek: weekNumber,
    );
  }

  void checkUnclaimedTuitionBonus() {
    final tuitionData = _storage.getTuition();
    if (tuitionData == null || tuitionData['data'] == null) {
      hasUnclaimedTuitionBonus.value = false;
      return;
    }

    final tuitionList =
        tuitionData['data']['ds_hoc_phi_hoc_ky'] as List? ?? [];
    final semesters = tuitionList
        .map((e) => TuitionSemester.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    for (var semester in semesters) {
      if (semester.paidAmount > 0 && semester.tenHocKy.isNotEmpty) {
        if (!_gameService.stats.value.isSemesterClaimed(semester.tenHocKy)) {
          hasUnclaimedTuitionBonus.value = true;
          return;
        }
      }
    }
    hasUnclaimedTuitionBonus.value = false;
  }

  void checkUnclaimedCurriculumReward() {
    final curriculumData = _storage.getCurriculum();
    if (curriculumData == null || curriculumData['data'] == null) {
      hasUnclaimedCurriculumReward.value = false;
      return;
    }

    final semList = curriculumData['data']['ds_CTDT_hocky'] as List? ?? [];
    final semesters = semList.map((e) => CurriculumSemester.fromJson(e)).toList();

    for (var semester in semesters) {
      for (var subject in semester.subjects) {
        if (subject.isCompleted && subject.maMon.isNotEmpty) {
          if (!_gameService.stats.value.isSubjectClaimed(subject.maMon)) {
            hasUnclaimedCurriculumReward.value = true;
            return;
          }
        }
      }
    }
    hasUnclaimedCurriculumReward.value = false;
  }

  void checkUnclaimedRankReward() {
    final gradesData = _storage.getGrades();
    if (gradesData == null || gradesData['data'] == null) {
      hasUnclaimedRankReward.value = false;
      return;
    }

    final semesterList = gradesData['data']['ds_diem_hocky'] as List? ?? [];
    if (semesterList.isEmpty) {
      hasUnclaimedRankReward.value = false;
      return;
    }

    final latestSemester = SemesterGrade.fromJson(semesterList.first);
    final gpa = latestSemester.dtbTichLuyHe10Double ?? 0;
    final rankIndex = RankHelper.getRankIndexFromGpa(gpa);

    hasUnclaimedRankReward.value =
        _gameService.countUnclaimedRanks(rankIndex) > 0;
  }
}
