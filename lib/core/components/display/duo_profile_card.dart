import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style Profile Header Card
class DuoProfileHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? email;
  final Widget? avatar;
  final Color? backgroundColor;
  final Color? shadowColor;

  const DuoProfileHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.email,
    this.avatar,
    this.backgroundColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final shadow = shadowColor ?? AppColors.primaryDark;

    return Container(
      padding: EdgeInsets.all(AppStyles.space6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.rounded2xl,
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          avatar ??
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.withAlpha(Colors.white, 0.3), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.withAlpha(shadow, 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(Icons.person_rounded, size: 48.sp, color: bgColor),
              ),
          SizedBox(height: AppStyles.space4),
          Text(
            name,
            style: TextStyle(
              fontSize: AppStyles.text2xl,
              fontWeight: AppStyles.fontBold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppStyles.space2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppStyles.space4, vertical: AppStyles.space2),
            decoration: BoxDecoration(
              color: AppColors.withAlpha(Colors.white, 0.2),
              borderRadius: AppStyles.roundedFull,
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: AppStyles.textSm,
                fontWeight: AppStyles.fontSemibold,
                color: Colors.white,
              ),
            ),
          ),
          if (email != null && email!.isNotEmpty) ...[
            SizedBox(height: AppStyles.space2),
            Text(
              email!,
              style: TextStyle(
                fontSize: AppStyles.textSm,
                color: AppColors.withAlpha(Colors.white, 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Duolingo-style Info Section
class DuoInfoSection extends StatelessWidget {
  final String title;
  final List<DuoInfoItem> items;
  final IconData? titleIcon;

  const DuoInfoSection({
    super.key,
    required this.title,
    required this.items,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border, width: AppStyles.border2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon != null) ...[
                Container(
                  padding: EdgeInsets.all(AppStyles.space2),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: AppStyles.roundedLg,
                  ),
                  child: Icon(titleIcon, size: AppStyles.iconSm, color: AppColors.primary),
                ),
                SizedBox(width: AppStyles.space3),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: AppStyles.textLg,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space4),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                _buildInfoRow(entry.value),
                if (!isLast) SizedBox(height: AppStyles.space3),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(DuoInfoItem item) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColors.withAlpha(item.iconColor ?? AppColors.primary, 0.1),
            borderRadius: AppStyles.roundedLg,
          ),
          child: Icon(
            item.icon,
            size: AppStyles.iconSm,
            color: item.iconColor ?? AppColors.primary,
          ),
        ),
        SizedBox(width: AppStyles.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: AppStyles.textXs,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  fontWeight: AppStyles.fontMedium,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DuoInfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const DuoInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });
}

/// Duolingo-style Menu Item
class DuoMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isDestructive;
  final Widget? trailing;

  const DuoMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  State<DuoMenuItem> createState() => _DuoMenuItemState();
}

class _DuoMenuItemState extends State<DuoMenuItem> {
  bool _isPressed = false;

  Color get _color {
    if (widget.isDestructive) return AppColors.red;
    return widget.iconColor ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppStyles.durationFast,
        padding: EdgeInsets.all(AppStyles.space4),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppStyles.roundedXl,
          border: Border.all(
            color: widget.isDestructive ? AppColors.withAlpha(AppColors.red, 0.3) : AppColors.border,
            width: AppStyles.border2,
          ),
          boxShadow: _isPressed ? [] : AppColors.cardBoxShadow(),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppStyles.space3),
              decoration: BoxDecoration(
                color: AppColors.withAlpha(_color, 0.1),
                borderRadius: AppStyles.roundedLg,
              ),
              child: Icon(widget.icon, size: AppStyles.iconMd, color: _color),
            ),
            SizedBox(width: AppStyles.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: AppStyles.textBase,
                      fontWeight: AppStyles.fontSemibold,
                      color: widget.isDestructive ? AppColors.red : AppColors.textPrimary,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            widget.trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: AppStyles.iconMd,
                ),
          ],
        ),
      ),
    );
  }
}

