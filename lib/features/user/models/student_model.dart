/// Model cho thông tin sinh viên
class StudentInfo {
  final String mssv;
  final String tenDayDu;
  final String lop;
  final String khoa;
  final String nganh;
  final String email;
  final String soDienThoai;
  final String ngaySinh;
  final String gioiTinh;
  final String? avatar;

  const StudentInfo({
    required this.mssv,
    required this.tenDayDu,
    required this.lop,
    this.khoa = '',
    this.nganh = '',
    this.email = '',
    this.soDienThoai = '',
    this.ngaySinh = '',
    this.gioiTinh = '',
    this.avatar,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      mssv: json['ma_sv']?.toString() ?? json['mssv']?.toString() ?? '',
      tenDayDu: json['ten_day_du']?.toString() ?? '',
      lop: json['lop']?.toString() ?? '',
      khoa: json['khoa']?.toString() ?? '',
      nganh: json['nganh']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      soDienThoai: json['so_dien_thoai']?.toString() ?? '',
      ngaySinh: json['ngay_sinh']?.toString() ?? '',
      gioiTinh: json['gioi_tinh']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ma_sv': mssv,
        'ten_day_du': tenDayDu,
        'lop': lop,
        'khoa': khoa,
        'nganh': nganh,
        'email': email,
        'so_dien_thoai': soDienThoai,
        'ngay_sinh': ngaySinh,
        'gioi_tinh': gioiTinh,
        'avatar': avatar,
      };

  /// Lấy tên viết tắt (2 chữ cái đầu)
  String get initials {
    final parts = tenDayDu.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return tenDayDu.isNotEmpty ? tenDayDu[0].toUpperCase() : '?';
  }

  /// Lấy họ tên ngắn gọn (Họ + Tên)
  String get shortName {
    final parts = tenDayDu.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first} ${parts.last}';
    }
    return tenDayDu;
  }
}
