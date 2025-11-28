import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/services/game_service.dart';
import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/rank_helper.dart';
import 'duo_currency_row.dart';
import 'duo_rank_reward_item.dart';

/// Bottom sheet hiển thị danh sách rank rewards
class DuoRankRewardsSheet extends StatelessWidget {
  final int currentRankIndex;
  final List<int> claimedRanks;
  final bool isClaimingAll; // Loading cho nút "Nhận tất cả"
  final int? claimingRankIndex; // Loading cho từng rank (null = không loading)
  final VoidCallback? onClaimAll;
  final Function(int rankIndex)? onClaimRank;

  const DuoRankRewardsSheet({
    super.key,
    required this.currentRankIndex,
    required this.claimedRanks,
    this.isClaimingAll = false,
    this.claimingRankIndex,
    this.onClaimAll,
    this.onClaimRank,
  });

  /// Tính rewards cho mỗi rank - lấy từ GameService
  static Map<String, int> getRewardsForRank(int rankIndex) {
    return GameService.calculateRankReward(rankIndex);
  }

  /// Tính tổng rewards chưa claim
  Map<String, int> get unclaimedRewards {
    int totalCoins = 0;
    int totalXp = 0;
    int totalDiamonds = 0;
    
    for (int i = 0; i <= currentRankIndex; i++) {
      if (!claimedRanks.contains(i)) {
        final rewards = getRewardsForRank(i);
        totalCoins += rewards['coins']!;
        totalXp += rewards['xp']!;
        totalDiamonds += rewards['diamonds']!;
      }
    }
    
    return {'coins': totalCoins, 'xp': totalXp, 'diamonds': totalDiamonds};
  }

  /// Số rank chưa claim
  int get unclaimedCount {
    int count = 0;
    for (int i = 0; i <= currentRankIndex; i++) {
      if (!claimedRanks.contains(i)) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.radius2xl)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: AppStyles.space3),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppStyles.roundedFull,
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(AppStyles.space4),
            child: Row(
              children: [
                Image.asset(
                  AppAssets.giftPurple,
                  width: 32.w,
                  height: 32.w,
                ),
                SizedBox(width: AppStyles.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thưởng theo Rank',
                        style: TextStyle(
                          fontSize: AppStyles.textXl,
                          fontWeight: AppStyles.fontBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Nhận thưởng khi đạt rank mới',
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
          // Claim all button (nếu có rewards chưa claim)
          if (unclaimedCount > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
              child: _buildClaimAllButton(),
            ),
          SizedBox(height: AppStyles.space3),
          // Rank list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
              itemCount: RankHelper.totalRanks,
              itemBuilder: (context, index) {
                final tier = RankHelper.getTierFromIndex(index);
                final level = RankHelper.getLevelFromIndex(index);
                final rewards = getRewardsForRank(index);
                final isUnlocked = index <= currentRankIndex;
                final isClaimed = claimedRanks.contains(index);
                
                return DuoRankRewardItem(
                  tier: tier,
                  level: level,
                  rankIndex: index,
                  isUnlocked: isUnlocked,
                  isClaimed: isClaimed,
                  isLoading: claimingRankIndex == index,
                  coinsReward: rewards['coins']!,
                  xpReward: rewards['xp']!,
                  diamondsReward: rewards['diamonds']!,
                  onClaim: () => onClaimRank?.call(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimAllButton() {
    final rewards = unclaimedRewards;
    final isDisabled = isClaimingAll || claimingRankIndex != null;
    
    return GestureDetector(
      onTap: isDisabled ? null : onClaimAll,
      child: Container(
        padding: EdgeInsets.all(AppStyles.space3),
        decoration: BoxDecoration(
          gradient: AppColors.purpleGradient,
          borderRadius: AppStyles.roundedLg,
          boxShadow: [
            BoxShadow(color: AppColors.purpleDark, offset: const Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppStyles.space2),
              decoration: BoxDecoration(
                color: AppColors.withAlpha(Colors.white, 0.2),
                borderRadius: AppStyles.roundedMd,
              ),
              child: Image.asset(
                AppAssets.chest,
                width: 32.w,
                height: 32.w,
              ),
            ),
            SizedBox(width: AppStyles.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhận tất cả ($unclaimedCount)',
                    style: TextStyle(
                      fontSize: AppStyles.textBase,
                      fontWeight: AppStyles.fontBold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        DuoCurrencyRow.coin(
                          value: rewards['coins']!,
                          size: DuoCurrencySize.sm,
                          valueStyle: TextStyle(
                            fontSize: AppStyles.textSm,
                            fontWeight: AppStyles.fontSemibold,
                            color: AppColors.yellowLight,
                          ),
                        ),
                        SizedBox(width: AppStyles.space2),
                        DuoCurrencyRow.xp(
                          value: rewards['xp']!,
                          size: DuoCurrencySize.sm,
                          valueStyle: TextStyle(
                            fontSize: AppStyles.textSm,
                            fontWeight: AppStyles.fontSemibold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: AppStyles.space2),
                        DuoCurrencyRow.diamond(
                          value: rewards['diamonds']!,
                          size: DuoCurrencySize.sm,
                          valueStyle: TextStyle(
                            fontSize: AppStyles.textSm,
                            fontWeight: AppStyles.fontSemibold,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isClaimingAll)
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }

}
