/// Model cho thông báo
class NotificationItem {
  final int id;
  final String tieuDe;
  final String noiDung;
  final String ngayGui;
  final String doiTuongSearch;
  final bool isDaDoc;
  final bool isPhaiXem;

  const NotificationItem({
    required this.id,
    required this.tieuDe,
    required this.noiDung,
    required this.ngayGui,
    required this.doiTuongSearch,
    required this.isDaDoc,
    required this.isPhaiXem,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: _parseInt(json['id']),
      tieuDe: json['tieu_de']?.toString() ?? '',
      noiDung: json['noi_dung']?.toString() ?? '',
      ngayGui: json['ngay_gui']?.toString() ?? '',
      doiTuongSearch: json['doi_tuong_search']?.toString() ?? '',
      isDaDoc: json['is_da_doc'] == true,
      isPhaiXem: json['is_phai_xem'] == true,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Kiểm tra thông báo đã đọc chưa
  bool get isRead => isDaDoc;

  /// Kiểm tra thông báo quan trọng
  bool get isPriority => isPhaiXem;
}
