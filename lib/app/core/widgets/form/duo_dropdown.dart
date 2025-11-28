import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style Dropdown
class DuoDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DuoDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Color? iconColor;

  const DuoDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border, width: AppStyles.border2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: color,
            fontWeight: AppStyles.fontSemibold,
          ),
          prefixIcon: prefixIcon != null
              ? Container(
                  margin: EdgeInsets.all(AppStyles.space3),
                  padding: EdgeInsets.all(AppStyles.space2),
                  decoration: BoxDecoration(
                    color: AppColors.withAlpha(color, 0.1),
                    borderRadius: AppStyles.roundedLg,
                  ),
                  child: Icon(prefixIcon, color: color, size: AppStyles.iconSm),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppStyles.space4,
            vertical: AppStyles.space3,
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
        isExpanded: true,
        dropdownColor: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        style: TextStyle(
          fontSize: AppStyles.textBase,
          fontWeight: AppStyles.fontSemibold,
          color: AppColors.textPrimary,
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item.value,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: AppStyles.textBase,
                fontWeight: item.isHighlighted ? AppStyles.fontBold : AppStyles.fontMedium,
                color: item.isHighlighted ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class DuoDropdownItem<T> {
  final T value;
  final String label;
  final bool isHighlighted;

  const DuoDropdownItem({
    required this.value,
    required this.label,
    this.isHighlighted = false,
  });
}

