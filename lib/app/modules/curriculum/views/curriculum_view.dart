import 'package:flutter/material.dart';
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
            _SummarySection(controller: controller),
            _SemesterSelectorSection(controller: controller),
            Expanded(child: _SubjectListSection(controller: controller)),
          ],
        );
      }),
    );
  }
}

/// Section tổng quan CTĐT
class _SummarySection extends StatelessWidget {
  final CurriculumController controller;

  const _SummarySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Obx(() => DuoCurriculumSummary(
            majorName: controller.majorName.value,
            completedCredits: controller.completedCredits,
            totalCredits: controller.totalCredits,
            completedSubjects: controller.completedSubjects,
            totalSubjects: controller.totalSubjects,
          )),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

/// Section chọn học kỳ
class _SemesterSelectorSection extends StatelessWidget {
  final CurriculumController controller;

  const _SemesterSelectorSection({required this.controller});

  @override
  Widget build(BuildContext context) {
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
            final shortName = tenHK
                .replaceAll('Học kỳ ', 'HK')
                .replaceAll(' - Năm học ', ' ');
            final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
            final completed =
                subjects.where((s) => s['mon_da_dat'] == 'x').length;
            final isAllCompleted =
                completed == subjects.length && subjects.isNotEmpty;
            final hasUnclaimedReward = controller.semesterHasUnclaimedReward(index);

            return DuoChipItem<int>(
              value: index,
              label: shortName,
              hasContent: isAllCompleted,
              hasBadge: hasUnclaimedReward, // Chấm đỏ nếu có môn chưa nhận thưởng
            );
          }).toList(),
          onSelected: controller.selectSemester,
        ),
      );
    });
  }
}

/// Section danh sách môn học
class _SubjectListSection extends StatelessWidget {
  final CurriculumController controller;

  const _SubjectListSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subjects = controller.currentSemesterSubjects;
      if (subjects.isEmpty) {
        return Center(
          child: Text(
            'Không có môn học',
            style: TextStyle(
              fontSize: AppStyles.textBase,
              color: AppColors.textTertiary,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppStyles.space4),
        itemCount: subjects.length,
        itemBuilder: (context, index) => _SubjectItem(
          item: subjects[index],
          index: index,
          controller: controller,
        ),
      );
    });
  }
}

/// Item môn học
class _SubjectItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final CurriculumController controller;

  const _SubjectItem({
    required this.item,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final maMon = item['ma_mon'] ?? '';
    
    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: Obx(() {
        // Đọc observable để trigger rebuild
        final _ = controller.claimingSubject.value;
        final claimedSubjects = controller.isSubjectClaimed(maMon);
        
        return DuoSubjectCard(
          tenMon: item['ten_mon'] ?? 'N/A',
          maMon: maMon,
          soTinChi: item['so_tin_chi']?.toString() ?? '0',
          isCompleted: item['mon_da_dat'] == 'x',
          isRequired: item['mon_bat_buoc'] == 'x',
          lyThuyet: item['ly_thuyet']?.toString(),
          thucHanh: item['thuc_hanh']?.toString(),
          rewardStatus: controller.getSubjectRewardStatus(item),
          onClaimReward: () => controller.claimSubjectReward(item),
        );
      }),
    ).animate()
        .fadeIn(duration: 300.ms, delay: (index * 30).ms)
        .slideX(begin: 0.05, end: 0);
  }
}
