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
      ),
      body: Obx(() {
        if (controller.semesters.isEmpty) {
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
        return Column(
          children: [
            _buildSummaryCard(),
            _buildSemesterSelector(),
            Expanded(child: _buildSubjectList()),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Get.theme.primaryColor, Get.theme.primaryColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(controller.majorName.value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildStatItem('Tín chỉ', '${controller.completedCredits}/${controller.totalCredits}')),
              Container(width: 1, height: 40.h, color: Colors.white30),
              Expanded(child: _buildStatItem('Môn học', '${controller.completedSubjects}/${controller.totalSubjects}')),
              Container(width: 1, height: 40.h, color: Colors.white30),
              Expanded(child: _buildStatItem('Tiến độ', '${(controller.completedCredits / controller.totalCredits * 100).toStringAsFixed(0)}%')),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
      ],
    );
  }

  Widget _buildSemesterSelector() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.semesters.length,
        itemBuilder: (context, index) {
          final semester = controller.semesters[index];
          final isSelected = controller.selectedSemesterIndex.value == index;
          final tenHK = semester['ten_hoc_ky'] as String? ?? '';
          final shortName = tenHK.replaceAll('Học kỳ ', 'HK').replaceAll(' - Năm học ', ' ');
          
          // Đếm số môn đã đạt trong học kỳ
          final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
          final completed = subjects.where((s) => s['mon_da_dat'] == 'x').length;
          
          return GestureDetector(
            onTap: () => controller.selectSemester(index),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? Get.theme.primaryColor : (completed == subjects.length && subjects.isNotEmpty ? Colors.green[50] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(20.r),
                border: completed == subjects.length && subjects.isNotEmpty && !isSelected 
                    ? Border.all(color: Colors.green.withValues(alpha: 0.5)) 
                    : null,
              ),
              child: Center(
                child: Text(
                  shortName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (completed == subjects.length && subjects.isNotEmpty ? Colors.green[700] : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildSubjectList() {
    return Obx(() {
      final subjects = controller.currentSemesterSubjects;
      if (subjects.isEmpty) {
        return Center(
          child: Text('Không có môn học', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: subjects.length,
        itemBuilder: (context, index) => _buildSubjectCard(subjects[index]),
      );
    });
  }

  Widget _buildSubjectCard(Map<String, dynamic> item) {
    final isCompleted = item['mon_da_dat'] == 'x';
    final isRequired = item['mon_bat_buoc'] == 'x';
    final soTC = item['so_tin_chi']?.toString() ?? '0';
    final lyThuyet = item['ly_thuyet']?.toString() ?? '';
    final thucHanh = item['thuc_hanh']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCompleted ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['ten_mon'] ?? 'N/A',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item['ma_mon'] ?? '',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCompleted) Icon(Iconsax.tick_circle, size: 14.sp, color: Colors.green),
                        if (isCompleted) SizedBox(width: 4.w),
                        Text(
                          isCompleted ? 'Đạt' : 'Chưa học',
                          style: TextStyle(fontSize: 11.sp, color: isCompleted ? Colors.green : Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _buildTag('$soTC TC', Get.theme.primaryColor),
              if (isRequired) _buildTag('Bắt buộc', Colors.orange),
              if (!isRequired) _buildTag('Tự chọn', Colors.blue),
              if (lyThuyet.isNotEmpty && lyThuyet != '0') _buildTag('LT: $lyThuyet', Colors.purple),
              if (thucHanh.isNotEmpty && thucHanh != '0') _buildTag('TH: $thucHanh', Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(text, style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
