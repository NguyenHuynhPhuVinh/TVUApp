import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';

/// Card hiển thị thông báo
class DuoNotificationCard extends StatelessWidget {
  final String title;
  final String? target;
  final String date;
  final bool isRead;
  final bool isPriority;
  final VoidCallback? onTap;

  const DuoNotificationCard({
    super.key,
    required this.title,
    this.target,
    required this.date,
    this.isRead = false,
    this.isPriority = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DuoCard(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppStyles.space3),
            _buildTitle(),
            SizedBox(height: AppStyles.space3),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (!isRead)
          Container(
            width: 10.w,
            height: 10.w,
            margin: EdgeInsets.only(right: AppStyles.space2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: AppColors.glowEffect(AppColors.primary, blur: 4, spread: 1),
            ),
          ),
        if (isPriority) _buildPriorityBadge(),
        Expanded(
          child: Text(
            target ?? '',
            style: TextStyle(
              fontSize: AppStyles.textXs,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space2, vertical: 2),
      margin: EdgeInsets.only(right: AppStyles.space2),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: AppStyles.roundedMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.redDark,
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.warning_2, size: 10.sp, color: Colors.white),
          SizedBox(width: 2.w),
          Text(
            'Quan trọng',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white,
              fontWeight: AppStyles.fontBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppStyles.textBase,
        fontWeight: isRead ? AppStyles.fontMedium : AppStyles.fontBold,
        color: AppColors.textPrimary,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyles.space2,
            vertical: AppStyles.space1,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: AppStyles.roundedFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.calendar, size: 12.sp, color: AppColors.textTertiary),
              SizedBox(width: AppStyles.space1),
              Text(
                date,
                style: TextStyle(
                  fontSize: AppStyles.textXs,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textTertiary,
          size: AppStyles.iconSm,
        ),
      ],
    );
  }
}
