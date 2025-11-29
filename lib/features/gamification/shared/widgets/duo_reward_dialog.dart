import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/components/widgets.dart';

/// Model cho custom reward item
class RewardItem {
  final String icon;
  final String label;
  final int value;
  final Color color;

  const RewardItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

/// Dialog hiển thị phần thưởng sau khi điểm danh
class DuoRewardDialog extends StatelessWidget {
  final String tenMon;
  final int earnedCoins;
  final int earnedDiamonds;
  final int earnedXp;
  final bool leveledUp;
  final int? newLevel;
  final String? customTitle;
  final List<RewardItem>? customRewards;

  const DuoRewardDialog({
    super.key,
    required this.tenMon,
    required this.earnedCoins,
    required this.earnedDiamonds,
    required this.earnedXp,
    this.leveledUp = false,
    this.newLevel,
    this.customTitle,
    this.customRewards,
  });

  /// Show dialog với rewards từ check-in
  static void show({
    required String tenMon,
    required Map<String, dynamic> rewards,
    String? title,
  }) {
    Get.dialog(
      DuoRewardDialog(
        tenMon: tenMon,
        earnedCoins: rewards['earnedCoins'] ?? 0,
        earnedDiamonds: rewards['earnedDiamonds'] ?? 0,
        earnedXp: rewards['earnedXp'] ?? 0,
        leveledUp: rewards['leveledUp'] == true,
        newLevel: rewards['newLevel'],
        customTitle: title,
      ),
      barrierDismissible: true,
    );
  }

  /// Show dialog cho nhận thưởng môn học CTDT
  static void showSubjectReward({
    required String tenMon,
    required Map<String, dynamic> rewards,
  }) {
    Get.dialog(
      DuoRewardDialog(
        tenMon: tenMon,
        earnedCoins: rewards['earnedCoins'] ?? 0,
        earnedDiamonds: rewards['earnedDiamonds'] ?? 0,
        earnedXp: rewards['earnedXp'] ?? 0,
        leveledUp: rewards['leveledUp'] == true,
        newLevel: rewards['newLevel'],
        customTitle: 'Nhận thưởng thành công!',
      ),
      barrierDismissible: true,
    );
  }

  /// Show dialog với custom rewards (cho wallet, shop...)
  static Future<void> showCustom({
    required String title,
    required List<RewardItem> rewards,
    String? subtitle,
    bool leveledUp = false,
    int? newLevel,
  }) async {
    await Get.dialog(
      DuoRewardDialog(
        tenMon: subtitle ?? '',
        earnedCoins: 0,
        earnedDiamonds: 0,
        earnedXp: 0,
        customTitle: title,
        customRewards: rewards,
        leveledUp: leveledUp,
        newLevel: newLevel ?? 1,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppStyles.space5),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppStyles.rounded2xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSuccessIcon(),
            SizedBox(height: AppStyles.space4),
            _buildTitle(),
            SizedBox(height: AppStyles.space2),
            _buildSubjectName(),
            SizedBox(height: AppStyles.space4),
            _buildRewardsSection(),
            if (leveledUp) ...[
              SizedBox(height: AppStyles.space3),
              _buildLevelUpBadge(),
            ],
            SizedBox(height: AppStyles.space5),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle_rounded,
        color: AppColors.green,
        size: 48.w,
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildTitle() {
    return Text(
      customTitle ?? 'Điểm danh thành công!',
      style: TextStyle(
        fontSize: AppStyles.textXl,
        fontWeight: AppStyles.fontBold,
        color: AppColors.green,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubjectName() {
    return Text(
      tenMon,
      style: TextStyle(
        fontSize: AppStyles.textBase,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRewardsSection() {
    // Nếu có custom rewards thì hiển thị custom
    if (customRewards != null && customRewards!.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(AppStyles.space4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppStyles.roundedXl,
        ),
        child: Column(
          children: [
            Text(
              'Phần thưởng',
              style: TextStyle(
                fontSize: AppStyles.textSm,
                fontWeight: AppStyles.fontBold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppStyles.space3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: customRewards!.map((item) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppStyles.space2),
                  child: _DuoRewardItem(
                    assetPath: item.icon,
                    value: '+${_formatNumber(item.value)}',
                    label: item.label,
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
    }

    // Default rewards cho check-in
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.roundedXl,
      ),
      child: Column(
        children: [
          Text(
            'Phần thưởng',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppStyles.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: _DuoRewardItem(
                  assetPath: AppAssets.coin,
                  value: '+${_formatNumber(earnedCoins)}',
                  label: 'Coins',
                ),
              ),
              Flexible(
                child: _DuoRewardItem(
                  assetPath: AppAssets.diamond,
                  value: '+${_formatNumber(earnedDiamonds)}',
                  label: 'Diamonds',
                ),
              ),
              Flexible(
                child: _DuoRewardItem(
                  assetPath: AppAssets.xpStar,
                  value: '+${_formatNumber(earnedXp)}',
                  label: 'XP',
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildLevelUpBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space4, vertical: AppStyles.space2),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: AppStyles.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 16.w),
          SizedBox(width: AppStyles.space1),
          Text(
            'Level Up! Lv.$newLevel',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontBold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildCloseButton() {
    return Builder(
      builder: (context) => DuoButton(
        text: 'Tuyệt vời!',
        variant: DuoButtonVariant.success,
        onPressed: () => Navigator.of(context).pop(),
        fullWidth: true,
      ),
    );
  }

  String _formatNumber(int number) {
    return NumberFormatter.compact(number);
  }
}

/// Widget hiển thị một item reward
class _DuoRewardItem extends StatelessWidget {
  final String assetPath;
  final String value;
  final String label;

  const _DuoRewardItem({
    required this.assetPath,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetPath,
          width: 32.w,
          height: 32.w,
          errorBuilder: (_, _, _) => Icon(
            Icons.card_giftcard,
            size: 32.w,
            color: AppColors.yellow,
          ),
        ),
        SizedBox(height: AppStyles.space1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: AppStyles.textLg,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppStyles.textXs,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}



