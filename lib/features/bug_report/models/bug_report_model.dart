import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho báo cáo lỗi
class BugReportModel {
  final String? id;
  final String mssv;
  final String title;
  final String description;
  final String category;
  final String? deviceInfo;
  final String? appVersion;
  final DateTime createdAt;
  final String status;

  BugReportModel({
    this.id,
    required this.mssv,
    required this.title,
    required this.description,
    required this.category,
    this.deviceInfo,
    this.appVersion,
    DateTime? createdAt,
    this.status = 'pending',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'mssv': mssv,
        'title': title,
        'description': description,
        'category': category,
        'deviceInfo': deviceInfo,
        'appVersion': appVersion,
        'createdAt': FieldValue.serverTimestamp(),
        'status': status,
      };

  factory BugReportModel.fromJson(Map<String, dynamic> json, String id) {
    return BugReportModel(
      id: id,
      mssv: json['mssv'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      deviceInfo: json['deviceInfo'],
      appVersion: json['appVersion'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }
}

/// Danh mục lỗi
enum BugCategory {
  ui('Giao diện', 'Lỗi hiển thị, layout, màu sắc'),
  crash('Ứng dụng crash', 'Ứng dụng bị đóng đột ngột'),
  data('Dữ liệu sai', 'Điểm, lịch học, học phí hiển thị sai'),
  performance('Chậm/Lag', 'Ứng dụng chạy chậm, giật'),
  feature('Tính năng', 'Tính năng không hoạt động'),
  other('Khác', 'Các lỗi khác');

  final String label;
  final String description;
  const BugCategory(this.label, this.description);
}
