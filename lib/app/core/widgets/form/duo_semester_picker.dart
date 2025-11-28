import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Bottom sheet chọn học kỳ
class DuoSemesterPicker {
  static void show({
    required List<Map<String, dynamic>> semesters,
    required int? selectedSemester,
    required int currentSemester,
    required Function(int) onSelected,
  }) {
    Get.bottomSheet(
      _SemesterPickerContent(
        semesters: semesters,
        selectedSemester: selectedSemester,
        currentSemester: currentSemester,
        onSelected: onSelected,
      ),
    );
  }
}

class _SemesterPickerContent extends StatelessWidget {
  final List<Map<String, dynamic>> semesters;
  final int? selectedSemester;
  final int currentSemester;
  final Function(int) onSelected;

  const _SemesterPickerContent({
    required this.semesters,
    required this.selectedSemester,
    required this.currentSemester,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppStyles.radius3xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildTitle(),
          Flexible(child: _buildList()),
          SizedBox(height: AppStyles.space4),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppStyles.space3),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: AppStyles.roundedFull,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Text(
        'Chọn học kỳ',
        style: TextStyle(
          fontSize: AppStyles.textLg,
          fontWeight: AppStyles.fontBold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
      itemCount: semesters.length,
      itemBuilder: (context, index) {
        final semester = semesters[index];
        final hocKy = semester['hoc_ky'] as int;
        final tenHocKy = semester['ten_hoc_ky'] as String? ?? '';
        final isCurrent = hocKy == currentSemester;
        final isSelected = hocKy == selectedSemester;

        return _SemesterItem(
          tenHocKy: tenHocKy,
          isCurrent: isCurrent,
          isSelected: isSelected,
          onTap: () {
            onSelected(hocKy);
            Get.back();
          },
        );
      },
    );
  }
}

class _SemesterItem extends StatelessWidget {
  final String tenHocKy;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;

  const _SemesterItem({
    required this.tenHocKy,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  fontWeight: isSelected
                      ? AppStyles.fontBold
                      : AppStyles.fontMedium,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isCurrent) _buildCurrentBadge(),
            if (isSelected) ...[
              SizedBox(width: AppStyles.space2),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: AppStyles.iconMd,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space2,
        vertical: AppStyles.space1,
      ),
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
    );
  }
}
