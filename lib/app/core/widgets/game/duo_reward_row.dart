import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';

/// Kích thước của DuoRewardRow
enum DuoRewardRowSize { sm, md, lg }

class DuoRewardRow extends StatelessWidget {
  final String? iconPath;
  final IconData fallbackIcon;
  final String label;
  final int value;
  final Color color;
  final Color bgColor;
  final String prefix;

  const DuoRewardRow({
    super.key,
    this.iconPath,
    required this.fallbackIcon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    this.prefix = '+',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppStyles.roundedLg,
            ),
            child: Center(
              child: iconPath != null
                  ? Image.asset(
                      iconPath!,
                      width: 32.w,
                      height: 32.w,
                      errorBuilder: (_, _, _) => Icon(
                        fallbackIcon,
                        size: 32.w,
                        color: color,
                      ),
                    )
                  : Icon(
                      fallbackIcon,
                      size: 32.w,
                      color: color,
                    ),
            ),
          ),
          SizedBox(width: AppStyles.space3),
          // Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppStyles.textBase,
                fontWeight: AppStyles.fontMedium,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Value
          Text(
            '$prefix${NumberFormatter.compact(value)}',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: AppStyles.fontBold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

