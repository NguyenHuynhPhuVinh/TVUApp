import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Loại feedback card
enum DuoFeedbackType {
  info,
  success,
  warning,
  error,
  excellent, // Vàng - cho thành tích xuất sắc
}

/// Unified Feedback Card - thay thế DuoMessageCard và DuoFeedbackMessage
/// Hiển thị thông báo với icon và màu sắc theo type
class DuoFeedbackCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final DuoFeedbackType type;
  final bool hasBorder;
  final bool hasIconBackground;

  const DuoFeedbackCard({
    super.key,
    required this.message,
    required this.icon,
    required this.type,
    this.hasBorder = true,
    this.hasIconBackground = true,
  });

  // ============ FACTORY CONSTRUCTORS ============

  /// Info message (màu primary/blue)
  factory DuoFeedbackCard.info({required String message}) {
    return DuoFeedbackCard(
      message: message,
      icon: Icons.info_rounded,
      type: DuoFeedbackType.info,
    );
  }

  /// Success message (màu xanh lá)
  factory DuoFeedbackCard.success({required String message}) {
    return DuoFeedbackCard(
      message: message,
      icon: Icons.check_circle_rounded,
      type: DuoFeedbackType.success,
    );
  }

  /// Warning message (màu cam)
  factory DuoFeedbackCard.warning({required String message}) {
    return DuoFeedbackCard(
      message: message,
      icon: Icons.warning_rounded,
      type: DuoFeedbackType.warning,
    );
  }

  /// Error message (màu đỏ)
  factory DuoFeedbackCard.error({required String message}) {
    return DuoFeedbackCard(
      message: message,
      icon: Icons.error_rounded,
      type: DuoFeedbackType.error,
    );
  }

  /// Excellent message (màu vàng - cho thành tích)
  factory DuoFeedbackCard.excellent({required String message}) {
    return DuoFeedbackCard(
      message: message,
      icon: Icons.emoji_events_rounded,
      type: DuoFeedbackType.excellent,
    );
  }

  /// Factory từ attendance rate - thay thế cả 2 widget cũ
  factory DuoFeedbackCard.fromAttendanceRate(double rate) {
    if (rate >= 90) {
      return DuoFeedbackCard(
        message: 'Xuất sắc! Bạn là sinh viên gương mẫu!',
        icon: Icons.emoji_events_rounded,
        type: DuoFeedbackType.excellent,
      );
    } else if (rate >= 80) {
      return DuoFeedbackCard(
        message: 'Tốt lắm! Tiếp tục phát huy nhé!',
        icon: Icons.thumb_up_rounded,
        type: DuoFeedbackType.success,
      );
    } else if (rate >= 70) {
      return DuoFeedbackCard(
        message: 'Khá tốt! Cố gắng thêm một chút nữa!',
        icon: Icons.trending_up_rounded,
        type: DuoFeedbackType.info,
      );
    } else if (rate >= 50) {
      return DuoFeedbackCard(
        message: 'Cần cố gắng hơn để đạt kết quả tốt!',
        icon: Icons.warning_rounded,
        type: DuoFeedbackType.warning,
      );
    } else {
      return DuoFeedbackCard(
        message: 'Hãy cải thiện chuyên cần để học tốt hơn!',
        icon: Icons.priority_high_rounded,
        type: DuoFeedbackType.error,
      );
    }
  }

  // ============ COLOR HELPERS ============

  Color get _color {
    switch (type) {
      case DuoFeedbackType.info:
        return AppColors.primary;
      case DuoFeedbackType.success:
        return AppColors.green;
      case DuoFeedbackType.warning:
        return AppColors.orange;
      case DuoFeedbackType.error:
        return AppColors.red;
      case DuoFeedbackType.excellent:
        return AppColors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: AppStyles.roundedXl,
        border: hasBorder
            ? Border.all(color: _color.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: AppStyles.space3),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppStyles.textBase,
                fontWeight: AppStyles.fontMedium,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (hasIconBackground) {
      return Container(
        padding: EdgeInsets.all(AppStyles.space2),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _color, size: 24.w),
      );
    }
    return Icon(icon, color: _color, size: 28.w);
  }
}
