import 'package:flutter/material.dart';
import '../../../../../core/components/widgets.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../models/mail_item.dart';

/// Card hiển thị một thư trong hòm thư - Duo style
class DuoMailCard extends StatelessWidget {
  final MailItem mail;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color accentColor;

  const DuoMailCard({
    super.key,
    required this.mail,
    this.onTap,
    this.onDelete,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(mail.id),
      direction: mail.canClaimReward 
          ? DismissDirection.none 
          : DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      onDismissed: (_) => onDelete?.call(),
      child: DuoCard(
        onTap: onTap,
        shadowColor: mail.canClaimReward ? accentColor : null,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(AppStyles.space3),
              child: Row(
                children: [
                  _buildIcon(),
                  SizedBox(width: AppStyles.space3),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
            // Footer với quà (nếu có)
            if (mail.hasReward) _buildRewardFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: AppStyles.rounded2xl,
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: mail.isRead 
            ? AppColors.backgroundDark 
            : accentColor.withValues(alpha: 0.15),
        borderRadius: AppStyles.roundedLg,
      ),
      child: Center(
        child: mail.hasReward && !mail.isClaimed
            ? Image.asset(AppAssets.giftPurple, width: 28, height: 28)
            : Image.asset(
                _getMailAsset(),
                width: 28,
                height: 28,
                color: mail.isRead ? AppColors.textTertiary : accentColor,
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề + badge
        Row(
          children: [
            // Chấm đỏ nếu chưa đọc
            if (!mail.isRead)
              Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(right: AppStyles.space2),
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                mail.title,
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  fontWeight: mail.isRead 
                      ? AppStyles.fontMedium 
                      : AppStyles.fontBold,
                  color: mail.isRead 
                      ? AppColors.textSecondary 
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppStyles.space2),
            // Badge loại thư
            DuoBadge.tag(
              text: mail.type.displayName,
              color: accentColor,
            ),
          ],
        ),
        SizedBox(height: AppStyles.space1),
        // Mô tả ngắn
        Text(
          mail.content,
          style: TextStyle(
            fontSize: AppStyles.textSm,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppStyles.space1),
        // Thời gian
        Text(
          _formatDate(mail.sentAt),
          style: TextStyle(
            fontSize: AppStyles.textXs,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardFooter() {
    final reward = mail.reward!;
    
    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: mail.isClaimed 
            ? AppColors.background 
            : AppColors.yellowSoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppStyles.radiusXl - 1),
          bottomRight: Radius.circular(AppStyles.radiusXl - 1),
        ),
      ),
      child: Row(
        children: [
          // Phần thưởng
          Expanded(
            child: Row(
              children: [
                if (reward.coins > 0) ...[
                  _buildRewardChip(AppAssets.coin, _formatNumber(reward.coins)),
                  SizedBox(width: AppStyles.space3),
                ],
                if (reward.diamonds > 0) ...[
                  _buildRewardChip(AppAssets.diamond, _formatNumber(reward.diamonds)),
                  SizedBox(width: AppStyles.space3),
                ],
                if (reward.xp > 0)
                  _buildRewardChip(AppAssets.xpStar, _formatNumber(reward.xp)),
              ],
            ),
          ),
          // Status
          if (mail.canClaimReward)
            DuoBadge(
              text: 'Nhận quà',
              variant: DuoBadgeVariant.warning,
              size: DuoBadgeSize.sm,
            )
          else if (mail.isClaimed)
            DuoBadge(
              text: 'Đã nhận',
              variant: DuoBadgeVariant.success,
              size: DuoBadgeSize.sm,
              icon: Icons.check,
            ),
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
            color: mail.isClaimed 
                ? AppColors.textTertiary 
                : AppColors.textPrimary,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    
    return '${date.day}/${date.month}/${date.year}';
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
