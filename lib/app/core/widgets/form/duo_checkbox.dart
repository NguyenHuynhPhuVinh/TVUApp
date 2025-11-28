import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Checkbox widget theo style Duolingo
class DuoCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final String? labelText;
  final Color? activeColor;
  final bool enabled;

  const DuoCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.labelText,
    this.activeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;

    return GestureDetector(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppStyles.durationFast,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? color : AppColors.backgroundWhite,
              borderRadius: AppStyles.roundedMd,
              border: Border.all(
                color: value ? color : AppColors.border,
                width: 2,
              ),
              boxShadow: value ? AppColors.glowEffect(color, blur: 4, spread: 0) : null,
            ),
            child: value
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.backgroundWhite,
                  )
                : null,
          ),
          if (label != null || labelText != null) ...[
            SizedBox(width: AppStyles.space2),
            Flexible(
              child: label ??
                  Text(
                    labelText!,
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
                    ),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
