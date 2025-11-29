import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage keys enum - tập trung quản lý keys
enum StorageKey {
  grades('grades_data'),
  curriculum('curriculum_data'),
  tuition('tuition_data'),
  semesters('semesters_data'),
  schedules('schedules_data'),
  studentInfo('student_info_data'),
  notifications('notifications_data'),
  lessonCheckIns('lesson_checkins_data'),
  missedLessons('missed_lessons_data');

  final String key;
  const StorageKey(this.key);
}

/// Generic LocalStorage Service - giảm code lặp lại
/// Sử dụng Generic và Enum key để chuẩn hóa
class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ============ GENERIC METHODS ============

  /// Lưu data dạng Map
  Future<void> saveData(StorageKey key, Map<String, dynamic> data) async {
    await _prefs.setString(key.key, jsonEncode(data));
  }

  /// Lấy data dạng Map
  Map<String, dynamic>? getData(StorageKey key) {
    final str = _prefs.getString(key.key);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  /// Xóa data theo key
  Future<void> removeData(StorageKey key) async {
    await _prefs.remove(key.key);
  }

  /// Kiểm tra có data không
  bool hasData(StorageKey key) {
    return _prefs.containsKey(key.key);
  }

  // ============ CONVENIENCE METHODS ============

  // Grades
  Future<void> saveGrades(Map<String, dynamic> data) =>
      saveData(StorageKey.grades, data);
  Map<String, dynamic>? getGrades() => getData(StorageKey.grades);

  // Curriculum
  Future<void> saveCurriculum(Map<String, dynamic> data) =>
      saveData(StorageKey.curriculum, data);
  Map<String, dynamic>? getCurriculum() => getData(StorageKey.curriculum);

  // Tuition
  Future<void> saveTuition(Map<String, dynamic> data) =>
      saveData(StorageKey.tuition, data);
  Map<String, dynamic>? getTuition() => getData(StorageKey.tuition);

  // Semesters
  Future<void> saveSemesters(Map<String, dynamic> data) =>
      saveData(StorageKey.semesters, data);
  Map<String, dynamic>? getSemesters() => getData(StorageKey.semesters);

  // Student Info
  Future<void> saveStudentInfo(Map<String, dynamic> data) =>
      saveData(StorageKey.studentInfo, data);
  Map<String, dynamic>? getStudentInfo() => getData(StorageKey.studentInfo);

  // Notifications
  Future<void> saveNotifications(Map<String, dynamic> data) =>
      saveData(StorageKey.notifications, data);
  Map<String, dynamic>? getNotifications() => getData(StorageKey.notifications);

  // ============ SCHEDULE METHODS (nested by semester) ============

  /// Lưu TKB theo học kỳ
  Future<void> saveSchedule(int semester, Map<String, dynamic> data) async {
    final allSchedules = getAllSchedules();
    allSchedules[semester.toString()] = data;
    await saveData(StorageKey.schedules, allSchedules);
  }

  /// Lấy TKB theo học kỳ
  Map<String, dynamic>? getSchedule(int semester) {
    final allSchedules = getAllSchedules();
    return allSchedules[semester.toString()] as Map<String, dynamic>?;
  }

  /// Lấy tất cả TKB
  Map<String, dynamic> getAllSchedules() {
    return getData(StorageKey.schedules) ?? {};
  }

  /// Lấy danh sách học kỳ đã lưu TKB
  List<int> getSavedScheduleSemesters() {
    final allSchedules = getAllSchedules();
    return allSchedules.keys
        .map((k) => int.tryParse(k) ?? 0)
        .where((k) => k > 0)
        .toList();
  }

  // ============ CHECK-IN METHODS (nested by key) ============

  /// Lưu check-in buổi học
  Future<void> saveLessonCheckIn(
      String checkInKey, Map<String, dynamic> data) async {
    final allCheckIns = getLessonCheckIns();
    allCheckIns[checkInKey] = data;
    await saveData(StorageKey.lessonCheckIns, allCheckIns);
  }

  /// Lấy tất cả check-ins
  Map<String, dynamic> getLessonCheckIns() {
    return getData(StorageKey.lessonCheckIns) ?? {};
  }

  /// Kiểm tra đã check-in buổi học chưa
  bool hasCheckedIn(String checkInKey) {
    final allCheckIns = getLessonCheckIns();
    return allCheckIns.containsKey(checkInKey);
  }

  /// Lấy thông tin check-in của buổi học
  Map<String, dynamic>? getCheckIn(String checkInKey) {
    final allCheckIns = getLessonCheckIns();
    return allCheckIns[checkInKey] as Map<String, dynamic>?;
  }

  /// Merge check-ins từ Firebase vào local
  Future<void> mergeCheckInsFromFirebase(
      Map<String, dynamic> firebaseCheckIns) async {
    final localCheckIns = getLessonCheckIns();
    bool hasChanges = false;

    for (var entry in firebaseCheckIns.entries) {
      if (!localCheckIns.containsKey(entry.key)) {
        localCheckIns[entry.key] = entry.value;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await saveData(StorageKey.lessonCheckIns, localCheckIns);
    }
  }

  // ============ MISSED LESSONS METHODS ============

  /// Lưu tiết bỏ lỡ
  Future<void> saveMissedLesson(
      String missedKey, Map<String, dynamic> data) async {
    final allMissed = getMissedLessons();
    allMissed[missedKey] = data;
    await saveData(StorageKey.missedLessons, allMissed);
  }

  /// Lấy tất cả tiết bỏ lỡ
  Map<String, dynamic> getMissedLessons() {
    return getData(StorageKey.missedLessons) ?? {};
  }

  /// Kiểm tra đã đánh dấu bỏ lỡ chưa
  bool hasMissedLesson(String missedKey) {
    final allMissed = getMissedLessons();
    return allMissed.containsKey(missedKey);
  }

  /// Lấy thông tin tiết bỏ lỡ
  Map<String, dynamic>? getMissedLesson(String missedKey) {
    final allMissed = getMissedLessons();
    return allMissed[missedKey] as Map<String, dynamic>?;
  }

  /// Merge missed lessons từ Firebase vào local
  Future<void> mergeMissedLessonsFromFirebase(
      Map<String, dynamic> firebaseMissed) async {
    final localMissed = getMissedLessons();
    bool hasChanges = false;

    for (var entry in firebaseMissed.entries) {
      if (!localMissed.containsKey(entry.key)) {
        localMissed[entry.key] = entry.value;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await saveData(StorageKey.missedLessons, localMissed);
    }
  }

  // ============ HELPER METHODS ============

  /// Lấy tên sinh viên
  String? getStudentName() {
    final info = getStudentInfo();
    if (info != null && info['data'] != null) {
      return info['data']['ten_day_du'] as String?;
    }
    return null;
  }

  /// Xóa tất cả data
  Future<void> clearAll() async {
    for (var key in StorageKey.values) {
      await removeData(key);
    }
  }
}
