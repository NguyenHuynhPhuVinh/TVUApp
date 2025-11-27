import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Number Input - input số với style game
class DuoNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final int? maxValue;
  final ValueChanged<String>? onChanged;

  const DuoNumberInput({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.maxValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.purple;

    return Container(
      padding: EdgeInsets.all(AppStyles.space5),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.rounded2xl,
        border: Border.all(color: AppColors.border, width: AppStyles.border2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (label != null || icon != null)
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(AppStyles.space2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: AppStyles.roundedLg,
                    ),
                    child: Icon(icon, color: color, size: 24.w),
                  ),
                  SizedBox(width: AppStyles.space3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (label != null)
                        Text(
                          label!,
                          style: TextStyle(
                            fontSize: AppStyles.textLg,
                            fontWeight: AppStyles.fontBold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: AppStyles.textSm,
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

          if (label != null || icon != null) SizedBox(height: AppStyles.space4),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppStyles.roundedXl,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: AppStyles.border2,
              ),
            ),
            child: Row(
              children: [
                // Decrease button
                _buildStepButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _adjustValue(-1),
                  color: color,
                ),
                // Input
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    onChanged: onChanged,
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hint ?? '0',
                      hintStyle: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.textDisabled,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: AppStyles.space4,
                      ),
                    ),
                  ),
                ),
                // Increase button
                _buildStepButton(
                  icon: Icons.add_rounded,
                  onTap: () => _adjustValue(1),
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.w,
        margin: EdgeInsets.all(AppStyles.space2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppStyles.roundedLg,
        ),
        child: Icon(icon, color: color, size: 28.w),
      ),
    );
  }

  void _adjustValue(int delta) {
    final current = int.tryParse(controller.text) ?? 0;
    var newValue = current + delta;

    if (newValue < 0) newValue = 0;
    if (maxValue != null && newValue > maxValue!) newValue = maxValue!;

    controller.text = newValue.toString();
    onChanged?.call(newValue.toString());
  }
}
