import '../../core/utils/number_formatter.dart';

/// Model cho học phí theo học kỳ
/// Thay thế `Map<String, dynamic>` để đảm bảo Type Safety
class TuitionSemester {
  final String tenHocKy;
  final double phaiThu;
  final double daThu;
  final double conNo;
  final String? ghiChu;

  const TuitionSemester({
    required this.tenHocKy,
    required this.phaiThu,
    required this.daThu,
    required this.conNo,
    this.ghiChu,
  });

  /// Đã đóng đủ chưa
  bool get isPaidFull => conNo <= 0;

  /// Đã đóng một phần
  bool get isPartiallyPaid => daThu > 0 && conNo > 0;

  /// Chưa đóng gì
  bool get isUnpaid => daThu <= 0;

  /// Tỷ lệ đã đóng (0.0 - 1.0)
  double get paidRatio => phaiThu > 0 ? daThu / phaiThu : 0;

  /// Số tiền đã đóng (int) - dùng cho game
  int get paidAmount => daThu.toInt();

  factory TuitionSemester.fromJson(Map<String, dynamic> json) {
    return TuitionSemester(
      tenHocKy: json['ten_hoc_ky'] ?? '',
      phaiThu: NumberFormatter.parseDouble(json['phai_thu']),
      daThu: NumberFormatter.parseDouble(json['da_thu']),
      conNo: NumberFormatter.parseDouble(json['con_no']),
      ghiChu: json['ghi_chu'],
    );
  }

  Map<String, dynamic> toJson() => {
    'ten_hoc_ky': tenHocKy,
    'phai_thu': phaiThu,
    'da_thu': daThu,
    'con_no': conNo,
    'ghi_chu': ghiChu,
  };
}
