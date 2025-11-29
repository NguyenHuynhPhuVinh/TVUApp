import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/components/widgets.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../models/mail_item.dart';

/// Bottom sheet hiển thị chi tiết thư - Duo style
class DuoMailDetailSheet extends StatelessWidget {
  final MailItem mail;
  final VoidCallback? onClaimReward;
  final Color accentColor;

  const DuoMailDetailSheet({
    super.key,
    required this.mail,
    this.onClaimReward,
    this.accentColor = AppColors.primary,
  });

  static Future<void> show({
    required MailItem mail,
    VoidCallback? onClaimReward,
    Color accentColor = AppColors.primary,
  }) {
    return Get.bottomSheet(
      DuoMailDetailSheet(
        mail: mail,
        onClaimReward: onClaimReward,
        accentColor: accentColor,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppStyles.radius2xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppStyles.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: AppStyles.space4),
                  _buildContentCard(),
                  if (mail.hasReward) ...[
                    SizedBox(height: AppStyles.space4),
                    _buildRewardCard(),
                  ],
                  SizedBox(height: AppStyles.space5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppStyles.space3),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: AppStyles.roundedFull,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: AppStyles.roundedLg,
          ),
          child: Center(
            child: Image.asset(
              mail.hasReward ? AppAssets.giftPurple : _getMailAsset(),
              width: 36,
              height: 36,
            ),
          ),
        ),
        SizedBox(width: AppStyles.space3),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge loại thư
              DuoBadge.tag(
                text: mail.type.displayName,
                color: accentColor,
              ),
              SizedBox(height: AppStyles.space2),
              // Tiêu đề
              Text(
                mail.title,
                style: TextStyle(
                  fontSize: AppStyles.textXl,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppStyles.space1),
              // Thời gian
              Text(
                _formatFullDate(mail.sentAt),
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard() {
    return DuoCard.static(
      backgroundColor: AppColors.background,
      hasBorder: false,
      padding: EdgeInsets.all(AppStyles.space4),
      child: Text(
        mail.content,
        style: TextStyle(
          fontSize: AppStyles.textBase,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    final reward = mail.reward!;

    return DuoCard(
      padding: EdgeInsets.zero,
      shadowColor: mail.isClaimed ? null : AppColors.yellow,
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppStyles.space4),
            child: Row(
              children: [
                Image.asset(
                  mail.isClaimed ? AppAssets.checkmark : AppAssets.chest,
                  width: 32,
                  height: 32,
                ),
                SizedBox(width: AppStyles.space3),
                Text(
                  mail.isClaimed ? 'Đã nhận quà' : 'Phần thưởng đính kèm',
                  style: TextStyle(
                    fontSize: AppStyles.textLg,
                    fontWeight: AppStyles.fontBold,
                    color: mail.isClaimed 
                        ? AppColors.green 
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Rewards
          Container(
            padding: EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: mail.isClaimed 
                  ? AppColors.background 
                  : AppColors.yellowSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppStyles.radiusXl - 1),
                bottomRight: Radius.circular(AppStyles.radiusXl - 1),
              ),
            ),
            child: Column(
              children: [
                // Reward items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (reward.coins > 0)
                      _buildRewardItem(AppAssets.coin, _formatNumber(reward.coins), 'Xu'),
                    if (reward.diamonds > 0)
                      _buildRewardItem(AppAssets.diamond, _formatNumber(reward.diamonds), 'Kim cương'),
                    if (reward.xp > 0)
                      _buildRewardItem(AppAssets.xpStar, _formatNumber(reward.xp), 'XP'),
                  ],
                ),
                // Claim button
                if (mail.canClaimReward) ...[
                  SizedBox(height: AppStyles.space4),
                  DuoButton(
                    text: 'Nhận quà',
                    onPressed: () {
                      onClaimReward?.call();
                      Get.back();
                    },
                    variant: DuoButtonVariant.warning,
                    fullWidth: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String asset, String value, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: AppStyles.roundedLg,
            boxShadow: AppColors.cardBoxShadow(offset: 2),
          ),
          child: Center(
            child: Image.asset(asset, width: 40, height: 40),
          ),
        ),
        SizedBox(height: AppStyles.space2),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textLg,
            fontWeight: AppStyles.fontBold,
            color: mail.isClaimed 
                ? AppColors.textTertiary 
                : AppColors.textPrimary,
          ),
        ),
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

  String _getMailAsset() {
    switch (mail.type) {
      case MailType.system:
        return AppAssets.crown;
      case MailType.reward:
        return AppAssets.giftPurple;
      case MailType.event:
        return AppAssets.fire;
      case MailType.welcome:
        return AppAssets.xpStar;
      case MailType.update:
        return AppAssets.checkmark;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  String _formatFullDate(DateTime date) {
    final weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
