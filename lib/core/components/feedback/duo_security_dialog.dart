import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_button.dart';

/// Dialog cảnh báo thiết bị không an toàn
class DuoSecurityDialog extends StatelessWidget {
  final List<String> issues;

  const DuoSecurityDialog({
    super.key,
    required this.issues,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundWhite,
      shape: RoundedRectangleBorder(borderRadius: AppStyles.rounded2xl),
      child: Padding(
        padding: EdgeInsets.all(AppStyles.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon cảnh báo
            Container(
              width: AppStyles.icon3xl,
              height: AppStyles.icon3xl,
              decoration: BoxDecoration(
                color: AppColors.redSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                color: AppColors.red,
                size: AppStyles.iconXl,
              ),
            ),
            SizedBox(height: AppStyles.space4),

            // Title
            Text(
              'Thiết bị không an toàn',
              style: TextStyle(
                fontSize: AppStyles.textXl,
                fontWeight: AppStyles.fontBold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppStyles.space3),

            // Mô tả
            Text(
              'Ứng dụng không thể chạy trên thiết bị này vì lý do bảo mật.',
              style: TextStyle(
                fontSize: AppStyles.textSm,
                color: AppColors.textSecondary,
                height: AppStyles.leadingRelaxed,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppStyles.space4),

            // Danh sách vấn đề
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppStyles.space3),
              decoration: BoxDecoration(
                color: AppColors.redSoft,
                borderRadius: AppStyles.roundedLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phát hiện:',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      fontWeight: AppStyles.fontSemibold,
                      color: AppColors.red,
                    ),
                  ),
                  SizedBox(height: AppStyles.space2),
                  ...issues.map(
                    (issue) => Padding(
                      padding: EdgeInsets.only(bottom: AppStyles.space1),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.red,
                            size: AppStyles.iconXs,
                          ),
                          SizedBox(width: AppStyles.space2),
                          Expanded(
                            child: Text(
                              issue,
                              style: TextStyle(
                                fontSize: AppStyles.textSm,
                                color: AppColors.redDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppStyles.space4),

            // Nút thoát
            DuoButton(
              text: 'Thoát ứng dụng',
              onPressed: _exitApp,
              variant: DuoButtonVariant.danger,
            ),
          ],
        ),
      ),
    );
  }

  static void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  /// Hiển thị dialog (không thể đóng)
  static Future<void> show(List<String> issues) {
    return Get.dialog(
      PopScope(
        canPop: false,
        child: DuoSecurityDialog(issues: issues),
      ),
      barrierDismissible: false,
    );
  }
}
