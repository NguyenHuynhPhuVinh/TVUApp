import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Card với 3D shadow effect
class DuoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? shadowOffset;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool hasBorder;

  const DuoCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.shadowColor,
    this.shadowOffset,
    this.borderRadius,
    this.onTap,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(AppStyles.cardPaddingMd),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.backgroundWhite,
          borderRadius: borderRadius ?? AppStyles.roundedXl,
          border: hasBorder
              ? Border.all(color: AppColors.border, width: AppStyles.border2)
              : null,
          boxShadow: AppColors.cardBoxShadow(
            color: shadowColor,
            offset: shadowOffset ?? AppStyles.shadowMd,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Duolingo-style Card có thể nhấn với hiệu ứng press
class DuoPressableCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? shadowColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const DuoPressableCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.shadowColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<DuoPressableCard> createState() => _DuoPressableCardState();
}

class _DuoPressableCardState extends State<DuoPressableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadowOffset = _isPressed ? 0.0 : AppStyles.shadowMd;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppStyles.durationFast,
        padding: widget.padding ?? EdgeInsets.all(AppStyles.cardPaddingMd),
        transform: Matrix4.translationValues(0, _isPressed ? AppStyles.shadowMd : 0, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.backgroundWhite,
          borderRadius: widget.borderRadius ?? AppStyles.roundedXl,
          border: Border.all(color: AppColors.border, width: AppStyles.border2),
          boxShadow: _isPressed
              ? []
              : AppColors.cardBoxShadow(
                  color: widget.shadowColor,
                  offset: shadowOffset,
                ),
        ),
        child: widget.child,
      ),
    );
  }
}
