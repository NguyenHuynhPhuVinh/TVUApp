import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Button với 3D shadow effect
enum DuoButtonVariant { primary, success, warning, danger, purple, ghost }
enum DuoButtonSize { sm, md, lg, xl }

class DuoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final DuoButtonVariant variant;
  final DuoButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  const DuoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = DuoButtonVariant.primary,
    this.size = DuoButtonSize.lg,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  Color get _bgColor {
    if (widget.isDisabled) return AppColors.textDisabled;
    switch (widget.variant) {
      case DuoButtonVariant.primary:
        return AppColors.primary;
      case DuoButtonVariant.success:
        return AppColors.green;
      case DuoButtonVariant.warning:
        return AppColors.orange;
      case DuoButtonVariant.danger:
        return AppColors.red;
      case DuoButtonVariant.purple:
        return AppColors.purple;
      case DuoButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _shadowColor {
    if (widget.isDisabled) return AppColors.border;
    switch (widget.variant) {
      case DuoButtonVariant.primary:
        return AppColors.primaryDark;
      case DuoButtonVariant.success:
        return AppColors.greenDark;
      case DuoButtonVariant.warning:
        return AppColors.orangeDark;
      case DuoButtonVariant.danger:
        return AppColors.redDark;
      case DuoButtonVariant.purple:
        return AppColors.purpleDark;
      case DuoButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    if (widget.variant == DuoButtonVariant.ghost) {
      return AppColors.primary;
    }
    return Colors.white;
  }

  double get _height {
    switch (widget.size) {
      case DuoButtonSize.sm:
        return AppStyles.buttonSm;
      case DuoButtonSize.md:
        return AppStyles.buttonMd;
      case DuoButtonSize.lg:
        return AppStyles.buttonLg;
      case DuoButtonSize.xl:
        return AppStyles.buttonXl;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case DuoButtonSize.sm:
        return AppStyles.textSm;
      case DuoButtonSize.md:
        return AppStyles.textBase;
      case DuoButtonSize.lg:
        return AppStyles.textLg;
      case DuoButtonSize.xl:
        return AppStyles.textLg;
    }
  }

  double get _shadowOffset => _isPressed ? 0 : AppStyles.shadowLg;

  @override
  Widget build(BuildContext context) {
    final isGhost = widget.variant == DuoButtonVariant.ghost;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isDisabled && !widget.isLoading) {
          widget.onPressed?.call();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppStyles.durationFast,
        width: widget.fullWidth ? double.infinity : null,
        height: _height,
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space6),
        transform: Matrix4.translationValues(0, _isPressed ? _shadowOffset : 0, 0),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: AppStyles.roundedXl,
          border: isGhost ? Border.all(color: AppColors.border, width: AppStyles.border2) : null,
          boxShadow: isGhost || _isPressed
              ? []
              : [
                  BoxShadow(
                    color: _shadowColor,
                    offset: Offset(0, _shadowOffset),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: widget.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                      ),
                    ),
                    SizedBox(width: AppStyles.space3),
                    Text(
                      'Đang xử lý...',
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: AppStyles.fontBold,
                        color: _textColor,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: _textColor, size: _fontSize + 4),
                      SizedBox(width: AppStyles.space2),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: AppStyles.fontBold,
                        color: _textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
