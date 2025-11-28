import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';

/// Card hiển thị tiến độ lên rank tiếp theo
class DuoRankProgress extends StatelessWidget {
  final String currentRankName;
  final String nextRankName;
  final String gpaForNextRank;
  final double progress;
  final Color rankColor;
  final bool isMaxRank;

  const DuoRankProgress({
    super.key,
    required this.currentRankName,
    required this.nextRankName,
    required this.gpaForNextRank,
    required this.progress,
    required this.rankColor,
    this.isMaxRank = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMaxRank ? 'Đã đạt hạng cao nhất!' : 'Tiến độ lên hạng',
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  fontWeight: AppStyles.fontSemibold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!isMaxRank)
                Text(
                  'Cần GPA $gpaForNextRank',
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppStyles.space3),
          // Progress bar
          ClipRRect(
            borderRadius: AppStyles.roundedFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12.h,
              backgroundColor: AppColors.backgroundDark,
              valueColor: AlwaysStoppedAnimation(rankColor),
            ),
          ),
          SizedBox(height: AppStyles.space2),
          if (!isMaxRank)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentRankName,
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  nextRankName,
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}



