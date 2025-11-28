import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Bottom sheet chi tiết thông báo
class DuoNotificationDetail {
  static void show({
    required String title,
    required String date,
    required String content,
    bool isPriority = false,
  }) {
    Get.bottomSheet(
      _NotificationDetailContent(
        title: title,
        date: date,
        content: content,
        isPriority: isPriority,
      ),
      isScrollControlled: true,
    );
  }
}

class _NotificationDetailContent extends StatelessWidget {
  final String title;
  final String date;
  final String content;
  final bool isPriority;

  const _NotificationDetailContent({
    required this.title,
    required this.date,
    required this.content,
    required this.isPriority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppStyles.radius3xl),
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
                  if (isPriority) _buildPriorityBadge(),
                  _buildTitle(),
                  SizedBox(height: AppStyles.space3),
                  _buildDateBadge(),
                  SizedBox(height: AppStyles.space4),
                  Divider(color: AppColors.border),
                  SizedBox(height: AppStyles.space4),
                  _buildContent(),
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
      width: 40.w,
      height: 4.h,
      margin: EdgeInsets.only(top: AppStyles.space3),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: AppStyles.roundedFull,
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space3,
        vertical: AppStyles.space1,
      ),
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      decoration: BoxDecoration(
        color: AppColors.redSoft,
        borderRadius: AppStyles.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.warning_2, size: 14.sp, color: AppColors.red),
          SizedBox(width: AppStyles.space1),
          Text(
            'Thông báo quan trọng',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.red,
              fontWeight: AppStyles.fontSemibold,
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
        fontSize: AppStyles.textXl,
        fontWeight: AppStyles.fontBold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space3,
        vertical: AppStyles.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppStyles.roundedLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.calendar, size: AppStyles.iconXs, color: AppColors.primary),
          SizedBox(width: AppStyles.space2),
          Text(
            date,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.primary,
              fontWeight: AppStyles.fontMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Parse HTML to plain text
    String text = content
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<p[^>]*>'), '')
        .replaceAll('</p>', '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    return Text(
      text,
      style: TextStyle(
        fontSize: AppStyles.textBase,
        height: 1.6,
        color: AppColors.textPrimary,
      ),
    );
  }
}
