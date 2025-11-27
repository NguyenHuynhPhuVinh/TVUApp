import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Message Card - hiển thị thông báo với icon và màu
class DuoMessageCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final bool hasBorder;

  const DuoMessageCard({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    this.hasBorder = true,
  });

  /// Factory cho message thành công
  factory DuoMessageCard.success({required String message}) {
    return DuoMessageCard(
      message: message,
      icon: Icons.check_circle_rounded,
      color: AppColors.green,
    );
  }

  /// Factory cho message cảnh báo
  factory DuoMessageCard.warning({required String message}) {
    return DuoMessageCard(
      message: message,
      icon: Icons.warning_rounded,
      color: AppColors.orange,
    );
  }

  /// Factory cho message lỗi
  factory DuoMessageCard.error({required String message}) {
    return DuoMessageCard(
      message: message,
      icon: Icons.error_rounded,
      color: AppColors.red,
    );
  }

  /// Factory cho message info
  factory DuoMessageCard.info({required String message}) {
    return DuoMessageCard(
      message: message,
      icon: Icons.info_rounded,
      color: AppColors.primary,
    );
  }

  /// Factory dựa trên attendance rate
  factory DuoMessageCard.fromAttendance(double rate) {
    if (rate >= 90) {
      return DuoMessageCard(
        message: 'Xuất sắc! Bạn là sinh viên gương mẫu!',
        icon: Icons.emoji_events_rounded,
        color: AppColors.yellow,
      );
    } else if (rate >= 80) {
      return DuoMessageCard(
        message: 'Tốt lắm! Tiếp tục phát huy nhé!',
        icon: Icons.thumb_up_rounded,
        color: AppColors.green,
      );
    } else if (rate >= 70) {
      return DuoMessageCard(
        message: 'Khá tốt! Cố gắng thêm một chút nữa!',
        icon: Icons.trending_up_rounded,
        color: AppColors.primary,
      );
    } else if (rate >= 50) {
      return DuoMessageCard(
        message: 'Cần cố gắng hơn để đạt kết quả tốt!',
        icon: Icons.warning_rounded,
        color: AppColors.orange,
      );
    } else {
      return DuoMessageCard(
        message: 'Hãy cải thiện chuyên cần để học tốt hơn!',
        icon: Icons.priority_high_rounded,
        color: AppColors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppStyles.roundedXl,
        border: hasBorder
            ? Border.all(color: color.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
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
}
