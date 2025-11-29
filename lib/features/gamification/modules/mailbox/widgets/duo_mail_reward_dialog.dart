import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/components/widgets.dart';
import '../models/mail_item.dart';

/// Dialog hiển thị phần thưởng khi nhận quà từ thư
class DuoMailRewardDialog extends StatelessWidget {
  final String title;
  final MailReward reward;
  final bool leveledUp;
  final int? newLevel;

  const DuoMailRewardDialog({
    super.key,
    required this.title,
    required this.reward,
    this.leveledUp = false,
    this.newLevel,
  });

  /// Show dialog khi nhận quà từ 1 thư
  static Future<void> show({
    required String title,
    required MailReward reward,
    bool leveledUp = false,
    int? newLevel,
  }) async {
    await Get.dialog(
      DuoMailRewardDialog(
        title: title,
        reward: reward,
        leveledUp: leveledUp,
        newLevel: newLevel,
      ),
      barrierDismissible: true,
    );
  }

  /// Show dialog khi nhận tất cả quà
  static Future<void> showBulk({
    required int count,
    required int totalCoins,
    required int totalDiamonds,
    required int totalXp,
  }) async {
    await Get.dialog(
      DuoMailRewardDialog(
        title: 'Đã nhận $count phần quà!',
        reward: MailReward(
          coins: totalCoins,
          diamonds: totalDiamonds,
          xp: totalXp,
        ),
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
          boxShadow: [
            BoxShadow(
              color: AppColors.yellow.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGiftIcon(),
            SizedBox(height: AppStyles.space4),
            _buildTitle(),
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

  Widget _buildGiftIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.yellow.withValues(alpha: 0.3),
                AppColors.yellow.withValues(alpha: 0),
              ],
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(duration: 1500.ms, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
        // Gift icon
        Container(
          padding: EdgeInsets.all(AppStyles.space4),
          decoration: BoxDecoration(
            color: AppColors.yellowSoft,
            shape: BoxShape.circle,
            boxShadow: AppColors.cardBoxShadow(color: AppColors.yellowDark, offset: 4),
          ),
          child: Image.asset(
            AppAssets.chest,
            width: 48.w,
            height: 48.w,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Nhận quà thành công!',
          style: TextStyle(
            fontSize: AppStyles.textXl,
            fontWeight: AppStyles.fontBold,
            color: AppColors.yellow,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: AppStyles.space1),
        Text(
          title,
          style: TextStyle(
            fontSize: AppStyles.textSm,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border),
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
              if (reward.coins > 0)
                _buildRewardItem(
                  AppAssets.coin,
                  '+${_formatNumber(reward.coins)}',
                  'Xu',
                  0,
                ),
              if (reward.diamonds > 0)
                _buildRewardItem(
                  AppAssets.diamond,
                  '+${_formatNumber(reward.diamonds)}',
                  'Kim cương',
                  100,
                ),
              if (reward.xp > 0)
                _buildRewardItem(
                  AppAssets.xpStar,
                  '+${_formatNumber(reward.xp)}',
                  'XP',
                  200,
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildRewardItem(String asset, String value, String label, int delayMs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: AppStyles.roundedLg,
            boxShadow: AppColors.cardBoxShadow(offset: 2),
          ),
          child: Center(
            child: Image.asset(asset, width: 36.w, height: 36.w),
          ),
        ).animate().scale(delay: Duration(milliseconds: 400 + delayMs), duration: 400.ms, curve: Curves.elasticOut),
        SizedBox(height: AppStyles.space2),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textLg,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 500 + delayMs)),
        Text(
          label,
          style: TextStyle(
            fontSize: AppStyles.textXs,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelUpBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space2,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: AppStyles.roundedFull,
        boxShadow: AppColors.buttonBoxShadow(AppColors.purpleDark, offset: 3),
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
    ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildCloseButton() {
    return Builder(
      builder: (context) => DuoButton(
        text: 'Tuyệt vời!',
        variant: DuoButtonVariant.warning,
        onPressed: () => Navigator.of(context).pop(),
        fullWidth: true,
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
