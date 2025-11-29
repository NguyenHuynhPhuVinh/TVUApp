import 'package:flutter/material.dart';
import '../models/achievement_reward.dart';
import '../../../../../core/components/widgets.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/utils/number_formatter.dart';

/// Card hiển thị thống kê thành tựu
class DuoAchievementStatsCard extends StatelessWidget {
  final int totalUnlocked;
  final int totalAchievements;
  final double completionRate;
  final int unclaimedCount;
  final AchievementReward totalClaimableReward;

  const DuoAchievementStatsCard({
    super.key,
    required this.totalUnlocked,
    required this.totalAchievements,
    required this.completionRate,
    required this.unclaimedCount,
    required this.totalClaimableReward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: AppStyles.roundedXl,
        boxShadow: AppColors.buttonBoxShadow(AppColors.purpleDark),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Image.asset(
                AppAssets.crown,
                width: 40,
                height: 40,
              ),
              SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thành tựu của bạn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppStyles.textLg,
                        fontWeight: AppStyles.fontBold,
                      ),
                    ),
                    Text(
                      '$totalUnlocked / $totalAchievements đã mở khóa',
                      style: TextStyle(
                        color: AppColors.withAlpha(Colors.white, 0.9),
                        fontSize: AppStyles.textSm,
                      ),
                    ),
                  ],
                ),
              ),
              // Completion percentage
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
                  '${(completionRate * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: AppStyles.fontBold,
                    fontSize: AppStyles.textBase,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppStyles.space4),

          // Progress bar
          DuoProgressBar(
            progress: completionRate,
            backgroundColor: AppColors.withAlpha(Colors.white, 0.2),
            progressColor: Colors.white,
            shadowColor: AppColors.withAlpha(Colors.white, 0.5),
            height: 10,
          ),

          // Claimable rewards
          if (unclaimedCount > 0) ...[
            SizedBox(height: AppStyles.space4),
            Container(
              padding: EdgeInsets.all(AppStyles.space3),
              decoration: BoxDecoration(
                color: AppColors.withAlpha(Colors.white, 0.15),
                borderRadius: AppStyles.roundedLg,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppStyles.space2),
                    decoration: BoxDecoration(
                      color: AppColors.withAlpha(AppColors.yellow, 0.2),
                      borderRadius: AppStyles.roundedMd,
                    ),
                    child: Image.asset(
                      AppAssets.giftPurple,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$unclaimedCount thành tựu chờ nhận',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: AppStyles.fontSemibold,
                          ),
                        ),
                        SizedBox(height: AppStyles.space1),
                        Wrap(
                          spacing: AppStyles.space2,
                          children: [
                            _buildRewardPreview(
                              AppAssets.coin,
                              NumberFormatter.compact(
                                  totalClaimableReward.coins),
                            ),
                            _buildRewardPreview(
                              AppAssets.diamond,
                              NumberFormatter.compact(
                                  totalClaimableReward.diamonds),
                            ),
                            _buildRewardPreview(
                              AppAssets.xpStar,
                              NumberFormatter.compact(totalClaimableReward.xp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardPreview(String asset, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 14, height: 14),
        SizedBox(width: AppStyles.space1),
        Text(
          value,
          style: TextStyle(
            color: AppColors.withAlpha(Colors.white, 0.9),
            fontSize: AppStyles.textXs,
            fontWeight: AppStyles.fontMedium,
          ),
        ),
      ],
    );
  }
}
