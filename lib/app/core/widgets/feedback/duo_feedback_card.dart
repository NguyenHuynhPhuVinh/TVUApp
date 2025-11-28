import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/feedback_helper.dart';

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

  /// Factory từ attendance rate - sử dụng FeedbackHelper
  factory DuoFeedbackCard.fromAttendanceRate(double rate) {
    final feedback = FeedbackHelper.fromAttendanceRate(rate);
    return DuoFeedbackCard(
      message: feedback.message,
      icon: feedback.icon,
      type: _mapFeedbackLevel(feedback.level),
    );
  }

  /// Factory từ GPA - sử dụng FeedbackHelper
  factory DuoFeedbackCard.fromGpa(double gpa) {
    final feedback = FeedbackHelper.fromGpa(gpa);
    return DuoFeedbackCard(
      message: feedback.message,
      icon: feedback.icon,
      type: _mapFeedbackLevel(feedback.level),
    );
  }

  /// Map FeedbackLevel sang DuoFeedbackType
  static DuoFeedbackType _mapFeedbackLevel(FeedbackLevel level) {
    switch (level) {
      case FeedbackLevel.excellent:
        return DuoFeedbackType.excellent;
      case FeedbackLevel.good:
        return DuoFeedbackType.success;
      case FeedbackLevel.fair:
        return DuoFeedbackType.info;
      case FeedbackLevel.needsImprovement:
        return DuoFeedbackType.warning;
      case FeedbackLevel.poor:
        return DuoFeedbackType.error;
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
