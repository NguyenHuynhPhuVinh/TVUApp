import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../models/reward_code_model.dart';

/// Widget hiển thị mã đã nhận trong lịch sử
class DuoClaimedCodeItem extends StatelessWidget {
  final ClaimedRewardCode claimedCode;

  const DuoClaimedCodeItem({
    super.key,
    required this.claimedCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: AppStyles.roundedMd,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppColors.green,
              size: AppStyles.iconMd,
            ),
          ),
          SizedBox(width: AppStyles.space3),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claimedCode.code,
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontBold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: AppStyles.space1),
                Text(
                  _formatDate(claimedCode.claimedAt),
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Rewards
          _buildRewards(),
        ],
      ),
    );
  }

  Widget _buildRewards() {
    final reward = claimedCode.reward;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reward.coins > 0) ...[
          Image.asset(AppAssets.coin, width: 16, height: 16),
          SizedBox(width: 2),
          Text(
            _formatNumber(reward.coins),
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontSemibold,
              color: AppColors.yellow,
            ),
          ),
          SizedBox(width: AppStyles.space2),
        ],
        if (reward.diamonds > 0) ...[
          Image.asset(AppAssets.diamond, width: 16, height: 16),
          SizedBox(width: 2),
          Text(
            _formatNumber(reward.diamonds),
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontSemibold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppStyles.space2),
        ],
        if (reward.xp > 0) ...[
          Image.asset(AppAssets.xpStar, width: 16, height: 16),
          SizedBox(width: 2),
          Text(
            _formatNumber(reward.xp),
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontSemibold,
              color: AppColors.purple,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
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
