import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';
import '../feedback/duo_tag.dart';

/// Card hiển thị môn học trong CTĐT
class DuoSubjectCard extends StatelessWidget {
  final String tenMon;
  final String maMon;
  final String soTinChi;
  final bool isCompleted;
  final bool isRequired;
  final String? lyThuyet;
  final String? thucHanh;

  const DuoSubjectCard({
    super.key,
    required this.tenMon,
    required this.maMon,
    required this.soTinChi,
    required this.isCompleted,
    required this.isRequired,
    this.lyThuyet,
    this.thucHanh,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppStyles.space3),
          _buildTags(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                tenMon,
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  fontWeight: AppStyles.fontSemibold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppStyles.space1),
              Text(
                maMon,
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
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
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: AppStyles.space2,
      runSpacing: AppStyles.space2,
      children: [
        DuoTag(text: '$soTinChi TC', color: AppColors.primary),
        if (isRequired)
          DuoTag(text: 'Bắt buộc', color: AppColors.orange)
        else
          DuoTag(text: 'Tự chọn', color: AppColors.purple),
        if (lyThuyet != null && lyThuyet != '0' && lyThuyet!.isNotEmpty)
          DuoTag(text: 'LT: $lyThuyet', color: AppColors.green),
        if (thucHanh != null && thucHanh != '0' && thucHanh!.isNotEmpty)
          DuoTag(text: 'TH: $thucHanh', color: AppColors.primary),
      ],
    );
  }
}
