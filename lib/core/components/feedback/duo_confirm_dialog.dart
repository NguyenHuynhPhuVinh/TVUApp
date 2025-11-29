import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../widgets.dart';

/// Dialog xác nhận style game
class DuoConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final DuoButtonVariant confirmVariant;

  const DuoConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Xác nhận',
    this.cancelText = 'Hủy',
    this.icon = Icons.warning_rounded,
    this.iconColor = AppColors.orange,
    this.iconBackgroundColor = AppColors.orangeSoft,
    this.onConfirm,
    this.onCancel,
    this.confirmVariant = DuoButtonVariant.danger,
  });

  /// Show dialog xác nhận xóa
  static Future<bool> showDelete({
    required String title,
    required String message,
    String confirmText = 'Xóa',
    String cancelText = 'Hủy',
  }) async {
    final result = await Get.dialog<bool>(
      DuoConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: Icons.delete_forever_rounded,
        iconColor: AppColors.red,
        iconBackgroundColor: AppColors.redSoft,
        confirmVariant: DuoButtonVariant.danger,
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  /// Show dialog xác nhận chung
  static Future<bool> show({
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    IconData icon = Icons.help_outline_rounded,
    Color iconColor = AppColors.primary,
    Color? iconBackgroundColor,
    DuoButtonVariant confirmVariant = DuoButtonVariant.primary,
  }) async {
    final result = await Get.dialog<bool>(
      DuoConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor ?? iconColor.withValues(alpha: 0.15),
        confirmVariant: confirmVariant,
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppStyles.space5),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppStyles.rounded2xl,
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            SizedBox(height: AppStyles.space4),
            _buildTitle(),
            SizedBox(height: AppStyles.space2),
            _buildMessage(),
            SizedBox(height: AppStyles.space5),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 36.w,
        color: iconColor,
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppStyles.textXl,
        fontWeight: AppStyles.fontBold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildMessage() {
    return Text(
      message,
      style: TextStyle(
        fontSize: AppStyles.textSm,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DuoButton(
            text: cancelText,
            variant: DuoButtonVariant.ghost,
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
          ),
        ),
        SizedBox(width: AppStyles.space3),
        Expanded(
          child: DuoButton(
            text: confirmText,
            variant: confirmVariant,
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }
}
