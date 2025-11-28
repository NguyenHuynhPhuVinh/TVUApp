import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<LocalStorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Keys
  static const String _gradesKey = 'grades_data';
  static const String _curriculumKey = 'curriculum_data';
  static const String _tuitionKey = 'tuition_data';
  static const String _semestersKey = 'semesters_data';
  static const String _schedulesKey = 'schedules_data';
  static const String _studentInfoKey = 'student_info_data';
  static const String _notificationsKey = 'notifications_data';
  static const String _lessonCheckInsKey = 'lesson_checkins_data';

  // Lưu điểm
  Future<void> saveGrades(Map<String, dynamic> data) async {
    await _prefs.setString(_gradesKey, jsonEncode(data));
  }

  // Lấy điểm
  Map<String, dynamic>? getGrades() {
    final str = _prefs.getString(_gradesKey);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  // Lưu CTDT
  Future<void> saveCurriculum(Map<String, dynamic> data) async {
    await _prefs.setString(_curriculumKey, jsonEncode(data));
  }

  // Lấy CTDT
  Map<String, dynamic>? getCurriculum() {
    final str = _prefs.getString(_curriculumKey);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  // Lưu học phí
  Future<void> saveTuition(Map<String, dynamic> data) async {
    await _prefs.setString(_tuitionKey, jsonEncode(data));
  }

  // Lấy học phí
  Map<String, dynamic>? getTuition() {
    final str = _prefs.getString(_tuitionKey);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  // Lưu danh sách học kỳ
  Future<void> saveSemesters(Map<String, dynamic> data) async {
    await _prefs.setString(_semestersKey, jsonEncode(data));
  }

  // Lấy danh sách học kỳ
  Map<String, dynamic>? getSemesters() {
    final str = _prefs.getString(_semestersKey);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  // Lưu TKB theo học kỳ
  Future<void> saveSchedule(int semester, Map<String, dynamic> data) async {
    final allSchedules = getAllSchedules();
    allSchedules[semester.toString()] = data;
    await _prefs.setString(_schedulesKey, jsonEncode(allSchedules));
  }

  // Lấy TKB theo học kỳ
  Map<String, dynamic>? getSchedule(int semester) {
    final allSchedules = getAllSchedules();
    return allSchedules[semester.toString()] as Map<String, dynamic>?;
  }

  // Lấy tất cả TKB
  Map<String, dynamic> getAllSchedules() {
    final str = _prefs.getString(_schedulesKey);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return {};
  }

  // Lấy danh sách học kỳ đã lưu TKB
  List<int> getSavedScheduleSemesters() {
    final allSchedules = getAllSchedules();
    return allSchedules.keys.map((k) => int.tryParse(k) ?? 0).where((k) => k > 0).toList();
  }

  // Lưu thông tin sinh viên (chỉ local, không đẩy Firebase)
  Future<void> saveStudentInfo(Map<String, dynamic> data) async {
    await _prefs.setString(_studentInfoKey, jsonEncode(data));
  }

  // Lấy thông tin sinh viên
  Map<String, dynamic>? getStudentInfo() {
    final str = _prefs.getString(_studentInfoKey);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  // Lưu thông báo (chỉ local, không đẩy Firebase)
  Future<void> saveNotifications(Map<String, dynamic> data) async {
    await _prefs.setString(_notificationsKey, jsonEncode(data));
  }

  // Lấy thông báo
  Map<String, dynamic>? getNotifications() {
    final str = _prefs.getString(_notificationsKey);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  // ============ LESSON CHECK-IN ============
  
  /// Lưu check-in buổi học
  /// Key format: "semester_week_day_lessonId"
  Future<void> saveLessonCheckIn(String checkInKey, Map<String, dynamic> data) async {
    final allCheckIns = getLessonCheckIns();
    allCheckIns[checkInKey] = data;
    await _prefs.setString(_lessonCheckInsKey, jsonEncode(allCheckIns));
  }

  /// Lấy tất cả check-ins
  Map<String, dynamic> getLessonCheckIns() {
    final str = _prefs.getString(_lessonCheckInsKey);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return {};
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

  // Xóa tất cả data
  Future<void> clearAll() async {
    await _prefs.remove(_gradesKey);
    await _prefs.remove(_curriculumKey);
    await _prefs.remove(_tuitionKey);
    await _prefs.remove(_semestersKey);
    await _prefs.remove(_schedulesKey);
    await _prefs.remove(_studentInfoKey);
    await _prefs.remove(_notificationsKey);
    await _prefs.remove(_lessonCheckInsKey);
  }
}
