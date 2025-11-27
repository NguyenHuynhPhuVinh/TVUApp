import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/news_controller.dart';

class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(icon: const Icon(Iconsax.refresh), onPressed: controller.loadNotifications),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notificationList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.notification, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text('Chưa có thông báo', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.notificationList.length,
            itemBuilder: (context, index) => _buildNotificationItem(controller.notificationList[index]),
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item) {
    final isRead = item['is_da_doc'] == true;
    final isPriority = item['is_phai_xem'] == true;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPriority ? Colors.red.withValues(alpha: 0.3) : (isRead ? Colors.grey.withValues(alpha: 0.2) : Get.theme.primaryColor.withValues(alpha: 0.3)),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _showNotificationDetail(item),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!isRead)
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(color: Get.theme.primaryColor, shape: BoxShape.circle),
                      ),
                    if (isPriority)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4.r)),
                        child: Text('Quan trọng', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    Expanded(
                      child: Text(
                        item['doi_tuong_search'] ?? '',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  item['tieu_de'] ?? 'N/A',
                  style: TextStyle(fontSize: 14.sp, fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(Iconsax.calendar, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      controller.formatDate(item['ngay_gui']),
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(Map<String, dynamic> item) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['tieu_de'] ?? 'N/A',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(Iconsax.calendar, size: 16.sp, color: Colors.grey),
                        SizedBox(width: 6.w),
                        Text(controller.formatDate(item['ngay_gui']), style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Divider(),
                    SizedBox(height: 16.h),
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
    // Simple HTML to text conversion
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
    
    return Text(text, style: TextStyle(fontSize: 14.sp, height: 1.6));
  }
}
