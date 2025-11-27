import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời khóa biểu'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.loadSchedule,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildWeekSelector(),
            Expanded(child: _buildScheduleList()),
          ],
        );
      }),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.weeks.length,
        itemBuilder: (context, index) {
          final week = controller.weeks[index];
          final isSelected = controller.selectedWeekIndex.value == index;
          return GestureDetector(
            onTap: () => controller.selectWeek(index),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? Get.theme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  'Tuần ${week['tuan'] ?? index + 1}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildScheduleList() {
    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    
    return Obx(() {
      if (controller.currentWeekSchedule.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.calendar_remove, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'Không có lịch học tuần này',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 7,
        itemBuilder: (context, index) {
          final daySchedule = controller.getScheduleByDay(index + 2);
          if (daySchedule.isEmpty) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  days[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ...daySchedule.map((item) => _buildScheduleCard(item)),
              SizedBox(height: 16.h),
            ],
          );
        },
      );
    });
  }

  Widget _buildScheduleCard(Map<String, dynamic> item) {
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
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Get.theme.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(Iconsax.clock, 'Tiết ${item['tiet_bat_dau'] ?? 'N/A'} - ${item['tiet_ket_thuc'] ?? 'N/A'}'),
          SizedBox(height: 4.h),
          _buildInfoRow(Iconsax.location, item['phong'] ?? 'N/A'),
          SizedBox(height: 4.h),
          _buildInfoRow(Iconsax.teacher, item['giao_vien'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
