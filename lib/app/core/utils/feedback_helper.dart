import 'package:flutter/material.dart';

/// Loại feedback dựa trên performance
enum FeedbackLevel {
  excellent, // >= 90%
  good, // >= 80%
  fair, // >= 70%
  needsImprovement, // >= 50%
  poor, // < 50%
}

/// Data class chứa thông tin feedback
class FeedbackData {
  final String message;
  final IconData icon;
  final FeedbackLevel level;

  const FeedbackData({
    required this.message,
    required this.icon,
    required this.level,
  });
}

/// Helper class để tạo feedback messages
/// Tách logic ra khỏi Widget để dễ test và tái sử dụng
class FeedbackHelper {
  FeedbackHelper._();

  /// Lấy feedback từ tỷ lệ chuyên cần
  static FeedbackData fromAttendanceRate(double rate) {
    if (rate >= 90) {
      return const FeedbackData(
        message: 'Xuất sắc! Bạn là sinh viên gương mẫu!',
        icon: Icons.emoji_events_rounded,
        level: FeedbackLevel.excellent,
      );
    } else if (rate >= 80) {
      return const FeedbackData(
        message: 'Tốt lắm! Tiếp tục phát huy nhé!',
        icon: Icons.thumb_up_rounded,
        level: FeedbackLevel.good,
      );
    } else if (rate >= 70) {
      return const FeedbackData(
        message: 'Khá tốt! Cố gắng thêm một chút nữa!',
        icon: Icons.trending_up_rounded,
        level: FeedbackLevel.fair,
      );
    } else if (rate >= 50) {
      return const FeedbackData(
        message: 'Cần cố gắng hơn để đạt kết quả tốt!',
        icon: Icons.warning_rounded,
        level: FeedbackLevel.needsImprovement,
      );
    } else {
      return const FeedbackData(
        message: 'Hãy cải thiện chuyên cần để học tốt hơn!',
        icon: Icons.priority_high_rounded,
        level: FeedbackLevel.poor,
      );
    }
  }

  /// Lấy feedback từ điểm GPA (hệ 10)
  static FeedbackData fromGpa(double gpa) {
    if (gpa >= 9.0) {
      return const FeedbackData(
        message: 'Xuất sắc! Thành tích học tập tuyệt vời!',
        icon: Icons.emoji_events_rounded,
        level: FeedbackLevel.excellent,
      );
    } else if (gpa >= 8.0) {
      return const FeedbackData(
        message: 'Giỏi! Kết quả học tập rất tốt!',
        icon: Icons.star_rounded,
        level: FeedbackLevel.good,
      );
    } else if (gpa >= 7.0) {
      return const FeedbackData(
        message: 'Khá! Tiếp tục cố gắng nhé!',
        icon: Icons.thumb_up_rounded,
        level: FeedbackLevel.fair,
      );
    } else if (gpa >= 5.0) {
      return const FeedbackData(
        message: 'Trung bình. Cần nỗ lực hơn!',
        icon: Icons.trending_up_rounded,
        level: FeedbackLevel.needsImprovement,
      );
    } else {
      return const FeedbackData(
        message: 'Cần cải thiện kết quả học tập!',
        icon: Icons.warning_rounded,
        level: FeedbackLevel.poor,
      );
    }
  }
}
