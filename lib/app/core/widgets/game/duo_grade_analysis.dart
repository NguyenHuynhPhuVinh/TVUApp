import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Card tổng quan thống kê điểm
class DuoGradeOverview extends StatelessWidget {
  final int totalSubjects;
  final int passedSubjects;
  final int excellentSubjects;

  const DuoGradeOverview({
    super.key,
    required this.totalSubjects,
    required this.passedSubjects,
    required this.excellentSubjects,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: AppStyles.textLg,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppStyles.space3),
          Row(
            children: [
              Expanded(child: _buildStatBox('Tổng môn', totalSubjects.toString(), AppColors.primary)),
              SizedBox(width: AppStyles.space3),
              Expanded(child: _buildStatBox('Đạt', passedSubjects.toString(), AppColors.green)),
              SizedBox(width: AppStyles.space3),
              Expanded(child: _buildStatBox('Xuất sắc', excellentSubjects.toString(), AppColors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(color, 0.1),
        borderRadius: AppStyles.roundedLg,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: AppStyles.text2xl,
              fontWeight: AppStyles.fontBold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppStyles.textXs,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card phân bố điểm theo xếp loại
class DuoGradeDistribution extends StatelessWidget {
  final Map<String, int> distribution;
  final int totalSubjects;
  final Color Function(String) getColor;

  const DuoGradeDistribution({
    super.key,
    required this.distribution,
    required this.totalSubjects,
    required this.getColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bố điểm',
            style: TextStyle(
              fontSize: AppStyles.textLg,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppStyles.space3),
          ...distribution.entries.map((entry) {
            final count = entry.value;
            final percent = totalSubjects > 0 ? (count / totalSubjects) : 0.0;
            final color = getColor(entry.key);
            return Padding(
              padding: EdgeInsets.only(bottom: AppStyles.space2),
              child: _buildDistributionRow(entry.key, count, percent, color),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(String label, int count, double percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppStyles.roundedFull,
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 16.h,
              backgroundColor: AppColors.backgroundDark,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        SizedBox(width: AppStyles.space2),
        SizedBox(
          width: 40.w,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontSemibold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card highlight điểm cao/thấp nhất
class DuoGradeHighlight extends StatelessWidget {
  final String title;
  final String subject;
  final String score;
  final Color color;
  final bool isHighest;

  const DuoGradeHighlight({
    super.key,
    required this.title,
    required this.subject,
    required this.score,
    required this.color,
    this.isHighest = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppStyles.space3),
            decoration: BoxDecoration(
              color: AppColors.withAlpha(color, 0.1),
              borderRadius: AppStyles.roundedLg,
            ),
            child: Icon(
              isHighest ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
              color: color,
              size: AppStyles.iconLg,
            ),
          ),
          SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyles.space3,
              vertical: AppStyles.space2,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppStyles.roundedLg,
            ),
            child: Text(
              score,
              style: TextStyle(
                fontSize: AppStyles.textLg,
                fontWeight: AppStyles.fontBold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
