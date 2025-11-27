import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Badge/Chip
enum DuoBadgeVariant { primary, success, warning, danger, purple, neutral }
enum DuoBadgeSize { sm, md, lg }

class DuoBadge extends StatelessWidget {
  final String text;
  final DuoBadgeVariant variant;
  final DuoBadgeSize size;
  final IconData? icon;
  final bool hasShadow;

  const DuoBadge({
    super.key,
    required this.text,
    this.variant = DuoBadgeVariant.primary,
    this.size = DuoBadgeSize.md,
    this.icon,
    this.hasShadow = false,
  });

  Color get _bgColor {
    switch (variant) {
      case DuoBadgeVariant.primary:
        return AppColors.primarySoft;
      case DuoBadgeVariant.success:
        return AppColors.greenSoft;
      case DuoBadgeVariant.warning:
        return AppColors.orangeSoft;
      case DuoBadgeVariant.danger:
        return AppColors.redSoft;
      case DuoBadgeVariant.purple:
        return AppColors.purpleSoft;
      case DuoBadgeVariant.neutral:
        return AppColors.backgroundDark;
    }
  }

  Color get _textColor {
    switch (variant) {
      case DuoBadgeVariant.primary:
        return AppColors.primaryDark;
      case DuoBadgeVariant.success:
        return AppColors.greenDark;
      case DuoBadgeVariant.warning:
        return AppColors.orangeDark;
      case DuoBadgeVariant.danger:
        return AppColors.redDark;
      case DuoBadgeVariant.purple:
        return AppColors.purpleDark;
      case DuoBadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case DuoBadgeSize.sm:
        return EdgeInsets.symmetric(
          horizontal: AppStyles.space2,
          vertical: AppStyles.space1,
        );
      case DuoBadgeSize.md:
        return EdgeInsets.symmetric(
          horizontal: AppStyles.space3,
          vertical: AppStyles.space1,
        );
      case DuoBadgeSize.lg:
        return EdgeInsets.symmetric(
          horizontal: AppStyles.space4,
          vertical: AppStyles.space2,
        );
    }
  }

  double get _fontSize {
    switch (size) {
      case DuoBadgeSize.sm:
        return AppStyles.textXs;
      case DuoBadgeSize.md:
        return AppStyles.textSm;
      case DuoBadgeSize.lg:
        return AppStyles.textBase;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppStyles.roundedFull,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: _textColor.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: _textColor, size: _fontSize + 2),
            SizedBox(width: AppStyles.space1),
          ],
          Text(
            text,
            style: TextStyle(
              color: _textColor,
              fontSize: _fontSize,
              fontWeight: AppStyles.fontSemibold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Duolingo-style Solid Badge với 3D shadow effect
class DuoSolidBadge extends StatelessWidget {
  final String text;
  final DuoBadgeVariant variant;
  final DuoBadgeSize size;
  final IconData? icon;
  final bool inverted; // true = nền trắng, text màu

  const DuoSolidBadge({
    super.key,
    required this.text,
    this.variant = DuoBadgeVariant.primary,
    this.size = DuoBadgeSize.md,
    this.icon,
    this.inverted = false,
  });

  Color get _mainColor {
    switch (variant) {
      case DuoBadgeVariant.primary:
        return AppColors.primary;
      case DuoBadgeVariant.success:
        return AppColors.green;
      case DuoBadgeVariant.warning:
        return AppColors.orange;
      case DuoBadgeVariant.danger:
        return AppColors.red;
      case DuoBadgeVariant.purple:
        return AppColors.purple;
      case DuoBadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  Color get _shadowColor {
    switch (variant) {
      case DuoBadgeVariant.primary:
        return AppColors.primaryDark;
      case DuoBadgeVariant.success:
        return AppColors.greenDark;
      case DuoBadgeVariant.warning:
        return AppColors.orangeDark;
      case DuoBadgeVariant.danger:
        return AppColors.redDark;
      case DuoBadgeVariant.purple:
        return AppColors.purpleDark;
      case DuoBadgeVariant.neutral:
        return AppColors.textPrimary;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case DuoBadgeSize.sm:
        return EdgeInsets.symmetric(
          horizontal: AppStyles.space3,
          vertical: AppStyles.space1,
        );
      case DuoBadgeSize.md:
        return EdgeInsets.symmetric(
          horizontal: AppStyles.space4,
          vertical: AppStyles.space2,
        );
      case DuoBadgeSize.lg:
        return EdgeInsets.symmetric(
          horizontal: AppStyles.space5,
          vertical: AppStyles.space2,
        );
    }
  }

  double get _fontSize {
    switch (size) {
      case DuoBadgeSize.sm:
        return AppStyles.textXs;
      case DuoBadgeSize.md:
        return AppStyles.textSm;
      case DuoBadgeSize.lg:
        return AppStyles.textBase;
    }
  }

  double get _shadowOffset {
    switch (size) {
      case DuoBadgeSize.sm:
        return 2;
      case DuoBadgeSize.md:
        return 3;
      case DuoBadgeSize.lg:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = inverted ? Colors.white : _mainColor;
    final textColor = inverted ? _mainColor : Colors.white;
    final shadow = inverted ? _shadowColor : _shadowColor;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.roundedFull,
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: Offset(0, _shadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: _fontSize + 4),
            SizedBox(width: AppStyles.space2),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: _fontSize,
              fontWeight: AppStyles.fontBold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Duolingo-style Version Badge (đặc biệt cho version)
class DuoVersionBadge extends StatelessWidget {
  final String version;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? shadowColor;

  const DuoVersionBadge({
    super.key,
    required this.version,
    this.backgroundColor,
    this.textColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: AppStyles.roundedFull,
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? AppColors.primaryDark,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            color: textColor ?? AppColors.primary,
            size: AppStyles.iconSm,
          ),
          SizedBox(width: AppStyles.space2),
          Text(
            version,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontBold,
              color: textColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
