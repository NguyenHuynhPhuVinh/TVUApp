import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style Icon Button với 3D shadow effect
enum DuoIconButtonVariant { primary, success, warning, danger, purple, white, ghost }
enum DuoIconButtonSize { sm, md, lg }

class DuoIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final DuoIconButtonVariant variant;
  final DuoIconButtonSize size;
  final bool hasBadge;
  final int badgeCount;

  const DuoIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.variant = DuoIconButtonVariant.primary,
    this.size = DuoIconButtonSize.md,
    this.hasBadge = false,
    this.badgeCount = 0,
  });

  @override
  State<DuoIconButton> createState() => _DuoIconButtonState();
}

class _DuoIconButtonState extends State<DuoIconButton> {
  bool _isPressed = false;

  Color get _bgColor {
    switch (widget.variant) {
      case DuoIconButtonVariant.primary:
        return AppColors.primary;
      case DuoIconButtonVariant.success:
        return AppColors.green;
      case DuoIconButtonVariant.warning:
        return AppColors.orange;
      case DuoIconButtonVariant.danger:
        return AppColors.red;
      case DuoIconButtonVariant.purple:
        return AppColors.purple;
      case DuoIconButtonVariant.white:
        return Colors.white;
      case DuoIconButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _shadowColor {
    switch (widget.variant) {
      case DuoIconButtonVariant.primary:
        return AppColors.primaryDark;
      case DuoIconButtonVariant.success:
        return AppColors.greenDark;
      case DuoIconButtonVariant.warning:
        return AppColors.orangeDark;
      case DuoIconButtonVariant.danger:
        return AppColors.redDark;
      case DuoIconButtonVariant.purple:
        return AppColors.purpleDark;
      case DuoIconButtonVariant.white:
        return AppColors.border;
      case DuoIconButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _iconColor {
    switch (widget.variant) {
      case DuoIconButtonVariant.white:
        return AppColors.primary;
      case DuoIconButtonVariant.ghost:
        return AppColors.textSecondary;
      default:
        return Colors.white;
    }
  }

  double get _size {
    switch (widget.size) {
      case DuoIconButtonSize.sm:
        return AppStyles.buttonSm;
      case DuoIconButtonSize.md:
        return AppStyles.buttonMd;
      case DuoIconButtonSize.lg:
        return AppStyles.buttonLg;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case DuoIconButtonSize.sm:
        return AppStyles.iconXs;
      case DuoIconButtonSize.md:
        return AppStyles.iconSm;
      case DuoIconButtonSize.lg:
        return AppStyles.iconMd;
    }
  }

  double get _shadowOffset => _isPressed ? 0 : 3;

  @override
  Widget build(BuildContext context) {
    final isGhost = widget.variant == DuoIconButtonVariant.ghost;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: AppStyles.durationFast,
            width: _size,
            height: _size,
            transform: Matrix4.translationValues(0, _isPressed ? _shadowOffset : 0, 0),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: AppStyles.roundedLg,
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
              child: Icon(widget.icon, color: _iconColor, size: _iconSize),
            ),
          ),
          if (widget.hasBadge && widget.badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: EdgeInsets.all(AppStyles.space1),
                constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: AppStyles.fontBold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

