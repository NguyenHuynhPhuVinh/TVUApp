import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/components/widgets.dart';
import '../models/reward_code_model.dart';

/// Dialog hiển thị khi nhận mã thưởng thành công
class DuoRewardCodeSuccessDialog extends StatelessWidget {
  final RewardCodeReward reward;

  const DuoRewardCodeSuccessDialog({
    super.key,
    required this.reward,
  });

  static Future<void> show({required RewardCodeReward reward}) {
    return Get.dialog(
      DuoRewardCodeSuccessDialog(reward: reward),
      barrierDismissible: false,
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
            // Icon thành công
            Container(
              padding: EdgeInsets.all(AppStyles.space4),
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                AppAssets.giftPurple,
                width: 48,
                height: 48,
              ),
            ),
            SizedBox(height: AppStyles.space4),

            // Title
            Text(
              'Nhận mã thành công!',
              style: TextStyle(
                fontSize: AppStyles.textXl,
                fontWeight: AppStyles.fontBold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppStyles.space2),

            Text(
              'Bạn đã nhận được phần thưởng',
              style: TextStyle(
                fontSize: AppStyles.textBase,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppStyles.space4),

            // Rewards
            _buildRewardsList(),
            SizedBox(height: AppStyles.space5),

            // Button
            DuoButton(
              text: 'Tuyệt vời!',
              variant: DuoButtonVariant.primary,
              onPressed: () => Get.back(),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList() {
    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.roundedLg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (reward.coins > 0)
            _buildRewardItem(AppAssets.coin, '+${_formatNumber(reward.coins)}', AppColors.yellow),
          if (reward.diamonds > 0)
            _buildRewardItem(AppAssets.diamond, '+${_formatNumber(reward.diamonds)}', AppColors.primary),
          if (reward.xp > 0)
            _buildRewardItem(AppAssets.xpStar, '+${_formatNumber(reward.xp)}', AppColors.purple),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String asset, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 32, height: 32),
        SizedBox(height: AppStyles.space1),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textBase,
            fontWeight: AppStyles.fontBold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
