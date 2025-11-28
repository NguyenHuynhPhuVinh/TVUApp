import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_button.dart';

/// Dialog hiển thị khi có phiên bản mới (bắt buộc cập nhật)
class DuoUpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final bool isDownloading;
  final double downloadProgress;
  final VoidCallback onUpdate;

  const DuoUpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    required this.onUpdate,
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
            // Icon
            Container(
              width: AppStyles.icon3xl,
              height: AppStyles.icon3xl,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: AppColors.green,
                size: AppStyles.iconXl,
              ),
            ),
            SizedBox(height: AppStyles.space4),

            // Title
            Text(
              'Có phiên bản mới!',
              style: TextStyle(
                fontSize: AppStyles.textXl,
                fontWeight: AppStyles.fontBold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppStyles.space2),

            // Version info
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppStyles.space3,
                vertical: AppStyles.space1,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: AppStyles.roundedFull,
              ),
              child: Text(
                '$currentVersion → $latestVersion',
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  fontWeight: AppStyles.fontSemibold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppStyles.space4),

            // Nút xem changelog
            if (releaseNotes.isNotEmpty)
              TextButton.icon(
                onPressed: () => _showChangelogDialog(releaseNotes),
                icon: Icon(
                  Icons.description_outlined,
                  size: AppStyles.iconSm,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Xem thay đổi',
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    color: AppColors.primary,
                    fontWeight: AppStyles.fontMedium,
                  ),
                ),
              ),
            SizedBox(height: AppStyles.space2),

            // Download progress
            if (isDownloading) ...[
              Column(
                children: [
                  ClipRRect(
                    borderRadius: AppStyles.roundedFull,
                    child: LinearProgressIndicator(
                      value: downloadProgress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(AppColors.green),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: AppStyles.space2),
                  Text(
                    'Đang tải... ${(downloadProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Thông báo bắt buộc
              Container(
                padding: EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: AppColors.orangeSoft,
                  borderRadius: AppStyles.roundedLg,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.orange,
                      size: AppStyles.iconSm,
                    ),
                    SizedBox(width: AppStyles.space2),
                    Expanded(
                      child: Text(
                        'Bạn cần cập nhật để tiếp tục sử dụng',
                        style: TextStyle(
                          fontSize: AppStyles.textSm,
                          color: AppColors.orangeDark,
                          fontWeight: AppStyles.fontMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppStyles.space4),
              // Buttons - xếp dọc
              DuoButton(
                text: 'Cập nhật ngay',
                onPressed: onUpdate,
                variant: DuoButtonVariant.success,
              ),
              SizedBox(height: AppStyles.space3),
              DuoButton(
                text: 'Thoát ứng dụng',
                onPressed: _exitApp,
                variant: DuoButtonVariant.ghost,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Thoát app
  static void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  /// Hiển thị dialog changelog
  static void _showChangelogDialog(String releaseNotes) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.rounded2xl),
        child: Padding(
          padding: EdgeInsets.all(AppStyles.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: AppColors.primary,
                    size: AppStyles.iconMd,
                  ),
                  SizedBox(width: AppStyles.space2),
                  Text(
                    'Có gì mới?',
                    style: TextStyle(
                      fontSize: AppStyles.textLg,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: AppStyles.iconMd,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppStyles.space4),
              Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Text(
                    releaseNotes,
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: AppColors.textSecondary,
                      height: AppStyles.leadingRelaxed,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppStyles.space4),
              DuoButton(
                text: 'Đóng',
                onPressed: () => Get.back(),
                variant: DuoButtonVariant.primary,
                size: DuoButtonSize.md,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hiển thị dialog (bắt buộc cập nhật)
  static Future<void> show({
    required String currentVersion,
    required String latestVersion,
    required String releaseNotes,
    required RxBool isDownloading,
    required RxDouble downloadProgress,
    required VoidCallback onUpdate,
  }) {
    return Get.dialog(
      PopScope(
        canPop: false,
        child: Obx(() => DuoUpdateDialog(
              currentVersion: currentVersion,
              latestVersion: latestVersion,
              releaseNotes: releaseNotes,
              isDownloading: isDownloading.value,
              downloadProgress: downloadProgress.value,
              onUpdate: onUpdate,
            )),
      ),
      barrierDismissible: false,
    );
  }
}
