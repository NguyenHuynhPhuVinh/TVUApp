import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/grades_controller.dart';

class GradesView extends GetView<GradesController> {
  const GradesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm học tập'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.loadGrades,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildGPASummary(),
            _buildSemesterSelector(),
            Expanded(child: _buildGradesList()),
          ],
        );
      }),
    );
  }

  Widget _buildGPASummary() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Get.theme.primaryColor, Get.theme.primaryColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGPAItem('GPA (Hệ 10)', controller.gpa10.value.toStringAsFixed(2)),
          Container(width: 1, height: 50.h, color: Colors.white30),
          _buildGPAItem('GPA (Hệ 4)', controller.gpa4.value.toStringAsFixed(2)),
          Container(width: 1, height: 50.h, color: Colors.white30),
          _buildGPAItem('Tín chỉ', controller.totalCredits.value.toString()),
        ],
      )),
    );
  }

  Widget _buildGPAItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSemesterSelector() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.gradesBySemester.length,
        itemBuilder: (context, index) {
          final semester = controller.gradesBySemester[index];
          final isSelected = controller.selectedSemesterIndex.value == index;
          return GestureDetector(
            onTap: () => controller.selectSemester(index),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? Get.theme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  semester['ten_hoc_ky'] ?? 'HK ${index + 1}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildGradesList() {
    return Obx(() {
      final grades = controller.currentSemesterGrades;
      if (grades.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'Chưa có điểm',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: grades.length,
        itemBuilder: (context, index) {
          final grade = grades[index];
          return _buildGradeCard(grade);
        },
      );
    });
  }

  Widget _buildGradeCard(Map<String, dynamic> grade) {
    final score10 = grade['diem_tk'] ?? grade['diem_hp'] ?? 0;
    final score4 = grade['diem_tk_he_4'] ?? 0;
    final letterGrade = grade['diem_tk_chu'] ?? '';
    
    Color gradeColor = Colors.grey;
    if (score10 >= 8.5) {
      gradeColor = Colors.green;
    } else if (score10 >= 7.0) {
      gradeColor = Colors.blue;
    } else if (score10 >= 5.5) {
      gradeColor = Colors.orange;
    } else if (score10 > 0) {
      gradeColor = Colors.red;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade['ten_mon'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${grade['so_tin_chi'] ?? 0} tín chỉ',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  letterGrade.isNotEmpty ? letterGrade : score10.toString(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: gradeColor,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Hệ 10: $score10 | Hệ 4: $score4',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
