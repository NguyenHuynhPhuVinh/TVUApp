import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/news_controller.dart';

class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Thông báo',
        showLogo: false,
        leading: const DuoBackButton(),
      ),
      body: Obx(() {
        if (controller.notificationList.isEmpty) {
          return DuoEmptyState(
            icon: Iconsax.notification,
            title: 'Chưa có thông báo',
            subtitle: 'Thông báo mới sẽ xuất hiện ở đây',
            iconColor: AppColors.textTertiary,
            iconBackgroundColor: AppColors.backgroundDark,
          ).animate().fadeIn(duration: 300.ms);
        }
        return ListView.builder(
          padding: EdgeInsets.all(AppStyles.space4),
          itemCount: controller.notificationList.length,
          itemBuilder: (context, index) => _buildNotificationItem(
            controller.notificationList[index],
            index,
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item, int index) {
    final isRead = item['is_da_doc'] == true;
    final isPriority = item['is_phai_xem'] == true;

    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: GestureDetector(
        onTap: () => _showNotificationDetail(item),
        child: DuoCard(
          padding: EdgeInsets.all(AppStyles.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Unread indicator
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
                  // Priority badge
                  if (isPriority)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppStyles.space2,
                        vertical: 2,
                      ),
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
                    ),
                  Expanded(
                    child: Text(
                      item['doi_tuong_search'] ?? '',
                      style: TextStyle(
                        fontSize: AppStyles.textXs,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppStyles.space3),
              Text(
                item['tieu_de'] ?? 'N/A',
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  fontWeight: isRead ? AppStyles.fontMedium : AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppStyles.space3),
              Row(
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
                        Icon(
                          Iconsax.calendar,
                          size: 12.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: AppStyles.space1),
                        Text(
                          controller.formatDate(item['ngay_gui']),
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
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms).slideX(begin: 0.05, end: 0);
  }

  void _showNotificationDetail(Map<String, dynamic> item) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.85),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.radius3xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: AppStyles.space3),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppStyles.roundedFull,
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppStyles.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority badge
                    if (item['is_phai_xem'] == true)
                      Container(
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
                      ),
                    // Title
                    Text(
                      item['tieu_de'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: AppStyles.textXl,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppStyles.space3),
                    // Date
                    Container(
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
                            controller.formatDate(item['ngay_gui']),
                            style: TextStyle(
                              fontSize: AppStyles.textSm,
                              color: AppColors.primary,
                              fontWeight: AppStyles.fontMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppStyles.space4),
                    Divider(color: AppColors.border),
                    SizedBox(height: AppStyles.space4),
                    // Content
                    _buildHtmlContent(item['noi_dung'] ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildHtmlContent(String html) {
    String text = html
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
