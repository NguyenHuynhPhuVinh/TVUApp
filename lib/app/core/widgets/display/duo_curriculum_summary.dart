import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../feedback/duo_progress.dart';

/// Card tổng quan chương trình đào tạo
class DuoCurriculumSummary extends StatelessWidget {
  final String majorName;
  final int completedCredits;
  final int totalCredits;
  final int completedSubjects;
  final int totalSubjects;

  const DuoCurriculumSummary({
    super.key,
    required this.majorName,
    required this.completedCredits,
    required this.totalCredits,
    required this.completedSubjects,
    required this.totalSubjects,
  });

  double get progress =>
      totalCredits > 0 ? completedCredits / totalCredits : 0.0;

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          SizedBox(height: AppStyles.space4),
          _buildProgressSection(),
          SizedBox(height: AppStyles.space4),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppStyles.space2),
          decoration: BoxDecoration(
            color: AppColors.withAlpha(Colors.white, 0.2),
            borderRadius: AppStyles.roundedLg,
          ),
          child: Icon(
            Iconsax.book_1,
            color: Colors.white,
            size: AppStyles.iconSm,
          ),
        ),
        SizedBox(width: AppStyles.space3),
        Expanded(
          child: Text(
            majorName,
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
    );
  }

  Widget _buildProgressSection() {
    return Column(
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
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Iconsax.medal_star,
            label: 'Tín chỉ',
            value: '$completedCredits/$totalCredits',
          ),
        ),
        Container(
          width: 1,
          height: 40.h,
          color: AppColors.withAlpha(Colors.white, 0.3),
        ),
        Expanded(
          child: _StatItem(
            icon: Iconsax.book,
            label: 'Môn học',
            value: '$completedSubjects/$totalSubjects',
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.withAlpha(Colors.white, 0.7),
          size: AppStyles.iconSm,
        ),
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
}
