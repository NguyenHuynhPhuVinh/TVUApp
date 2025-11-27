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
        title: const Text('Tin tức & Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => controller.loadNews(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.newsList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.notification, size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text('Chưa có tin tức', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.newsList.length,
                itemBuilder: (context, index) {
                  final item = controller.newsList[index];
                  return _buildNewsItem(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          _buildChip('Tất cả', ''),
          SizedBox(width: 8.w),
          _buildChip('Thông báo', 'tb'),
          SizedBox(width: 8.w),
          _buildChip('Hướng dẫn', 'hd'),
          SizedBox(width: 8.w),
          _buildChip('Biểu mẫu', 'bm'),
        ],
      ),
    ));
  }

  Widget _buildChip(String label, String value) {
    final isSelected = controller.selectedFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.loadNews(filter: value),
      selectedColor: Get.theme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Get.theme.primaryColor,
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['tieu_de'] ?? 'N/A',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Iconsax.calendar, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                item['ngay_dang_tin'] ?? '',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
