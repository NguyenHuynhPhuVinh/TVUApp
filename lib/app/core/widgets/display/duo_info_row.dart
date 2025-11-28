import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Widget hiển thị một dòng thông tin với icon và text
/// Dùng cho schedule info, location, teacher, v.v.
class DuoInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final double? fontSize;

  const DuoInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize ?? AppStyles.iconXs,
          color: iconColor ?? AppColors.textTertiary,
        ),
        SizedBox(width: AppStyles.space2),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? AppStyles.textSm,
              color: textColor ?? AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
