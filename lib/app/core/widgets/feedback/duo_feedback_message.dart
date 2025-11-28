import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

enum DuoFeedbackType { excellent, good, fair, warning, danger }

class DuoFeedbackMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final DuoFeedbackType type;

  const DuoFeedbackMessage({
    super.key,
    required this.message,
    required this.icon,
    required this.type,
  });

  /// Factory từ attendance rate
  factory DuoFeedbackMessage.fromAttendanceRate(double rate) {
    if (rate >= 90) {
      return const DuoFeedbackMessage(
        message: 'Xuất sắc! Bạn là sinh viên gương mẫu!',
        icon: Icons.emoji_events_rounded,
        type: DuoFeedbackType.excellent,
      );
    } else if (rate >= 80) {
      return const DuoFeedbackMessage(
        message: 'Tốt lắm! Tiếp tục phát huy nhé!',
        icon: Icons.thumb_up_rounded,
        type: DuoFeedbackType.good,
      );
    } else if (rate >= 70) {
      return const DuoFeedbackMessage(
        message: 'Khá tốt! Cố gắng thêm một chút nữa!',
        icon: Icons.trending_up_rounded,
        type: DuoFeedbackType.fair,
      );
    } else if (rate >= 50) {
      return const DuoFeedbackMessage(
        message: 'Cần cố gắng hơn để đạt kết quả tốt!',
        icon: Icons.warning_rounded,
        type: DuoFeedbackType.warning,
      );
    } else {
      return const DuoFeedbackMessage(
        message: 'Hãy cải thiện chuyên cần để học tốt hơn!',
        icon: Icons.priority_high_rounded,
        type: DuoFeedbackType.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28.w),
          SizedBox(width: AppStyles.space3),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppStyles.textBase,
                fontWeight: AppStyles.fontMedium,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case DuoFeedbackType.excellent:
        return AppColors.yellow;
      case DuoFeedbackType.good:
        return AppColors.green;
      case DuoFeedbackType.fair:
        return AppColors.primary;
      case DuoFeedbackType.warning:
        return AppColors.orange;
      case DuoFeedbackType.danger:
        return AppColors.red;
    }
  }
}

