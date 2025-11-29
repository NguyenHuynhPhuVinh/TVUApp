import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../models/achievement_reward.dart';
import '../data/achievement_icons.dart';
import '../../../../../core/components/widgets.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/utils/number_formatter.dart';

/// Card hiển thị một thành tựu
class DuoAchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onClaim;
  final bool isClaiming;

  const DuoAchievementCard({
    super.key,
    required this.achievement,
    this.onClaim,
    this.isClaiming = false,
  });

  Color get _tierColor =>
      Color(AchievementTierHelper.getTierColorValue(achievement.tier));

  @override
  Widget build(BuildContext context) {
    final reward = AchievementReward.forAchievement(achievement);

    return DuoCard(
      padding: EdgeInsets.zero,
      shadowColor: achievement.canClaimReward ? _tierColor : null,
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppStyles.space3),
            child: Row(
              children: [
                // Icon
                _buildIcon(),
                SizedBox(width: AppStyles.space3),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.name,
                              style: TextStyle(
                                fontWeight: AppStyles.fontBold,
                                fontSize: AppStyles.textBase,
                                color: achievement.isUnlocked
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                          // Tier badge
                          DuoBadge.tag(
                            text: AchievementTierHelper.getTierName(
                                achievement.tier),
                            color: _tierColor,
                          ),
                        ],
                      ),
                      SizedBox(height: AppStyles.space1),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: AppStyles.textSm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar (nếu chưa hoàn thành)
          if (!achievement.isUnlocked) _buildProgressSection(),

          // Rewards preview
          _buildRewardsSection(reward),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final iconAsset = AchievementIcons.getAchievementAsset(achievement);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? AppColors.withAlpha(_tierColor, 0.15)
            : AppColors.backgroundDark,
        borderRadius: AppStyles.roundedLg,
      ),
      child: Center(
        child: Image.asset(
          iconAsset,
          width: 28,
          height: 28,
          color: achievement.isUnlocked ? null : AppColors.textTertiary,
          colorBlendMode:
              achievement.isUnlocked ? null : BlendMode.saturation,
        ),
      ),
    );
  }

  DuoButtonVariant _getButtonVariant() {
    switch (achievement.tier) {
      case AchievementTier.wood:
      case AchievementTier.stone:
      case AchievementTier.bronze:
        return DuoButtonVariant.warning;
      case AchievementTier.silver:
      case AchievementTier.gold:
        return DuoButtonVariant.success;
      case AchievementTier.platinum:
      case AchievementTier.amethyst:
      case AchievementTier.onyx:
        return DuoButtonVariant.purple;
    }
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space3),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${achievement.currentValue}/${achievement.targetValue}',
                style: TextStyle(
                  fontSize: AppStyles.textXs,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${achievement.progressPercent}%',
                style: TextStyle(
                  fontSize: AppStyles.textXs,
                  fontWeight: AppStyles.fontSemibold,
                  color: _tierColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space1),
          DuoProgressBar(
            progress: achievement.progress,
            progressColor: _tierColor,
            height: 8,
            showShimmer: false,
          ),
          SizedBox(height: AppStyles.space3),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(AchievementReward reward) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? AppColors.withAlpha(_tierColor, 0.05)
            : AppColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppStyles.radiusXl - 1),
          bottomRight: Radius.circular(AppStyles.radiusXl - 1),
        ),
      ),
      child: Row(
        children: [
          // Rewards
          Expanded(
            child: Wrap(
              spacing: AppStyles.space3,
              children: [
                _buildRewardChip(
                    AppAssets.coin, NumberFormatter.compact(reward.coins)),
                _buildRewardChip(
                    AppAssets.diamond, NumberFormatter.compact(reward.diamonds)),
                _buildRewardChip(
                    AppAssets.xpStar, NumberFormatter.compact(reward.xp)),
              ],
            ),
          ),

          // Action button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildRewardChip(String asset, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 16, height: 16),
        SizedBox(width: AppStyles.space1),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textSm,
            fontWeight: AppStyles.fontSemibold,
            color:
                achievement.isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (achievement.canClaimReward) {
      return DuoButton(
        text: 'Nhận',
        onPressed: isClaiming ? null : onClaim,
        isLoading: isClaiming,
        size: DuoButtonSize.sm,
        variant: _getButtonVariant(),
        fullWidth: false,
      );
    }

    if (achievement.isRewardClaimed) {
      return DuoBadge(
        text: 'Đã nhận',
        variant: DuoBadgeVariant.success,
        size: DuoBadgeSize.sm,
        icon: Icons.check,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(AppAssets.lock, width: 16, height: 16),
        SizedBox(width: AppStyles.space1),
        Text(
          'Chưa mở',
          style: TextStyle(
            fontSize: AppStyles.textXs,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
