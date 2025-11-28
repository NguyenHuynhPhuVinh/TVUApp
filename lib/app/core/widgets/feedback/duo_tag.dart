import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Widget tag nhỏ với custom color - dùng cho labels, categories
class DuoTag extends StatelessWidget {
  final String text;
  final Color color;
  final double? fontSize;

  const DuoTag({
    super.key,
    required this.text,
    required this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space2, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(color, 0.1),
        borderRadius: AppStyles.roundedMd,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 10.sp,
          color: color,
          fontWeight: AppStyles.fontSemibold,
        ),
      ),
    );
  }
}
