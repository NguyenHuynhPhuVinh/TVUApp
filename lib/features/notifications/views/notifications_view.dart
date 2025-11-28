import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/extensions/animation_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/components/widgets.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

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
          ).animateFadeSlide();
        }
        return ListView.builder(
          padding: EdgeInsets.all(AppStyles.space4),
          itemCount: controller.notificationList.length,
          itemBuilder: (context, index) => _NotificationItem(
            item: controller.notificationList[index],
            index: index,
            controller: controller,
          ),
        );
      }),
    );
  }
}

/// Item thông báo
class _NotificationItem extends StatelessWidget {
  final NotificationItem item;
  final int index;
  final NotificationsController controller;

  const _NotificationItem({
    required this.item,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: DuoNotificationCard(
        title: item.tieuDe.isNotEmpty ? item.tieuDe : 'N/A',
        target: item.doiTuongSearch,
        date: controller.formatDate(item.ngayGui),
        isRead: item.isRead,
        isPriority: item.isPriority,
        onTap: () => DuoNotificationDetail.show(
          title: item.tieuDe.isNotEmpty ? item.tieuDe : 'N/A',
          date: controller.formatDate(item.ngayGui),
          content: item.noiDung,
          isPriority: item.isPriority,
        ),
      ),
    ).animateFadeSlideRight(delay: (index * 30).toDouble(), slideBegin: 0.05);
  }
}
