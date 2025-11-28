import 'game_service.dart';
import '../../../infrastructure/storage/storage_service.dart';
import '../../../core/utils/date_formatter.dart';

/// Trạng thái check-in của buổi học
enum CheckInStatus {
  canCheckIn,      // Có thể điểm danh ngay
  tooEarly,        // Chưa đến giờ điểm danh
  expired,         // Đã hết hạn điểm danh
  alreadyCheckedIn,// Đã điểm danh rồi
  beforeGameInit,  // Buổi học trước khi khởi tạo game
}

/// Kết quả kiểm tra check-in
class CheckInResult {
  final CheckInStatus status;
  final Duration? timeUntilCheckIn; // Thời gian còn lại đến khi có thể check-in
  final String checkInKey;

  const CheckInResult({
    required this.status,
    this.timeUntilCheckIn,
    required this.checkInKey,
  });

  bool get canCheckIn => status == CheckInStatus.canCheckIn;
  bool get isExpired => status == CheckInStatus.expired;
  bool get isTooEarly => status == CheckInStatus.tooEarly;
  bool get isAlreadyCheckedIn => status == CheckInStatus.alreadyCheckedIn;
  bool get isBeforeGameInit => status == CheckInStatus.beforeGameInit;
}

/// Manager tập trung logic check-in
/// Thay thế logic phân tán trong HomeController và ScheduleController
class CheckInManager {
  final GameService _gameService;
  final StorageService _storage;

  CheckInManager({
    required GameService gameService,
    required StorageService storage,
  })  : _gameService = gameService,
        _storage = storage;

  /// Kiểm tra trạng thái check-in của buổi học
  /// [lesson] - Map chứa thông tin buổi học từ API
  /// [lessonDate] - Ngày của buổi học
  /// [semester] - Học kỳ
  /// [week] - Tuần học kỳ
  CheckInResult checkLessonStatus({
    required Map<String, dynamic> lesson,
    required DateTime lessonDate,
    required int semester,
    required int week,
  }) {
    final tietBatDau = lesson['tiet_bat_dau'] as int? ?? 1;
    final soTiet = lesson['so_tiet'] as int? ?? 1;
    final maMon = lesson['ma_mon'] ?? '';
    final day = lesson['thu_kieu_so'] ?? 0;

    // Tạo check-in key
    final checkInKey = '${semester}_${week}_${day}_${tietBatDau}_$maMon';

    // 1. Kiểm tra đã check-in chưa
    if (_storage.hasCheckedIn(checkInKey)) {
      return CheckInResult(
        status: CheckInStatus.alreadyCheckedIn,
        checkInKey: checkInKey,
      );
    }

    // 2. Kiểm tra buổi học có trước thời điểm init game không
    final endTime = GameService.calculateLessonEndTime(lessonDate, tietBatDau, soTiet);
    final initializedAt = _gameService.stats.value.initializedAt;
    if (initializedAt != null && endTime.isBefore(initializedAt)) {
      return CheckInResult(
        status: CheckInStatus.beforeGameInit,
        checkInKey: checkInKey,
      );
    }

    // 3. Kiểm tra thời gian
    final now = DateTime.now();
    final checkInStart = GameService.calculateCheckInStartTime(lessonDate, tietBatDau);
    final checkInDeadline = GameService.calculateCheckInDeadline(lessonDate);

    // Đã hết hạn
    if (now.isAfter(checkInDeadline)) {
      return CheckInResult(
        status: CheckInStatus.expired,
        checkInKey: checkInKey,
      );
    }

    // Chưa đến giờ
    if (now.isBefore(checkInStart)) {
      return CheckInResult(
        status: CheckInStatus.tooEarly,
        timeUntilCheckIn: checkInStart.difference(now),
        checkInKey: checkInKey,
      );
    }

    // Có thể check-in
    return CheckInResult(
      status: CheckInStatus.canCheckIn,
      checkInKey: checkInKey,
    );
  }

  /// Kiểm tra có buổi học nào có thể điểm danh hôm nay không
  /// Dùng cho badge indicator trên HomeController
  bool hasPendingCheckIn({
    required List<Map<String, dynamic>> todaySchedule,
    required int currentSemester,
    required int currentWeek,
  }) {
    final now = DateTime.now();

    for (var lesson in todaySchedule) {
      final result = checkLessonStatus(
        lesson: lesson,
        lessonDate: now,
        semester: currentSemester,
        week: currentWeek,
      );

      if (result.canCheckIn) {
        return true;
      }
    }
    return false;
  }

  /// Tạo check-in key từ lesson data
  /// Dùng khi cần key mà không cần full check
  String createCheckInKey({
    required Map<String, dynamic> lesson,
    required int semester,
    required int week,
  }) {
    final day = lesson['thu_kieu_so'] ?? 0;
    final tietBatDau = lesson['tiet_bat_dau'] ?? 0;
    final maMon = lesson['ma_mon'] ?? '';
    return '${semester}_${week}_${day}_${tietBatDau}_$maMon';
  }

  /// Lấy ngày của buổi học trong tuần
  /// [weekStartDate] - Ngày bắt đầu tuần (từ API)
  /// [dayOfWeek] - thu_kieu_so: 2 = Thứ 2, 3 = Thứ 3, ..., 8 = CN
  DateTime? getLessonDate(String? weekStartDateStr, int dayOfWeek) {
    final startDate = DateFormatter.parseVietnamese(weekStartDateStr);
    if (startDate == null) return null;

    // thu_kieu_so: 2 = Thứ 2 (offset 0), 3 = Thứ 3 (offset 1), ...
    final dayOffset = dayOfWeek - 2;
    return startDate.add(Duration(days: dayOffset));
  }

  /// Tìm tuần hiện tại trong danh sách tuần
  /// Returns: Map chứa thông tin tuần hoặc null
  Map<String, dynamic>? findCurrentWeek(List<dynamic> weeks) {
    final now = DateTime.now();
    for (var week in weeks) {
      final startStr = week['ngay_bat_dau'] as String?;
      final endStr = week['ngay_ket_thuc'] as String?;
      if (DateFormatter.isDateInRange(now, startStr, endStr)) {
        return Map<String, dynamic>.from(week);
      }
    }
    return null;
  }

  /// Lấy số tuần học kỳ từ week data
  int getWeekNumber(Map<String, dynamic>? week) {
    return week?['tuan_hoc_ky'] as int? ?? 0;
  }
}



