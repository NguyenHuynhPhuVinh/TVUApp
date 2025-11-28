import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'duo_progress.dart';

/// Widget hiển thị card level với XP progress bar
class DuoLevelProgressCard extends StatelessWidget {
  final int level;
  final int currentXp;
  final int xpForNextLevel;
  final Color? backgroundColor;
  final Color? shadowColor;

  const DuoLevelProgressCard({
    super.key,
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
  })  : backgroundColor = null,
        shadowColor = null;

  const DuoLevelProgressCard.custom({
    super.key,
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
    this.backgroundColor,
    this.shadowColor,
  });

  double get progress => currentXp / xpForNextLevel;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.purple;
    final shadow = shadowColor ?? AppColors.purpleDark;

    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.roundedXl,
        boxShadow: AppColors.buttonBoxShadow(shadow),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star_rounded, color: AppColors.yellow, size: 24.w),
                  SizedBox(width: AppStyles.space2),
                  Text(
                    'Level $level',
                    style: TextStyle(
                      fontSize: AppStyles.textLg,
                      fontWeight: AppStyles.fontBold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '$currentXp/$xpForNextLevel XP',
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space2),
          DuoProgressBar(
            progress: progress,
            height: 10.h,
            progressColor: AppColors.yellow,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            showShimmer: false,
          ),
        ],
      ),
    );
  }
}
