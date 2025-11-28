/// Model cho điểm thành phần
class GradeComponent {
  final String kyHieu;
  final String tenThanhPhan;
  final String trongSo;
  final String diemThanhPhan;

  const GradeComponent({
    required this.kyHieu,
    required this.tenThanhPhan,
    required this.trongSo,
    required this.diemThanhPhan,
  });

  factory GradeComponent.fromJson(Map<String, dynamic> json) {
    return GradeComponent(
      kyHieu: json['ky_hieu']?.toString() ?? '',
      tenThanhPhan: json['ten_thanh_phan']?.toString() ?? '',
      trongSo: json['trong_so']?.toString() ?? '',
      diemThanhPhan: json['diem_thanh_phan']?.toString() ?? '',
    );
  }
}

/// Model cho điểm một môn học
class SubjectGrade {
  final String maMon;
  final String tenMon;
  final String tenMonEg;
  final String nhomTo;
  final int soTinChi;
  final String diemThi;
  final String diemGiuaKy;
  final String diemTk;       // Điểm tổng kết hệ 10
  final String diemTkSo;     // Điểm tổng kết hệ 4
  final String diemTkChu;    // Điểm chữ (A, B+, C...)
  final int ketQua;          // 1 = đạt, 0 = chưa đạt
  final bool hienThiKetQua;
  final int khongTinhDiemTbtl;
  final String lyDoKhongTinhDiemTbtl;
  final List<GradeComponent> dsThanhPhan;

  const SubjectGrade({
    required this.maMon,
    required this.tenMon,
    required this.tenMonEg,
    required this.nhomTo,
    required this.soTinChi,
    required this.diemThi,
    required this.diemGiuaKy,
    required this.diemTk,
    required this.diemTkSo,
    required this.diemTkChu,
    required this.ketQua,
    required this.hienThiKetQua,
    required this.khongTinhDiemTbtl,
    required this.lyDoKhongTinhDiemTbtl,
    required this.dsThanhPhan,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    final thanhPhanList = json['ds_diem_thanh_phan'] as List? ?? [];
    return SubjectGrade(
      maMon: json['ma_mon']?.toString() ?? '',
      tenMon: json['ten_mon']?.toString() ?? 'N/A',
      tenMonEg: json['ten_mon_eg']?.toString() ?? '',
      nhomTo: json['nhom_to']?.toString() ?? '',
      soTinChi: _parseInt(json['so_tin_chi']),
      diemThi: json['diem_thi']?.toString() ?? '',
      diemGiuaKy: json['diem_giua_ky']?.toString() ?? '',
      diemTk: json['diem_tk']?.toString() ?? '',
      diemTkSo: json['diem_tk_so']?.toString() ?? '',
      diemTkChu: json['diem_tk_chu']?.toString() ?? '',
      ketQua: _parseInt(json['ket_qua']),
      hienThiKetQua: json['hien_thi_ket_qua'] == true,
      khongTinhDiemTbtl: _parseInt(json['khong_tinh_diem_tbtl']),
      lyDoKhongTinhDiemTbtl: json['ly_do_khong_tinh_diem_tbtl']?.toString() ?? '',
      dsThanhPhan: thanhPhanList.map((e) => GradeComponent.fromJson(e)).toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Kiểm tra môn đã đạt chưa
  bool get isPassed => ketQua == 1;

  /// Kiểm tra môn có điểm chưa
  bool get hasGrade => diemTk.isNotEmpty;

  /// Kiểm tra môn có tính vào điểm TB không
  bool get countInGPA => khongTinhDiemTbtl == 0;

  /// Điểm tổng kết dạng số
  double? get diemTkDouble => double.tryParse(diemTk);
}

/// Model cho điểm một học kỳ
class SemesterGrade {
  final String hocKy;
  final String tenHocKy;
  final String dtbHkHe10;
  final String dtbHkHe4;
  final String dtbTichLuyHe10;
  final String dtbTichLuyHe4;
  final String soTinChiDatHk;
  final String soTinChiDatTichLuy;
  final String xepLoaiTkbHk;
  final String xepLoaiTkbHkEg;
  final List<SubjectGrade> subjects;

  const SemesterGrade({
    required this.hocKy,
    required this.tenHocKy,
    required this.dtbHkHe10,
    required this.dtbHkHe4,
    required this.dtbTichLuyHe10,
    required this.dtbTichLuyHe4,
    required this.soTinChiDatHk,
    required this.soTinChiDatTichLuy,
    required this.xepLoaiTkbHk,
    required this.xepLoaiTkbHkEg,
    required this.subjects,
  });

  factory SemesterGrade.fromJson(Map<String, dynamic> json) {
    final subjectList = json['ds_diem_mon_hoc'] as List? ?? [];
    return SemesterGrade(
      hocKy: json['hoc_ky']?.toString() ?? '',
      tenHocKy: json['ten_hoc_ky']?.toString() ?? '',
      dtbHkHe10: json['dtb_hk_he10']?.toString() ?? '',
      dtbHkHe4: json['dtb_hk_he4']?.toString() ?? '',
      dtbTichLuyHe10: json['dtb_tich_luy_he_10']?.toString() ?? '',
      dtbTichLuyHe4: json['dtb_tich_luy_he_4']?.toString() ?? '',
      soTinChiDatHk: json['so_tin_chi_dat_hk']?.toString() ?? '',
      soTinChiDatTichLuy: json['so_tin_chi_dat_tich_luy']?.toString() ?? '',
      xepLoaiTkbHk: json['xep_loai_tkb_hk']?.toString() ?? '',
      xepLoaiTkbHkEg: json['xep_loai_tkb_hk_eg']?.toString() ?? '',
      subjects: subjectList.map((e) => SubjectGrade.fromJson(e)).toList(),
    );
  }

  /// Điểm TB học kỳ hệ 10 dạng số
  double? get dtbHkHe10Double => double.tryParse(dtbHkHe10);

  /// Điểm TB tích lũy hệ 10 dạng số  
  double? get dtbTichLuyHe10Double => double.tryParse(dtbTichLuyHe10);

  /// Số tín chỉ đạt học kỳ dạng số
  int get soTinChiDatHkInt => int.tryParse(soTinChiDatHk) ?? 0;

  /// Số tín chỉ tích lũy dạng số
  int get soTinChiDatTichLuyInt => int.tryParse(soTinChiDatTichLuy) ?? 0;

  /// Xếp loại học lực
  String get academicRank {
    if (xepLoaiTkbHk.isNotEmpty) return xepLoaiTkbHk;
    final gpa = dtbTichLuyHe10Double ?? 0;
    if (gpa >= 9.0) return 'Xuất sắc';
    if (gpa >= 8.0) return 'Giỏi';
    if (gpa >= 7.0) return 'Khá';
    if (gpa >= 5.0) return 'Trung bình';
    return 'Yếu';
  }
}
