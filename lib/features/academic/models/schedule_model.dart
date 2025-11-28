/// Model cho một buổi học trong thời khóa biểu
class ScheduleLesson {
  final String maMon;
  final String tenMon;
  final int tietBatDau;
  final int soTiet;
  final String maPhong;
  final String tenPhong;
  final String tenGiangVien;
  final int thuKieuSo; // 2 = Thứ 2, 3 = Thứ 3, ..., 8 = CN

  const ScheduleLesson({
    required this.maMon,
    required this.tenMon,
    required this.tietBatDau,
    required this.soTiet,
    required this.maPhong,
    required this.tenPhong,
    required this.tenGiangVien,
    required this.thuKieuSo,
  });

  factory ScheduleLesson.fromJson(Map<String, dynamic> json) {
    return ScheduleLesson(
      maMon: json['ma_mon']?.toString() ?? '',
      tenMon: json['ten_mon']?.toString() ?? 'N/A',
      tietBatDau: _parseInt(json['tiet_bat_dau']),
      soTiet: _parseInt(json['so_tiet']),
      maPhong: json['ma_phong']?.toString() ?? '',
      tenPhong: json['ten_phong']?.toString() ?? '',
      tenGiangVien: json['ten_giang_vien']?.toString() ?? '',
      thuKieuSo: _parseInt(json['thu_kieu_so']),
    );
  }

  Map<String, dynamic> toJson() => {
        'ma_mon': maMon,
        'ten_mon': tenMon,
        'tiet_bat_dau': tietBatDau,
        'so_tiet': soTiet,
        'ma_phong': maPhong,
        'ten_phong': tenPhong,
        'ten_giang_vien': tenGiangVien,
        'thu_kieu_so': thuKieuSo,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Thời gian bắt đầu dạng text (VD: "7:00")
  String get startTimeText {
    final hour = _getStartHour();
    final minute = _getStartMinute();
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Thời gian kết thúc dạng text
  String get endTimeText {
    final startMinutes = _getStartHour() * 60 + _getStartMinute();
    final endMinutes = startMinutes + (soTiet * 45);
    final hour = endMinutes ~/ 60;
    final minute = endMinutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  int _getStartHour() {
    if (tietBatDau <= 6) {
      return 7 + ((tietBatDau - 1) * 45) ~/ 60;
    } else if (tietBatDau <= 12) {
      return 13 + ((tietBatDau - 7) * 45) ~/ 60;
    } else {
      return 18 + ((tietBatDau - 13) * 45) ~/ 60;
    }
  }

  int _getStartMinute() {
    if (tietBatDau <= 6) {
      return ((tietBatDau - 1) * 45) % 60;
    } else if (tietBatDau <= 12) {
      return ((tietBatDau - 7) * 45) % 60;
    } else {
      return ((tietBatDau - 13) * 45) % 60;
    }
  }
}


/// Model cho một tuần học
class ScheduleWeek {
  final int tuanHocKy;
  final String ngayBatDau;
  final String ngayKetThuc;
  final List<ScheduleLesson> lessons;

  const ScheduleWeek({
    required this.tuanHocKy,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.lessons,
  });

  factory ScheduleWeek.fromJson(Map<String, dynamic> json) {
    final lessonList = json['ds_thoi_khoa_bieu'] as List? ?? [];
    return ScheduleWeek(
      tuanHocKy: json['tuan_hoc_ky'] as int? ?? 0,
      ngayBatDau: json['ngay_bat_dau']?.toString() ?? '',
      ngayKetThuc: json['ngay_ket_thuc']?.toString() ?? '',
      lessons: lessonList.map((e) => ScheduleLesson.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tuan_hoc_ky': tuanHocKy,
        'ngay_bat_dau': ngayBatDau,
        'ngay_ket_thuc': ngayKetThuc,
        'ds_thoi_khoa_bieu': lessons.map((e) => e.toJson()).toList(),
      };

  /// Lấy danh sách buổi học theo ngày trong tuần
  List<ScheduleLesson> getLessonsByDay(int dayOfWeek) {
    return lessons.where((l) => l.thuKieuSo == dayOfWeek).toList()
      ..sort((a, b) => a.tietBatDau.compareTo(b.tietBatDau));
  }
}
