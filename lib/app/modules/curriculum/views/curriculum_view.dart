import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/curriculum_controller.dart';

class CurriculumView extends GetView<CurriculumController> {
  const CurriculumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Chương trình đào tạo',
        showLogo: false,
        leading: const DuoBackButton(),
      ),
      body: Obx(() {
        if (controller.semesters.isEmpty) {
          return DuoEmptyState(
            icon: Iconsax.book,
            title: 'Chưa có dữ liệu',
            subtitle: 'Thông tin CTĐT sẽ được cập nhật',
            iconColor: AppColors.textTertiary,
            iconBackgroundColor: AppColors.backgroundDark,
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
    return Padding(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Obx(() {
        final progress = controller.totalCredits > 0
            ? controller.completedCredits / controller.totalCredits
            : 0.0;

        return Container(
          padding: EdgeInsets.all(AppStyles.space5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppStyles.rounded2xl,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppStyles.space2),
                    decoration: BoxDecoration(
                      color: AppColors.withAlpha(Colors.white, 0.2),
                      borderRadius: AppStyles.roundedLg,
                    ),
                    child: Icon(Iconsax.book_1, color: Colors.white, size: AppStyles.iconSm),
                  ),
                  SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Text(
                      controller.majorName.value,
                      style: TextStyle(
                        fontSize: AppStyles.textBase,
                        fontWeight: AppStyles.fontBold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppStyles.space4),
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ hoàn thành',
                        style: TextStyle(
                          fontSize: AppStyles.textSm,
                          color: AppColors.withAlpha(Colors.white, 0.8),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: AppStyles.textSm,
                          fontWeight: AppStyles.fontBold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppStyles.space2),
                  DuoProgressBar(
                    progress: progress,
                    backgroundColor: AppColors.primaryDark,
                    progressColor: AppColors.green,
                    shadowColor: AppColors.greenDark,
                    height: 10,
                  ),
                ],
              ),
              SizedBox(height: AppStyles.space4),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Tín chỉ',
                      '${controller.completedCredits}/${controller.totalCredits}',
                      Iconsax.medal_star,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40.h,
                    color: AppColors.withAlpha(Colors.white, 0.3),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Môn học',
                      '${controller.completedSubjects}/${controller.totalSubjects}',
                      Iconsax.book,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.withAlpha(Colors.white, 0.7), size: AppStyles.iconSm),
        SizedBox(width: AppStyles.space2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: AppStyles.textLg,
                fontWeight: AppStyles.fontBold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: AppStyles.textXs,
                color: AppColors.withAlpha(Colors.white, 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSemesterSelector() {
    return Obx(() {
      if (controller.semesters.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(bottom: AppStyles.space2),
        child: DuoChipSelector<int>(
          selectedValue: controller.selectedSemesterIndex.value,
          activeColor: AppColors.primary,
          height: 44,
          items: controller.semesters.asMap().entries.map((entry) {
            final index = entry.key;
            final semester = entry.value;
            final tenHK = semester['ten_hoc_ky'] as String? ?? '';
            final shortName = tenHK.replaceAll('Học kỳ ', 'HK').replaceAll(' - Năm học ', ' ');
            final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
            final completed = subjects.where((s) => s['mon_da_dat'] == 'x').length;
            final isAllCompleted = completed == subjects.length && subjects.isNotEmpty;

            return DuoChipItem<int>(
              value: index,
              label: shortName,
              hasContent: isAllCompleted,
            );
          }).toList(),
          onSelected: controller.selectSemester,
        ),
      );
    });
  }

  Widget _buildSubjectList() {
    return Obx(() {
      final subjects = controller.currentSemesterSubjects;
      if (subjects.isEmpty) {
        return Center(
          child: Text(
            'Không có môn học',
            style: TextStyle(fontSize: AppStyles.textBase, color: AppColors.textTertiary),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppStyles.space4),
        itemCount: subjects.length,
        itemBuilder: (context, index) => _buildSubjectCard(subjects[index], index),
      );
    });
  }

  Widget _buildSubjectCard(Map<String, dynamic> item, int index) {
    final isCompleted = item['mon_da_dat'] == 'x';
    final isRequired = item['mon_bat_buoc'] == 'x';
    final soTC = item['so_tin_chi']?.toString() ?? '0';
    final lyThuyet = item['ly_thuyet']?.toString() ?? '';
    final thucHanh = item['thuc_hanh']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: DuoCard(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.green : AppColors.textTertiary,
                    borderRadius: AppStyles.roundedFull,
                  ),
                ),
                SizedBox(width: AppStyles.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['ten_mon'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: AppStyles.textBase,
                          fontWeight: AppStyles.fontSemibold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppStyles.space1),
                      Text(
                        item['ma_mon'] ?? '',
                        style: TextStyle(
                          fontSize: AppStyles.textSm,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppStyles.space3,
                    vertical: AppStyles.space1,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.greenSoft : AppColors.backgroundDark,
                    borderRadius: AppStyles.roundedFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCompleted)
                        Icon(Iconsax.tick_circle, size: 14.sp, color: AppColors.green),
                      if (isCompleted) SizedBox(width: AppStyles.space1),
                      Text(
                        isCompleted ? 'Đạt' : 'Chưa học',
                        style: TextStyle(
                          fontSize: AppStyles.textXs,
                          fontWeight: AppStyles.fontSemibold,
                          color: isCompleted ? AppColors.green : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppStyles.space3),
            Wrap(
              spacing: AppStyles.space2,
              runSpacing: AppStyles.space2,
              children: [
                _buildTag('$soTC TC', AppColors.primary),
                if (isRequired)
                  _buildTag('Bắt buộc', AppColors.orange)
                else
                  _buildTag('Tự chọn', AppColors.purple),
                if (lyThuyet.isNotEmpty && lyThuyet != '0')
                  _buildTag('LT: $lyThuyet', AppColors.green),
                if (thucHanh.isNotEmpty && thucHanh != '0')
                  _buildTag('TH: $thucHanh', AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space2, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(color, 0.1),
        borderRadius: AppStyles.roundedMd,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: AppStyles.fontSemibold,
        ),
      ),
    );
  }
}
