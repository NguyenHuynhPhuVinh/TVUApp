import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Widget hiển thị stat nhỏ gọn (icon + value + label)
class DuoMiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const DuoMiniStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.w),
        SizedBox(height: AppStyles.space1),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textSm,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppStyles.textXs,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

