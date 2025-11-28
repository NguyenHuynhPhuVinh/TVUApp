/// Model cho điểm một môn học
class SubjectGrade {
  final String maMon;
  final String tenMon;
  final int soTinChi;
  final double? diemQuaTrinh;
  final double? diemThi;
  final double? diemTongKet;
  final String? diemChu;
  final double? diemHe4;

  const SubjectGrade({
    required this.maMon,
    required this.tenMon,
    required this.soTinChi,
    this.diemQuaTrinh,
    this.diemThi,
    this.diemTongKet,
    this.diemChu,
    this.diemHe4,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    return SubjectGrade(
      maMon: json['ma_mon']?.toString() ?? '',
      tenMon: json['ten_mon']?.toString() ?? 'N/A',
      soTinChi: _parseInt(json['so_tin_chi']),
      diemQuaTrinh: _parseDouble(json['diem_qua_trinh']),
      diemThi: _parseDouble(json['diem_thi']),
      diemTongKet: _parseDouble(json['diem_tong_ket']),
      diemChu: json['diem_chu']?.toString(),
      diemHe4: _parseDouble(json['diem_he_4']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Kiểm tra môn đã đạt chưa
  bool get isPassed => (diemTongKet ?? 0) >= 4.0;
}


/// Model cho điểm một học kỳ
class SemesterGrade {
  final int hocKy;
  final String tenHocKy;
  final double? dtbHocKyHe10;
  final double? dtbHocKyHe4;
  final double? dtbTichLuyHe10;
  final double? dtbTichLuyHe4;
  final int soTinChiDat;
  final int soTinChiTichLuy;
  final List<SubjectGrade> subjects;

  const SemesterGrade({
    required this.hocKy,
    required this.tenHocKy,
    this.dtbHocKyHe10,
    this.dtbHocKyHe4,
    this.dtbTichLuyHe10,
    this.dtbTichLuyHe4,
    required this.soTinChiDat,
    required this.soTinChiTichLuy,
    required this.subjects,
  });

  factory SemesterGrade.fromJson(Map<String, dynamic> json) {
    final subjectList = json['ds_diem_mon_hoc'] as List? ?? [];
    return SemesterGrade(
      hocKy: json['hoc_ky'] as int? ?? 0,
      tenHocKy: json['ten_hoc_ky']?.toString() ?? '',
      dtbHocKyHe10: _parseDouble(json['dtb_hoc_ky_he_10']),
      dtbHocKyHe4: _parseDouble(json['dtb_hoc_ky_he_4']),
      dtbTichLuyHe10: _parseDouble(json['dtb_tich_luy_he_10']),
      dtbTichLuyHe4: _parseDouble(json['dtb_tich_luy_he_4']),
      soTinChiDat: json['so_tin_chi_dat'] as int? ?? 0,
      soTinChiTichLuy: json['so_tin_chi_tich_luy'] as int? ?? 0,
      subjects: subjectList.map((e) => SubjectGrade.fromJson(e)).toList(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Xếp loại học lực dựa trên GPA
  String get academicRank {
    final gpa = dtbTichLuyHe10 ?? 0;
    if (gpa >= 9.0) return 'Xuất sắc';
    if (gpa >= 8.0) return 'Giỏi';
    if (gpa >= 7.0) return 'Khá';
    if (gpa >= 5.0) return 'Trung bình';
    return 'Yếu';
  }
}
