import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/grades_controller.dart';

class GradesView extends GetView<GradesController> {
  const GradesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DuoAppBar(title: 'Điểm học tập', showLogo: false),
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
    return Padding(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Obx(() => DuoStatCard(
            title: 'Tích lũy',
            stats: [
              DuoStatItem(label: 'GPA (Hệ 10)', value: controller.gpa10),
              DuoStatItem(label: 'GPA (Hệ 4)', value: controller.gpa4),
              DuoStatItem(label: 'Tín chỉ', value: controller.totalCredits),
            ],
          )).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildSemesterSelector() {
    return Obx(() {
      if (controller.gradesBySemester.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(bottom: AppStyles.space2),
        child: DuoChipSelector<int>(
          selectedValue: controller.selectedSemesterIndex.value,
          activeColor: AppColors.primary,
          height: 44,
          items: controller.gradesBySemester.asMap().entries.map((entry) {
            final index = entry.key;
            final semester = entry.value;
            final tenHK = semester['ten_hoc_ky'] as String? ?? '';
            final shortName = tenHK.replaceAll('Học kỳ ', 'HK').replaceAll(' - Năm học ', ' ');
            return DuoChipItem<int>(
              value: index,
              label: shortName,
              hasContent: true,
            );
          }).toList(),
          onSelected: controller.selectSemester,
        ),
      );
    });
  }

  Widget _buildSemesterInfo() {
    return Obx(() {
      final semGpa10 = controller.semesterGpa10;
      final semGpa4 = controller.semesterGpa4;
      final semCredits = controller.semesterCredits;
      final classification = controller.classification;

      if (semGpa10.isEmpty && semCredits.isEmpty) return const SizedBox.shrink();

      final stats = <DuoStatItem>[
        DuoStatItem(label: 'ĐTB HK (10)', value: semGpa10),
        DuoStatItem(label: 'ĐTB HK (4)', value: semGpa4),
        DuoStatItem(label: 'TC đạt', value: semCredits),
      ];

      if (classification.isNotEmpty) {
        stats.add(DuoStatItem(label: 'Xếp loại', value: classification));
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
        child: DuoMiniStatRow(stats: stats),
      ).animate().fadeIn(duration: 300.ms);
    });
  }

  Widget _buildGradesList() {
    return Obx(() {
      final grades = controller.currentSemesterGrades;
      if (grades.isEmpty) {
        return DuoEmptyState(
          icon: Iconsax.document,
          title: 'Chưa có điểm',
          subtitle: 'Điểm sẽ được cập nhật khi có kết quả',
          iconColor: AppColors.textTertiary,
          iconBackgroundColor: AppColors.backgroundDark,
        ).animate().fadeIn(duration: 300.ms);
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppStyles.space4),
        itemCount: grades.length,
        itemBuilder: (context, index) {
          final grade = grades[index];
          return Padding(
            padding: EdgeInsets.only(bottom: AppStyles.space3),
            child: DuoGradeCard(
              subject: grade['ten_mon'] ?? 'N/A',
              credits: grade['so_tin_chi']?.toString() ?? '0',
              group: grade['nhom_to']?.toString(),
              score: grade['diem_tk']?.toString(),
              letterGrade: grade['diem_tk_chu']?.toString(),
              score4: grade['diem_tk_so']?.toString(),
              note: grade['ly_do_khong_tinh_diem_tbtl']?.toString(),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
        },
      );
    });
  }
}
