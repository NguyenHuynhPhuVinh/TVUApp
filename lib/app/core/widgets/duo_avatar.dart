import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Avatar với border và shadow
enum DuoAvatarSize { sm, md, lg, xl, xxl, xxxl }

class DuoAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String? text;
  final DuoAvatarSize size;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool hasShadow;
  final VoidCallback? onTap;

  const DuoAvatar({
    super.key,
    this.imageUrl,
    this.icon,
    this.text,
    this.size = DuoAvatarSize.md,
    this.backgroundColor,
    this.borderColor,
    this.hasShadow = true,
    this.onTap,
  });

  double get _size {
    switch (size) {
      case DuoAvatarSize.sm:
        return AppStyles.avatarSm;
      case DuoAvatarSize.md:
        return AppStyles.avatarMd;
      case DuoAvatarSize.lg:
        return AppStyles.avatarLg;
      case DuoAvatarSize.xl:
        return AppStyles.avatarXl;
      case DuoAvatarSize.xxl:
        return AppStyles.avatar2xl;
      case DuoAvatarSize.xxxl:
        return AppStyles.avatar3xl;
    }
  }

  double get _borderWidth {
    switch (size) {
      case DuoAvatarSize.sm:
      case DuoAvatarSize.md:
        return AppStyles.border2;
      case DuoAvatarSize.lg:
      case DuoAvatarSize.xl:
        return AppStyles.border3;
      case DuoAvatarSize.xxl:
      case DuoAvatarSize.xxxl:
        return AppStyles.border4;
    }
  }

  double get _iconSize {
    switch (size) {
      case DuoAvatarSize.sm:
        return AppStyles.iconXs;
      case DuoAvatarSize.md:
        return AppStyles.iconSm;
      case DuoAvatarSize.lg:
        return AppStyles.iconMd;
      case DuoAvatarSize.xl:
        return AppStyles.iconLg;
      case DuoAvatarSize.xxl:
        return AppStyles.icon2xl;
      case DuoAvatarSize.xxxl:
        return AppStyles.icon3xl;
    }
  }

  double get _fontSize {
    switch (size) {
      case DuoAvatarSize.sm:
        return AppStyles.textSm;
      case DuoAvatarSize.md:
        return AppStyles.textBase;
      case DuoAvatarSize.lg:
        return AppStyles.textLg;
      case DuoAvatarSize.xl:
        return AppStyles.textXl;
      case DuoAvatarSize.xxl:
        return AppStyles.text2xl;
      case DuoAvatarSize.xxxl:
        return AppStyles.text4xl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final border = borderColor ?? AppColors.primaryDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: _borderWidth),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: border,
                    offset: Offset(0, AppStyles.shadowMd),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    if (icon != null) {
      return Center(
        child: Icon(icon, color: Colors.white, size: _iconSize),
      );
    }
    if (text != null) {
      return Center(
        child: Text(
          text!.substring(0, text!.length > 2 ? 2 : text!.length).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: _fontSize,
            fontWeight: AppStyles.fontBold,
          ),
        ),
      );
    }
    return Center(
      child: Icon(Icons.person, color: Colors.white, size: _iconSize),
    );
  }
}
