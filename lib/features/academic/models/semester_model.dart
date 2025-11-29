/// Model cho học kỳ (dùng chung cho schedule, grades, etc.)
class Semester {
  final int hocKy;
  final String tenHocKy;

  const Semester({
    required this.hocKy,
    required this.tenHocKy,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      hocKy: _parseInt(json['hoc_ky']),
      tenHocKy: json['ten_hoc_ky']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'hoc_ky': hocKy,
        'ten_hoc_ky': tenHocKy,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Tên học kỳ rút gọn (VD: "HK1 2023-2024")
  String get shortName {
    return tenHocKy
        .replaceAll('Học kỳ ', 'HK')
        .replaceAll(' - Năm học ', ' ');
  }
}
