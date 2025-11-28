import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';
import '../base/duo_button.dart';

/// Duolingo-style Empty State Widget
class DuoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const DuoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.green;
    final bgColor = iconBackgroundColor ?? AppColors.greenSoft;

    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppStyles.space5),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppStyles.icon2xl, color: color),
            ),
            SizedBox(height: AppStyles.space4),
            Text(
              title,
              style: TextStyle(
                fontSize: AppStyles.textLg,
                fontWeight: AppStyles.fontSemibold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppStyles.space2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              SizedBox(height: AppStyles.space4),
              DuoButton(
                text: actionText!,
                onPressed: onAction,
                variant: DuoButtonVariant.primary,
                size: DuoButtonSize.md,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Duolingo-style Loading State Widget
class DuoLoadingState extends StatelessWidget {
  final String? message;

  const DuoLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppStyles.space4),
            Text(
              message!,
              style: TextStyle(
                fontSize: AppStyles.textSm,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Duolingo-style Error State Widget
class DuoErrorState extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onRetry;

  const DuoErrorState({
    super.key,
    required this.message,
    this.actionText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppStyles.space4),
              decoration: BoxDecoration(
                color: AppColors.redSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: AppStyles.icon2xl,
                color: AppColors.red,
              ),
            ),
            SizedBox(height: AppStyles.space4),
            Text(
              message,
              style: TextStyle(
                fontSize: AppStyles.textBase,
                fontWeight: AppStyles.fontMedium,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppStyles.space4),
              DuoButton(
                text: actionText ?? 'Thử lại',
                onPressed: onRetry,
                variant: DuoButtonVariant.danger,
                size: DuoButtonSize.md,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

