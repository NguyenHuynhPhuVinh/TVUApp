import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../gamification/core/rank_helper.dart';

/// Card hiển thị rank hiện tại với badge và tên
class DuoRankCard extends StatelessWidget {
  final RankTier tier;
  final int level;
  final int rankIndex;
  final String rankAsset;

  const DuoRankCard({
    super.key,
    required this.tier,
    required this.level,
    required this.rankIndex,
    required this.rankAsset,
  });

  @override
  Widget build(BuildContext context) {
    final color = RankHelper.getTierColor(tier);
    final darkColor = RankHelper.getTierDarkColor(tier);
    final rankName = RankHelper.getRankName(tier, level);

    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, darkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppStyles.roundedXl,
        boxShadow: [
          BoxShadow(color: darkColor, offset: const Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.withAlpha(Colors.white, 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                rankAsset,
                width: 56.w,
                height: 56.w,
                fit: BoxFit.contain,
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          SizedBox(width: AppStyles.space4),
          // Rank info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rankName,
                  style: TextStyle(
                    fontSize: AppStyles.textXl,
                    fontWeight: AppStyles.fontBold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                SizedBox(height: AppStyles.space1),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppStyles.space3,
                    vertical: AppStyles.space1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.withAlpha(Colors.white, 0.2),
                    borderRadius: AppStyles.roundedFull,
                  ),
                  child: Text(
                    'Hạng ${rankIndex + 1} / ${RankHelper.totalRanks}',
                    style: TextStyle(
                      fontSize: AppStyles.textXs,
                      color: Colors.white,
                      fontWeight: AppStyles.fontMedium,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



