import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/curriculum_controller.dart';

class CurriculumView extends GetView<CurriculumController> {
  const CurriculumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chương trình đào tạo'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.loadCurriculum,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.curriculumList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.book, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text('Chưa có dữ liệu', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.curriculumList.length,
          itemBuilder: (context, index) {
            final item = controller.curriculumList[index];
            return _buildCurriculumItem(item);
          },
        );
      }),
    );
  }

  Widget _buildCurriculumItem(Map<String, dynamic> item) {
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
            item['ten_mon'] ?? 'N/A',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildTag('Mã: ${item['ma_mon'] ?? 'N/A'}'),
              SizedBox(width: 8.w),
              _buildTag('${item['so_tc'] ?? 0} TC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: Get.theme.primaryColor),
      ),
    );
  }
}
