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
        if (controller.isLoading.value && controller.semesters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildSemesterSelector(),
            _buildWeekSelector(),
            Expanded(child: _buildScheduleList()),
          ],
        );
      }),
    );
  }

  Widget _buildSemesterSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(() => DropdownButtonFormField<int>(
        value: controller.selectedSemester.value,
        decoration: InputDecoration(
          labelText: 'Học kỳ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        isExpanded: true,
        items: controller.semesters.map((semester) {
          final hocKy = semester['hoc_ky'] as int;
          final tenHocKy = semester['ten_hoc_ky'] as String? ?? '';
          final isCurrent = hocKy == controller.currentSemester.value;
          return DropdownMenuItem<int>(
            value: hocKy,
            child: Text(
              isCurrent ? '$tenHocKy (Hiện tại)' : tenHocKy,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? Get.theme.primaryColor : null,
              ),
            ),
          );
        }).toList(),
        onChanged: controller.changeSemester,
      )),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Obx(() {
        if (controller.weeks.isEmpty) {
          return const SizedBox.shrink();
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: controller.weeks.length,
          itemBuilder: (context, index) {
            final week = controller.weeks[index];
            final isSelected = controller.selectedWeekIndex.value == index;
            final hasSchedule = (week['ds_thoi_khoa_bieu'] as List?)?.isNotEmpty ?? false;
            return GestureDetector(
              onTap: () => controller.selectWeek(index),
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected ? Get.theme.primaryColor : (hasSchedule ? Colors.blue[50] : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(20.r),
                  border: hasSchedule && !isSelected ? Border.all(color: Get.theme.primaryColor.withValues(alpha: 0.3)) : null,
                ),
                child: Center(
                  child: Text(
                    'Tuần ${week['tuan_hoc_ky'] ?? index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : (hasSchedule ? Get.theme.primaryColor : Colors.black54),
                      fontWeight: isSelected || hasSchedule ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildScheduleList() {
    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.currentWeekSchedule.isEmpty) {
        final week = controller.weeks.isNotEmpty && controller.selectedWeekIndex.value < controller.weeks.length
            ? controller.weeks[controller.selectedWeekIndex.value]
            : null;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.calendar_remove, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text('Không có lịch học tuần này', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
              if (week != null) ...[
                SizedBox(height: 8.h),
                Text(
                  '${week['ngay_bat_dau']} - ${week['ngay_ket_thuc']}',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                ),
              ],
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
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
    final tietBatDau = item['tiet_bat_dau'] ?? 0;
    final soTiet = item['so_tiet'] ?? 0;
    final tietKetThuc = tietBatDau + soTiet - 1;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['ten_mon'] ?? 'N/A',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Get.theme.primaryColor),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '${item['so_tin_chi'] ?? 0} TC',
                  style: TextStyle(fontSize: 11.sp, color: Get.theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildInfoRow(Iconsax.clock, 'Tiết $tietBatDau - $tietKetThuc'),
          SizedBox(height: 6.h),
          _buildInfoRow(Iconsax.location, item['ma_phong'] ?? 'N/A'),
          SizedBox(height: 6.h),
          _buildInfoRow(Iconsax.teacher, item['ten_giang_vien'] ?? 'N/A'),
          if (item['ma_nhom'] != null && item['ma_nhom'].toString().isNotEmpty) ...[
            SizedBox(height: 6.h),
            _buildInfoRow(Iconsax.people, 'Nhóm ${item['ma_nhom']}'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]))),
      ],
    );
  }
}
