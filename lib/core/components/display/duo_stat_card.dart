import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style Stat Card (cho GPA, điểm, thống kê)
class DuoStatCard extends StatelessWidget {
  final String title;
  final List<DuoStatItem> stats;
  final Color? backgroundColor;
  final Color? shadowColor;
  final bool showDividers;

  const DuoStatCard({
    super.key,
    required this.title,
    required this.stats,
    this.backgroundColor,
    this.shadowColor,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final shadow = shadowColor ?? AppColors.primaryDark;

    return Container(
      padding: EdgeInsets.all(AppStyles.space5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.rounded2xl,
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.withAlpha(Colors.white, 0.8),
              fontWeight: AppStyles.fontMedium,
            ),
          ),
          SizedBox(height: AppStyles.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(stats.length * 2 - 1, (index) {
              if (index.isOdd && showDividers) {
                return Container(
                  width: 1,
                  height: 50.h,
                  color: AppColors.withAlpha(Colors.white, 0.3),
                );
              }
              final statIndex = index ~/ 2;
              return _buildStatItem(stats[statIndex]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(DuoStatItem stat) {
    return Column(
      children: [
        Text(
          stat.value.isNotEmpty ? stat.value : '--',
          style: TextStyle(
            fontSize: AppStyles.text2xl,
            fontWeight: AppStyles.fontBold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppStyles.space1),
        Text(
          stat.label,
          style: TextStyle(
            fontSize: AppStyles.textXs,
            color: AppColors.withAlpha(Colors.white, 0.8),
          ),
        ),
      ],
    );
  }
}

class DuoStatItem {
  final String label;
  final String value;

  const DuoStatItem({required this.label, required this.value});
}

/// Duolingo-style Mini Stat Row (cho thông tin học kỳ)
class DuoMiniStatRow extends StatelessWidget {
  final List<DuoStatItem> stats;
  final Color? backgroundColor;
  final Color? textColor;

  const DuoMiniStatRow({
    super.key,
    required this.stats,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space4, vertical: AppStyles.space3),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primarySoft,
        borderRadius: AppStyles.roundedXl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) => _buildItem(stat)).toList(),
      ),
    );
  }

  Widget _buildItem(DuoStatItem stat) {
    final color = textColor ?? AppColors.primary;
    return Column(
      children: [
        Text(
          stat.value.isNotEmpty ? stat.value : '--',
          style: TextStyle(
            fontSize: AppStyles.textBase,
            fontWeight: AppStyles.fontBold,
            color: color,
          ),
        ),
        Text(
          stat.label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.withAlpha(color, 0.7),
          ),
        ),
      ],
    );
  }
}

/// Duolingo-style Grade Card
class DuoGradeCard extends StatelessWidget {
  final String subject;
  final String credits;
  final String? group;
  final String? score;
  final String? letterGrade;
  final String? score4;
  final String? note;
  final Color? accentColor;

  const DuoGradeCard({
    super.key,
    required this.subject,
    required this.credits,
    this.group,
    this.score,
    this.letterGrade,
    this.score4,
    this.note,
    this.accentColor,
  });

  Color get _gradeColor {
    if (accentColor != null) return accentColor!;
    if (score == null || score!.isEmpty) return AppColors.textTertiary;

    final scoreNum = double.tryParse(score!);
    if (scoreNum == null) return AppColors.textTertiary;

    if (scoreNum >= 8.5) return AppColors.green;
    if (scoreNum >= 7.0) return AppColors.primary;
    if (scoreNum >= 5.5) return AppColors.orange;
    if (scoreNum >= 4.0) return AppColors.orangeDark;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border, width: AppStyles.border2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Row(
        children: [
          // Accent bar
          Container(
            width: 4.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: _gradeColor,
              borderRadius: AppStyles.roundedFull,
            ),
          ),
          SizedBox(width: AppStyles.space3),
          // Subject info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppStyles.space1),
                Row(
                  children: [
                    _buildInfoChip('$credits TC'),
                    if (group != null && group!.isNotEmpty) ...[
                      SizedBox(width: AppStyles.space2),
                      _buildInfoChip('Nhóm $group'),
                    ],
                  ],
                ),
                if (note != null && note!.isNotEmpty && note != 'Môn chưa nhập điểm') ...[
                  SizedBox(height: AppStyles.space2),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppStyles.space2, vertical: AppStyles.space1),
                    decoration: BoxDecoration(
                      color: AppColors.orangeSoft,
                      borderRadius: AppStyles.roundedMd,
                    ),
                    child: Text(
                      note!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.orangeDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Score
          _buildScoreSection(),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space2, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: AppStyles.roundedFull,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: AppColors.textSecondary,
          fontWeight: AppStyles.fontMedium,
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    if (score == null || score!.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space2),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: AppStyles.roundedLg,
        ),
        child: Text(
          'Chưa có',
          style: TextStyle(
            fontSize: AppStyles.textSm,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space2),
          decoration: BoxDecoration(
            color: AppColors.withAlpha(_gradeColor, 0.1),
            borderRadius: AppStyles.roundedLg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score!,
                style: TextStyle(
                  fontSize: AppStyles.textLg,
                  fontWeight: AppStyles.fontBold,
                  color: _gradeColor,
                ),
              ),
              if (letterGrade != null && letterGrade!.isNotEmpty) ...[
                SizedBox(width: AppStyles.space2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppStyles.space2, vertical: 2),
                  decoration: BoxDecoration(
                    color: _gradeColor,
                    borderRadius: AppStyles.roundedMd,
                  ),
                  child: Text(
                    letterGrade!,
                    style: TextStyle(
                      fontSize: AppStyles.textXs,
                      fontWeight: AppStyles.fontBold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (score4 != null && score4!.isNotEmpty) ...[
          SizedBox(height: AppStyles.space1),
          Text(
            'Hệ 4: $score4',
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

