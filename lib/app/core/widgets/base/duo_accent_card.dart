import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import 'duo_card.dart';

/// Base widget cho các card có thanh màu dọc (accent bar)
/// Thay thế pattern lặp lại trong: DuoScheduleItem, DuoTodayScheduleCard, 
/// DuoGradeCard, DuoTuitionCard, DuoSubjectCard
class DuoAccentCard extends StatelessWidget {
  final Widget content;
  final Widget? trailing;
  final Color accentColor;
  final double accentHeight;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool pressable;

  const DuoAccentCard({
    super.key,
    required this.content,
    this.trailing,
    this.accentColor = AppColors.primary,
    this.accentHeight = 50,
    this.onTap,
    this.padding,
    this.pressable = false,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      padding: padding ?? EdgeInsets.all(AppStyles.space4),
      onTap: onTap,
      pressable: pressable,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent bar
          Container(
            width: 4.w,
            height: accentHeight.h,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: AppStyles.roundedFull,
            ),
          ),
          SizedBox(width: AppStyles.space3),
          // Content
          Expanded(child: content),
          // Trailing widget
          if (trailing != null) ...[
            SizedBox(width: AppStyles.space3),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Widget hiển thị số lượng (tiết, tín chỉ, etc.) - dùng chung cho các card
class DuoCountBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const DuoCountBadge({
    super.key,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space3,
        vertical: AppStyles.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(color, 0.1),
        borderRadius: AppStyles.roundedLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: AppStyles.textXl,
              fontWeight: AppStyles.fontBold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppStyles.textXs,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
