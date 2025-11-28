import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/components/widgets.dart';
import '../../../../core/extensions/animation_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../features/academic/widgets/academic_widgets.dart';
import '../../models/curriculum_model.dart';
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

class _SummarySection extends StatelessWidget {
  final CurriculumController controller;
  const _SummarySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Column(
        children: [
          Obx(() => DuoCurriculumSummary(
                majorName: controller.majorName.value,
                completedCredits: controller.completedCredits,
                totalCredits: controller.totalCredits,
                completedSubjects: controller.completedSubjects,
                totalSubjects: controller.totalSubjects,
              )),
          Obx(() {
            final unclaimed = controller.totalUnclaimedRewards;
            if (unclaimed == 0) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.only(top: AppStyles.space3),
              child: DuoButton(
                text: 'Nhận tất cả ($unclaimed môn)',
                icon: Iconsax.gift,
                variant: DuoButtonVariant.warning,
                isLoading: controller.isClaimingAll.value,
                onPressed: controller.claimAllRewards,
              ),
            );
          }),
        ],
      ),
    ).animateFadeSlide(slideBegin: -0.1);
  }
}

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
            final shortName = semester.tenHocKy
                .replaceAll('Học kỳ ', 'HK')
                .replaceAll(' - Năm học ', ' ');
            final isAllCompleted = semester.completedSubjects ==
                    semester.subjects.length &&
                semester.subjects.isNotEmpty;
            final hasUnclaimedReward =
                controller.semesterHasUnclaimedReward(index);

            return DuoChipItem<int>(
              value: index,
              label: shortName,
              hasContent: isAllCompleted,
              hasBadge: hasUnclaimedReward,
            );
          }).toList(),
          onSelected: controller.selectSemester,
        ),
      );
    });
  }
}


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
          subject: subjects[index],
          index: index,
          controller: controller,
        ),
      );
    });
  }
}

class _SubjectItem extends StatelessWidget {
  final CurriculumSubject subject;
  final int index;
  final CurriculumController controller;

  const _SubjectItem({
    required this.subject,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: Obx(() {
        controller.claimingSubject.value;
        controller.isClaimingAll.value;

        return DuoSubjectCard(
          tenMon: subject.tenMon,
          maMon: subject.maMon,
          soTinChi: subject.soTinChi.toString(),
          isCompleted: subject.isCompleted,
          isRequired: true,
          lyThuyet: null,
          thucHanh: null,
          rewardStatus: controller.getSubjectRewardStatus(subject),
          onClaimReward: () => controller.claimSubjectReward(subject),
        );
      }),
    ).animateFadeSlideRight(delay: (index * 30).toDouble(), slideBegin: 0.05);
  }
}
