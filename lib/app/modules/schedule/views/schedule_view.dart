import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

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
            _buildSemesterSelector(),
            _buildWeekSelector(),
            Expanded(child: _buildScheduleList()),
          ],
        );
      }),
    );
  }

  Widget _buildSemesterSelector() {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppStyles.space4, AppStyles.space4, AppStyles.space4, AppStyles.space2),
      child: Obx(() {
        final selected = controller.semesters.firstWhereOrNull(
          (s) => s['hoc_ky'] == controller.selectedSemester.value,
        );
        final tenHocKy = selected?['ten_hoc_ky'] as String? ?? 'Chọn học kỳ';
        final isCurrent = controller.selectedSemester.value == controller.currentSemester.value;

        return GestureDetector(
          onTap: () => _showSemesterPicker(),
          child: DuoCard(
            padding: EdgeInsets.symmetric(horizontal: AppStyles.space4, vertical: AppStyles.space3),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppStyles.space2),
                  decoration: BoxDecoration(
                    color: AppColors.withAlpha(AppColors.primary, 0.1),
                    borderRadius: AppStyles.roundedLg,
                  ),
                  child: Icon(Iconsax.calendar_1, color: AppColors.primary, size: AppStyles.iconSm),
                ),
                SizedBox(width: AppStyles.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Học kỳ',
                        style: TextStyle(
                          fontSize: AppStyles.textXs,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        tenHocKy,
                        style: TextStyle(
                          fontSize: AppStyles.textBase,
                          fontWeight: AppStyles.fontSemibold,
                          color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    margin: EdgeInsets.only(right: AppStyles.space2),
                    padding: EdgeInsets.symmetric(horizontal: AppStyles.space2, vertical: AppStyles.space1),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: AppStyles.roundedFull,
                    ),
                    child: Text(
                      'Hiện tại',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showSemesterPicker() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.radius3xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: AppStyles.space3),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppStyles.roundedFull,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppStyles.space4),
              child: Text(
                'Chọn học kỳ',
                style: TextStyle(
                  fontSize: AppStyles.textLg,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
                itemCount: controller.semesters.length,
                itemBuilder: (context, index) {
                  final semester = controller.semesters[index];
                  final hocKy = semester['hoc_ky'] as int;
                  final tenHocKy = semester['ten_hoc_ky'] as String? ?? '';
                  final isCurrent = hocKy == controller.currentSemester.value;
                  final isSelected = hocKy == controller.selectedSemester.value;

                  return GestureDetector(
                    onTap: () {
                      controller.changeSemester(hocKy);
                      Get.back();
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: AppStyles.space2),
                      padding: EdgeInsets.all(AppStyles.space4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primarySoft : AppColors.background,
                        borderRadius: AppStyles.roundedXl,
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tenHocKy,
                              style: TextStyle(
                                fontSize: AppStyles.textBase,
                                fontWeight: isSelected ? AppStyles.fontBold : AppStyles.fontMedium,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppStyles.space2, vertical: AppStyles.space1),
                              decoration: BoxDecoration(
                                color: AppColors.greenSoft,
                                borderRadius: AppStyles.roundedFull,
                              ),
                              child: Text(
                                'Hiện tại',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: AppStyles.fontBold,
                                  color: AppColors.green,
                                ),
                              ),
                            ),
                          if (isSelected) ...[
                            SizedBox(width: AppStyles.space2),
                            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: AppStyles.iconMd),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppStyles.space4),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
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
            final hasSchedule = (week['ds_thoi_khoa_bieu'] as List?)?.isNotEmpty ?? false;
            return DuoChipItem<int>(
              value: index,
              label: 'Tuần ${week['tuan_hoc_ky'] ?? index + 1}',
              hasContent: hasSchedule,
            );
          }).toList(),
          onSelected: controller.selectWeek,
        ),
      );
    });
  }

  Widget _buildScheduleList() {
    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    final dayColors = [
      AppColors.primary,
      AppColors.green,
      AppColors.orange,
      AppColors.purple,
      AppColors.red,
      AppColors.primary,
      AppColors.green,
    ];

    return Obx(() {
      if (controller.currentWeekSchedule.isEmpty) {
        final week = controller.weeks.isNotEmpty &&
                controller.selectedWeekIndex.value < controller.weeks.length
            ? controller.weeks[controller.selectedWeekIndex.value]
            : null;
        return DuoEmptyState(
          icon: Iconsax.calendar_remove,
          title: 'Không có lịch học tuần này',
          subtitle: week != null
              ? '${week['ngay_bat_dau']} - ${week['ngay_ket_thuc']}'
              : null,
          iconColor: AppColors.textTertiary,
          iconBackgroundColor: AppColors.backgroundDark,
        ).animate().fadeIn(duration: 300.ms);
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppStyles.space4),
        itemCount: 7,
        itemBuilder: (context, index) {
          final daySchedule = controller.getScheduleByDay(index + 2);
          if (daySchedule.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DuoDayBadge(day: days[index], color: dayColors[index]),
              SizedBox(height: AppStyles.space3),
              ...daySchedule.asMap().entries.map((entry) {
                return _buildScheduleCard(entry.value, dayColors[index], entry.key)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (entry.key * 50).ms)
                    .slideX(begin: 0.1, end: 0);
              }),
              SizedBox(height: AppStyles.space4),
            ],
          );
        },
      );
    });
  }

  Widget _buildScheduleCard(Map<String, dynamic> item, Color accentColor, int index) {
    final tietBatDau = item['tiet_bat_dau'] ?? 0;
    final soTiet = item['so_tiet'] ?? 0;
    final tietKetThuc = tietBatDau + soTiet - 1;

    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: DuoCard(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: AppStyles.roundedFull,
                  ),
                ),
                SizedBox(width: AppStyles.space3),
                Expanded(
                  child: Text(
                    item['ten_mon'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: AppStyles.textBase,
                      fontWeight: AppStyles.fontBold,
                      color: accentColor,
                    ),
                  ),
                ),
                DuoBadge(
                  text: '${item['so_tin_chi'] ?? 0} TC',
                  variant: _getVariantFromColor(accentColor),
                  size: DuoBadgeSize.sm,
                ),
              ],
            ),
            SizedBox(height: AppStyles.space3),
            _buildInfoRow(Iconsax.clock, 'Tiết $tietBatDau - $tietKetThuc'),
            SizedBox(height: AppStyles.space2),
            _buildInfoRow(Iconsax.location, item['ma_phong'] ?? 'N/A'),
            SizedBox(height: AppStyles.space2),
            _buildInfoRow(Iconsax.teacher, item['ten_giang_vien'] ?? 'N/A'),
            if (item['ma_nhom'] != null && item['ma_nhom'].toString().isNotEmpty) ...[
              SizedBox(height: AppStyles.space2),
              _buildInfoRow(Iconsax.people, 'Nhóm ${item['ma_nhom']}'),
            ],
          ],
        ),
      ),
    );
  }

  DuoBadgeVariant _getVariantFromColor(Color color) {
    if (color == AppColors.green) return DuoBadgeVariant.success;
    if (color == AppColors.orange) return DuoBadgeVariant.warning;
    if (color == AppColors.purple) return DuoBadgeVariant.purple;
    if (color == AppColors.red) return DuoBadgeVariant.danger;
    return DuoBadgeVariant.primary;
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: AppStyles.iconXs, color: AppColors.textTertiary),
        SizedBox(width: AppStyles.space2),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
