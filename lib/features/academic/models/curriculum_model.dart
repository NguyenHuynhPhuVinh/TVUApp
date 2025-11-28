/// Model cho môn học trong CTDT
class CurriculumSubject {
  final String maMon;
  final String tenMon;
  final int soTinChi;
  final bool isCompleted; // mon_da_dat == 'x'
  final String? diemChu;
  final String? nhomMon;

  const CurriculumSubject({
    required this.maMon,
    required this.tenMon,
    required this.soTinChi,
    required this.isCompleted,
    this.diemChu,
    this.nhomMon,
  });

  factory CurriculumSubject.fromJson(Map<String, dynamic> json) {
    return CurriculumSubject(
      maMon: json['ma_mon']?.toString() ?? '',
      tenMon: json['ten_mon']?.toString() ?? 'N/A',
      soTinChi: _parseInt(json['so_tin_chi']),
      isCompleted: json['mon_da_dat'] == 'x',
      diemChu: json['diem_chu']?.toString(),
      nhomMon: json['nhom_mon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ma_mon': maMon,
        'ten_mon': tenMon,
        'so_tin_chi': soTinChi,
        'mon_da_dat': isCompleted ? 'x' : '',
        'diem_chu': diemChu,
        'nhom_mon': nhomMon,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// Model cho học kỳ trong CTDT
class CurriculumSemester {
  final int hocKy;
  final String tenHocKy;
  final List<CurriculumSubject> subjects;

  const CurriculumSemester({
    required this.hocKy,
    required this.tenHocKy,
    required this.subjects,
  });

  factory CurriculumSemester.fromJson(Map<String, dynamic> json) {
    final subjectList = json['ds_CTDT_mon_hoc'] as List? ?? [];
    return CurriculumSemester(
      hocKy: _parseInt(json['hoc_ky']),
      tenHocKy: json['ten_hoc_ky']?.toString() ?? '',
      subjects: subjectList.map((e) => CurriculumSubject.fromJson(e)).toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Tổng tín chỉ trong học kỳ
  int get totalCredits =>
      subjects.fold(0, (sum, sub) => sum + sub.soTinChi);

  /// Tín chỉ đã hoàn thành
  int get completedCredits => subjects
      .where((s) => s.isCompleted)
      .fold(0, (sum, sub) => sum + sub.soTinChi);

  /// Số môn đã hoàn thành
  int get completedSubjects =>
      subjects.where((s) => s.isCompleted).length;
}
