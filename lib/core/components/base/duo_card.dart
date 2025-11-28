import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style Card với 3D shadow effect
/// Hỗ trợ cả static và pressable mode
class DuoCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? shadowOffset;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool hasBorder;

  /// Nếu true, card sẽ có hiệu ứng press (lún xuống khi nhấn)
  /// Mặc định: true nếu có onTap, false nếu không
  final bool? pressable;

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
    this.pressable,
  });

  /// Factory cho card không có hiệu ứng press
  factory DuoCard.static({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? shadowColor,
    double? shadowOffset,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    bool hasBorder = true,
  }) {
    return DuoCard(
      key: key,
      padding: padding,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      shadowOffset: shadowOffset,
      borderRadius: borderRadius,
      onTap: onTap,
      hasBorder: hasBorder,
      pressable: false,
      child: child,
    );
  }

  /// Factory cho card có hiệu ứng press
  factory DuoCard.pressable({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? shadowColor,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return DuoCard(
      key: key,
      padding: padding,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      borderRadius: borderRadius,
      onTap: onTap,
      pressable: true,
      child: child,
    );
  }

  @override
  State<DuoCard> createState() => _DuoCardState();
}

class _DuoCardState extends State<DuoCard> {
  bool _isPressed = false;

  bool get _isPressable => widget.pressable ?? (widget.onTap != null);

  @override
  Widget build(BuildContext context) {
    final effectiveShadowOffset = _isPressed ? 0.0 : (widget.shadowOffset ?? AppStyles.shadowMd);
    final translateY = _isPressed ? (widget.shadowOffset ?? AppStyles.shadowMd) : 0.0;

    Widget card = AnimatedContainer(
      duration: AppStyles.durationFast,
      padding: widget.padding ?? EdgeInsets.all(AppStyles.cardPaddingMd),
      transform: _isPressable ? Matrix4.translationValues(0, translateY, 0) : null,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.backgroundWhite,
        borderRadius: widget.borderRadius ?? AppStyles.roundedXl,
        border: widget.hasBorder
            ? Border.all(color: AppColors.border, width: AppStyles.border2)
            : null,
        boxShadow: (_isPressable && _isPressed)
            ? []
            : AppColors.cardBoxShadow(
                color: widget.shadowColor,
                offset: effectiveShadowOffset,
              ),
      ),
      child: widget.child,
    );

    if (_isPressable) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: card,
      );
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: card,
      );
    }

    return card;
  }
}


