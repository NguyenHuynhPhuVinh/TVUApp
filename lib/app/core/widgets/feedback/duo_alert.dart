import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style Alert/Message Box
enum DuoAlertVariant { info, success, warning, error }

class DuoAlert extends StatelessWidget {
  final String message;
  final DuoAlertVariant variant;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final bool animated;

  const DuoAlert({
    super.key,
    required this.message,
    this.variant = DuoAlertVariant.info,
    this.icon,
    this.onDismiss,
    this.animated = true,
  });

  Color get _bgColor {
    switch (variant) {
      case DuoAlertVariant.info:
        return AppColors.primarySoft;
      case DuoAlertVariant.success:
        return AppColors.greenSoft;
      case DuoAlertVariant.warning:
        return AppColors.orangeSoft;
      case DuoAlertVariant.error:
        return AppColors.redSoft;
    }
  }

  Color get _borderColor {
    switch (variant) {
      case DuoAlertVariant.info:
        return AppColors.primary;
      case DuoAlertVariant.success:
        return AppColors.green;
      case DuoAlertVariant.warning:
        return AppColors.orange;
      case DuoAlertVariant.error:
        return AppColors.red;
    }
  }

  Color get _iconBgColor {
    switch (variant) {
      case DuoAlertVariant.info:
        return AppColors.withAlpha(AppColors.primary, 0.2);
      case DuoAlertVariant.success:
        return AppColors.withAlpha(AppColors.green, 0.2);
      case DuoAlertVariant.warning:
        return AppColors.withAlpha(AppColors.orange, 0.2);
      case DuoAlertVariant.error:
        return AppColors.withAlpha(AppColors.red, 0.2);
    }
  }

  IconData get _defaultIcon {
    switch (variant) {
      case DuoAlertVariant.info:
        return Icons.info_outline_rounded;
      case DuoAlertVariant.success:
        return Icons.check_circle_outline_rounded;
      case DuoAlertVariant.warning:
        return Icons.warning_amber_rounded;
      case DuoAlertVariant.error:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget alert = Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(
          color: AppColors.withAlpha(_borderColor, 0.3),
          width: AppStyles.border2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: _iconBgColor,
              borderRadius: AppStyles.roundedLg,
            ),
            child: Icon(
              icon ?? _defaultIcon,
              color: _borderColor,
              size: AppStyles.iconSm,
            ),
          ),
          SizedBox(width: AppStyles.space3),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _borderColor,
                fontSize: AppStyles.textSm,
                fontWeight: AppStyles.fontSemibold,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: _borderColor,
                size: AppStyles.iconSm,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );

    if (animated) {
      alert = alert
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1))
          .then()
          .shakeX(hz: 3, amount: variant == DuoAlertVariant.error ? 4 : 0, duration: 400.ms);
    }

    return alert;
  }
}

/// Duolingo-style Toast/Snackbar helper
class DuoToast {
  static void show(
    BuildContext context, {
    required String message,
    DuoAlertVariant variant = DuoAlertVariant.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + AppStyles.space4,
        left: AppStyles.space4,
        right: AppStyles.space4,
        child: Material(
          color: Colors.transparent,
          child: DuoAlert(
            message: message,
            variant: variant,
            onDismiss: () => entry.remove(),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  }
}

