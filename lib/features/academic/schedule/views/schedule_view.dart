import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/components/widgets.dart';
import '../../../../core/extensions/animation_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../features/academic/widgets/academic_widgets.dart';
import '../../../../features/gamification/widgets/game_widgets.dart';
import '../../models/schedule_model.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  static const _days = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'CN'
  ];
  static const _dayColors = [
    AppColors.primary,
    AppColors.green,
    AppColors.orange,
    AppColors.purple,
    AppColors.red,
    AppColors.primary,
    AppColors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DuoAppBar(title: 'Thời khóa biểu', showLogo: false),
      body: Obx(() {
        if (controller.semesters.isEmpty) {
          return DuoEmptyState(
            icon: Iconsax.calendar,
            title: 'Chưa có dữ liệu',
            subtitle: 'Vui lòng đăng nhập để xem thời khóa biểu',
          );
        }
        return Column(
          children: [
            _SemesterSection(controller: controller),
            _WeekSection(controller: controller),
            Expanded(child: _ScheduleListSection(controller: controller)),
          ],
        );
      }),
    );
  }
}

class _SemesterSection extends StatelessWidget {
  final ScheduleController controller;
  const _SemesterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.semesters.firstWhereOrNull(
        (s) => s['hoc_ky'] == controller.selectedSemester.value,
      );
      final tenHocKy = selected?['ten_hoc_ky'] as String? ?? 'Chọn học kỳ';
      final isCurrent =
          controller.selectedSemester.value == controller.currentSemester.value;

      return DuoSemesterSelector(
        tenHocKy: tenHocKy,
        isCurrent: isCurrent,
        onTap: () => DuoSemesterPicker.show(
          semesters: controller.semesters,
          selectedSemester: controller.selectedSemester.value,
          currentSemester: controller.currentSemester.value,
          onSelected: controller.changeSemester,
        ),
      );
    });
  }
}

class _WeekSection extends StatelessWidget {
  final ScheduleController controller;
  const _WeekSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.weeks.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(bottom: AppStyles.space3),
        child: DuoChipSelector<int>(
          selectedValue: controller.selectedWeekIndex.value,
          activeColor: AppColors.primary,
          height: 48,
          items: controller.weeks.asMap().entries.map((entry) {
            final index = entry.key;
            final week = entry.value;
            return DuoChipItem<int>(
              value: index,
              label: 'Tuần ${week.tuanHocKy}',
              hasContent: week.lessons.isNotEmpty,
            );
          }).toList(),
          onSelected: controller.selectWeek,
        ),
      );
    });
  }
}


class _ScheduleListSection extends StatelessWidget {
  final ScheduleController controller;
  const _ScheduleListSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.currentWeekLessons.isEmpty) {
        final week = controller.weeks.isNotEmpty &&
                controller.selectedWeekIndex.value < controller.weeks.length
            ? controller.weeks[controller.selectedWeekIndex.value]
            : null;
        return DuoEmptyState(
          icon: Iconsax.calendar_remove,
          title: 'Không có lịch học tuần này',
          subtitle: week != null
              ? '${week.ngayBatDau} - ${week.ngayKetThuc}'
              : null,
          iconColor: AppColors.textTertiary,
          iconBackgroundColor: AppColors.backgroundDark,
        ).animateFadeSlide();
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppStyles.space4),
        itemCount: 7,
        itemBuilder: (context, index) {
          final daySchedule = controller.getScheduleByDay(index + 2);
          if (daySchedule.isEmpty) return const SizedBox.shrink();

          return _DayScheduleGroup(
            day: ScheduleView._days[index],
            color: ScheduleView._dayColors[index],
            schedules: daySchedule,
            controller: controller,
          );
        },
      );
    });
  }
}

class _DayScheduleGroup extends StatelessWidget {
  final String day;
  final Color color;
  final List<ScheduleLesson> schedules;
  final ScheduleController controller;

  const _DayScheduleGroup({
    required this.day,
    required this.color,
    required this.schedules,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DuoDayBadge(day: day, color: color),
        SizedBox(height: AppStyles.space3),
        ...schedules.asMap().entries.map((entry) {
          return _ScheduleCardItem(
            lesson: entry.value,
            accentColor: color,
            index: entry.key,
            controller: controller,
          );
        }),
        SizedBox(height: AppStyles.space4),
      ],
    );
  }
}

class _ScheduleCardItem extends StatelessWidget {
  final ScheduleLesson lesson;
  final Color accentColor;
  final int index;
  final ScheduleController controller;

  const _ScheduleCardItem({
    required this.lesson,
    required this.accentColor,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool hasCheckedIn = false;
      bool canCheckIn = false;
      bool isCheckingIn = false;
      bool isBeforeGameInit = false;
      bool isExpired = false;
      Duration? timeRemaining;

      try {
        hasCheckedIn = controller.hasCheckedInLesson(lesson);
        canCheckIn = controller.canCheckInLesson(lesson);
        isCheckingIn = controller.isCheckingIn(lesson);
        isBeforeGameInit = controller.isLessonBeforeGameInit(lesson);
        isExpired = controller.isLessonExpired(lesson);
        timeRemaining = controller.getTimeUntilCheckIn(lesson);
      } catch (e) {
        // Ignore errors
      }

      return DuoScheduleCard(
        tenMon: lesson.tenMon,
        soTinChi: lesson.soTiet, // Note: Model có thể cần thêm field soTinChi
        tietBatDau: lesson.tietBatDau,
        soTiet: lesson.soTiet,
        maPhong: lesson.maPhong,
        tenGiangVien: lesson.tenGiangVien,
        maNhom: null,
        accentColor: accentColor,
        canCheckIn: canCheckIn,
        hasCheckedIn: hasCheckedIn,
        isCheckingIn: isCheckingIn,
        isBeforeGameInit: isBeforeGameInit,
        isExpired: isExpired,
        timeRemaining: timeRemaining,
        onCheckIn: () => _handleCheckIn(context),
      ).animateFadeSlideRight(delay: (index * 50).toDouble(), slideBegin: 0.1);
    });
  }

  void _handleCheckIn(BuildContext context) async {
    final rewards = await controller.checkInLesson(lesson);
    if (rewards != null) {
      DuoRewardDialog.show(
        tenMon: lesson.tenMon,
        rewards: rewards,
      );
    } else {
      Get.snackbar(
        'Không thể điểm danh',
        'Vui lòng thử lại sau hoặc kiểm tra thiết bị của bạn',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redSoft,
        colorText: AppColors.red,
        margin: EdgeInsets.all(AppStyles.space4),
        borderRadius: AppStyles.radiusLg,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
