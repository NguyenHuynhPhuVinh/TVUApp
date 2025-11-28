import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style AppBar
class DuoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLogo;
  final Color? backgroundColor;
  final bool centerTitle;

  const DuoAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showLogo = true,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: titleWidget ?? _buildTitle(),
      actions: actions,
    );
  }

  Widget _buildTitle() {
    if (!showLogo && title != null) {
      return Text(
        title!,
        style: TextStyle(
          fontSize: AppStyles.textLg,
          fontWeight: AppStyles.fontBold,
          color: Colors.white,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLogo) ...[
          Container(
            padding: EdgeInsets.all(AppStyles.space1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppStyles.roundedMd,
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppColors.primary,
              size: AppStyles.iconSm,
            ),
          ),
          SizedBox(width: AppStyles.space2),
        ],
        Text(
          title ?? 'TVU App',
          style: TextStyle(
            fontSize: AppStyles.textLg,
            fontWeight: AppStyles.fontBold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Duolingo-style Back Button cho AppBar
class DuoBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;

  const DuoBackButton({super.key, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        margin: EdgeInsets.all(AppStyles.space2),
        padding: EdgeInsets.all(AppStyles.space2),
        decoration: BoxDecoration(
          color: AppColors.withAlpha(Colors.white, 0.2),
          borderRadius: AppStyles.roundedLg,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: color ?? Colors.white,
          size: AppStyles.iconSm,
        ),
      ),
    );
  }
}

