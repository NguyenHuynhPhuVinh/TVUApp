import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';

class DuoLevelBadge extends StatelessWidget {
  final int level;
  final String? title;
  final String? iconPath;
  final Color? backgroundColor;
  final Color? shadowColor;

  const DuoLevelBadge({
    super.key,
    required this.level,
    this.title,
    this.iconPath,
    this.backgroundColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.purple;
    final shadow = shadowColor ?? AppColors.purpleDark;

    return Container(
      padding: EdgeInsets.all(AppStyles.space5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.rounded2xl,
        boxShadow: AppColors.buttonBoxShadow(shadow),
      ),
      child: Column(
        children: [
          Text(
            title ?? 'Cấp độ đạt được',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: AppStyles.space2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconPath != null)
                Image.asset(
                  iconPath!,
                  width: 32.w,
                  height: 32.w,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.star_rounded,
                    size: 32.w,
                    color: AppColors.yellow,
                  ),
                )
              else
                Icon(
                  Icons.star_rounded,
                  size: 32.w,
                  color: AppColors.yellow,
                ),
              SizedBox(width: AppStyles.space2),
              Text(
                'Level $level',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: AppStyles.fontBold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




