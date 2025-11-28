import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../features/gamification/utils/rank_helper.dart';
import 'duo_currency_row.dart';

/// Item hiển thị rank reward với trạng thái claim
class DuoRankRewardItem extends StatelessWidget {
  final RankTier tier;
  final int level;
  final int rankIndex;
  final bool isUnlocked; // Đã đạt rank này chưa
  final bool isClaimed; // Đã nhận thưởng chưa
  final bool isLoading;
  final int coinsReward;
  final int xpReward;
  final int diamondsReward;
  final VoidCallback? onClaim;

  const DuoRankRewardItem({
    super.key,
    required this.tier,
    required this.level,
    required this.rankIndex,
    required this.isUnlocked,
    required this.isClaimed,
    this.isLoading = false,
    required this.coinsReward,
    required this.xpReward,
    required this.diamondsReward,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final color = RankHelper.getTierColor(tier);
    final darkColor = RankHelper.getTierDarkColor(tier);
    final rankName = RankHelper.getRankName(tier, level);
    final rankAsset = RankHelper.getAssetPath(tier, level);

    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space2),
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.backgroundWhite : AppColors.background,
        borderRadius: AppStyles.roundedLg,
        border: Border.all(
          color: isClaimed ? AppColors.green : (isUnlocked ? color : AppColors.border),
          width: isClaimed ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [BoxShadow(color: darkColor, offset: const Offset(0, 3), blurRadius: 0)]
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.withAlpha(color, 0.2)
                  : AppColors.withAlpha(AppColors.textTertiary, 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: Image.asset(
                  rankAsset,
                  width: 32.w,
                  height: 32.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(width: AppStyles.space3),
          // Rank info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rankName,
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontBold,
                    color: isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
                SizedBox(height: AppStyles.space1),
                // Rewards preview - sử dụng DuoCurrencyRow
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      DuoCurrencyRow.coin(
                        value: coinsReward,
                        size: DuoCurrencySize.sm,
                        valueStyle: TextStyle(
                          fontSize: AppStyles.textSm,
                          fontWeight: AppStyles.fontMedium,
                          color: isUnlocked ? AppColors.yellow : AppColors.textTertiary,
                        ),
                      ),
                      SizedBox(width: AppStyles.space2),
                      DuoCurrencyRow.xp(
                        value: xpReward,
                        size: DuoCurrencySize.sm,
                        valueStyle: TextStyle(
                          fontSize: AppStyles.textSm,
                          fontWeight: AppStyles.fontMedium,
                          color: isUnlocked ? AppColors.purple : AppColors.textTertiary,
                        ),
                      ),
                      SizedBox(width: AppStyles.space2),
                      DuoCurrencyRow.diamond(
                        value: diamondsReward,
                        size: DuoCurrencySize.sm,
                        valueStyle: TextStyle(
                          fontSize: AppStyles.textSm,
                          fontWeight: AppStyles.fontMedium,
                          color: isUnlocked ? AppColors.primary : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action button
          _buildActionButton(color, darkColor),
        ],
      ),
    );
  }

  Widget _buildActionButton(Color color, Color darkColor) {
    if (isClaimed) {
      // Đã nhận
      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space2),
        decoration: BoxDecoration(
          color: AppColors.greenSoft,
          borderRadius: AppStyles.roundedFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.checkmark,
              width: 16.w,
              height: 16.w,
            ),
            SizedBox(width: 4.w),
            Text(
              'Đã nhận',
              style: TextStyle(
                fontSize: AppStyles.textXs,
                fontWeight: AppStyles.fontSemibold,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      );
    }

    if (!isUnlocked) {
      // Chưa đạt rank
      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space2),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppStyles.roundedFull,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.lock,
              width: 16.w,
              height: 16.w,
            ),
            SizedBox(width: 4.w),
            Text(
              'Chưa đạt',
              style: TextStyle(
                fontSize: AppStyles.textXs,
                fontWeight: AppStyles.fontMedium,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    // Có thể nhận
    return GestureDetector(
      onTap: isLoading ? null : onClaim,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppStyles.roundedFull,
          boxShadow: [BoxShadow(color: darkColor, offset: const Offset(0, 3), blurRadius: 0)],
        ),
        child: isLoading
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.giftPurple,
                    width: 16.w,
                    height: 16.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Nhận',
                    style: TextStyle(
                      fontSize: AppStyles.textXs,
                      fontWeight: AppStyles.fontBold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

}



