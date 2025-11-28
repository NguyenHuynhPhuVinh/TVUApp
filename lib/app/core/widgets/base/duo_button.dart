import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

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

  Widget _buildButtonContent() {
    return widget.isLoading
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
              Flexible(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: AppStyles.fontBold,
                    color: _textColor,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );
  }

  Widget _buildStackButton(double shadowHeight) {
    return Stack(
      children: [
        // Shadow layer (bottom)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: _height,
            decoration: BoxDecoration(
              color: _shadowColor,
              borderRadius: AppStyles.roundedXl,
            ),
          ),
        ),
        // Button layer (top) - moves down when pressed
        Positioned(
          left: 0,
          right: 0,
          top: _isPressed ? shadowHeight : 0,
          child: Container(
            height: _height,
            padding: EdgeInsets.symmetric(horizontal: AppStyles.space6),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: AppStyles.roundedXl,
            ),
            child: Center(child: _buildButtonContent()),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGhost = widget.variant == DuoButtonVariant.ghost;
    final shadowHeight = AppStyles.shadowLg;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isDisabled && !widget.isLoading) {
          widget.onPressed?.call();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      // Ghost button - không có shadow, không lún
      child: isGhost
          ? Container(
              width: widget.fullWidth ? double.infinity : null,
              height: _height,
              padding: EdgeInsets.symmetric(horizontal: AppStyles.space6),
              decoration: BoxDecoration(
                color: _isPressed ? AppColors.background : Colors.transparent,
                borderRadius: AppStyles.roundedXl,
                border: Border.all(
                  color: AppColors.border,
                  width: AppStyles.border2,
                ),
              ),
              child: Center(child: _buildButtonContent()),
            )
          // Normal button - có shadow, lún khi bấm
          : widget.fullWidth
              ? SizedBox(
                  width: double.infinity,
                  height: _height + shadowHeight,
                  child: _buildStackButton(shadowHeight),
                )
              : IntrinsicWidth(
                  child: SizedBox(
                    height: _height + shadowHeight,
                    child: _buildStackButton(shadowHeight),
                  ),
                ),
    );
  }
}
