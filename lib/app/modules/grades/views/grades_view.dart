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
      ),
      body: Column(
        children: [
          _buildGPASummary(),
          _buildSemesterSelector(),
          _buildSemesterInfo(),
          Expanded(child: _buildGradesList()),
        ],
      ),
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
      child: Column(
        children: [
          Text('Tích lũy', style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
          SizedBox(height: 12.h),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGPAItem('GPA (Hệ 10)', controller.gpa10),
              Container(width: 1, height: 50.h, color: Colors.white30),
              _buildGPAItem('GPA (Hệ 4)', controller.gpa4),
              Container(width: 1, height: 50.h, color: Colors.white30),
              _buildGPAItem('Tín chỉ', controller.totalCredits),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildGPAItem(String label, String value) {
    return Column(
      children: [
        Text(
          value.isNotEmpty ? value : '--',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
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
          final tenHK = semester['ten_hoc_ky'] as String? ?? '';
          // Rút gọn tên học kỳ
          final shortName = tenHK.replaceAll('Học kỳ ', 'HK').replaceAll(' - Năm học ', ' ');
          return GestureDetector(
            onTap: () => controller.selectSemester(index),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? Get.theme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  shortName,
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

  Widget _buildSemesterInfo() {
    return Obx(() {
      final semGpa10 = controller.semesterGpa10;
      final semGpa4 = controller.semesterGpa4;
      final semCredits = controller.semesterCredits;
      final classification = controller.classification;
      
      if (semGpa10.isEmpty && semCredits.isEmpty) return const SizedBox.shrink();
      
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSemesterInfoItem('ĐTB HK (10)', semGpa10),
            _buildSemesterInfoItem('ĐTB HK (4)', semGpa4),
            _buildSemesterInfoItem('TC đạt', semCredits),
            if (classification.isNotEmpty)
              _buildSemesterInfoItem('Xếp loại', classification),
          ],
        ),
      );
    });
  }

  Widget _buildSemesterInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value.isNotEmpty ? value : '--',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Get.theme.primaryColor),
        ),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey[600])),
      ],
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
              Text('Chưa có điểm', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: grades.length,
        itemBuilder: (context, index) => _buildGradeCard(grades[index]),
      );
    });
  }

  Widget _buildGradeCard(Map<String, dynamic> grade) {
    final diemTK = grade['diem_tk']?.toString() ?? '';
    final diemTKSo = grade['diem_tk_so']?.toString() ?? '';
    final diemTKChu = grade['diem_tk_chu']?.toString() ?? '';
    final soTC = grade['so_tin_chi']?.toString() ?? '0';
    final lyDoKhongTinh = grade['ly_do_khong_tinh_diem_tbtl']?.toString() ?? '';
    
    // Parse điểm để xác định màu
    double? score;
    if (diemTK.isNotEmpty) {
      score = double.tryParse(diemTK);
    }
    
    Color gradeColor = Colors.grey;
    if (score != null) {
      if (score >= 8.5) {
        gradeColor = Colors.green;
      } else if (score >= 7.0) {
        gradeColor = Colors.blue;
      } else if (score >= 5.5) {
        gradeColor = Colors.orange;
      } else if (score >= 4.0) {
        gradeColor = Colors.deepOrange;
      } else {
        gradeColor = Colors.red;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade['ten_mon'] ?? 'N/A',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text('$soTC TC', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                        if (grade['nhom_to'] != null) ...[
                          Text(' • Nhóm ${grade['nhom_to']}', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (diemTK.isNotEmpty || diemTKChu.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: gradeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (diemTK.isNotEmpty)
                            Text(diemTK, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: gradeColor)),
                          if (diemTKChu.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: gradeColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(diemTKChu, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (diemTKSo.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text('Hệ 4: $diemTKSo', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                      ),
                  ],
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text('Chưa có', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                ),
            ],
          ),
          if (lyDoKhongTinh.isNotEmpty && lyDoKhongTinh != 'Môn chưa nhập điểm') ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                lyDoKhongTinh,
                style: TextStyle(fontSize: 10.sp, color: Colors.amber[800], fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
