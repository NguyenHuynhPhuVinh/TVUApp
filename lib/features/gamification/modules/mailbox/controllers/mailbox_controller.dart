import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/mail_item.dart';
import '../services/mailbox_service.dart';
import '../widgets/duo_mail_reward_dialog.dart';

class MailboxController extends GetxController {
  final MailboxService _mailboxService = Get.find<MailboxService>();

  // Observables
  final selectedFilter = MailType.system.obs;
  final isLoading = false.obs;
  final isClaimingAll = false.obs;

  // Getters
  List<MailItem> get mails => _mailboxService.mails;
  int get unreadCount => _mailboxService.unreadCount.value;
  int get unclaimedCount => _mailboxService.unclaimedCount.value;
  bool get hasNewMail => _mailboxService.hasNewMail;

  /// Đánh dấu đã đọc
  Future<void> markAsRead(MailItem mail) async {
    if (mail.isRead) return;
    await _mailboxService.markAsRead(mail.id);
  }

  /// Nhận quà từ thư
  Future<void> claimReward(MailItem mail) async {
    if (!mail.canClaimReward) return;

    isLoading.value = true;
    
    // Hiện loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.yellow),
      ),
      barrierDismissible: false,
    );

    try {
      final success = await _mailboxService.claimReward(mail.id);
      Get.back(); // Đóng loading
      
      if (success) {
        // Hiện reward dialog
        await DuoMailRewardDialog.show(
          title: mail.title,
          reward: mail.reward!,
        );
      }
    } catch (e) {
      Get.back(); // Đóng loading
      Get.snackbar(
        'Lỗi',
        'Không thể nhận quà. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Nhận tất cả quà
  Future<void> claimAllRewards() async {
    if (unclaimedCount == 0) {
      Get.snackbar(
        'Thông báo',
        'Không có quà để nhận',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
      return;
    }

    isClaimingAll.value = true;
    
    // Tính tổng phần thưởng trước
    int totalCoins = 0;
    int totalDiamonds = 0;
    int totalXp = 0;
    for (var mail in mails) {
      if (mail.canClaimReward && mail.reward != null) {
        totalCoins += mail.reward!.coins;
        totalDiamonds += mail.reward!.diamonds;
        totalXp += mail.reward!.xp;
      }
    }

    // Hiện loading dialog
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.yellow),
              const SizedBox(height: 16),
              Text(
                'Đang nhận $unclaimedCount phần quà...',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final count = await _mailboxService.claimAllRewards();
      Get.back(); // Đóng loading
      
      if (count > 0) {
        // Hiện reward dialog
        await DuoMailRewardDialog.showBulk(
          count: count,
          totalCoins: totalCoins,
          totalDiamonds: totalDiamonds,
          totalXp: totalXp,
        );
      }
    } catch (e) {
      Get.back(); // Đóng loading
      Get.snackbar(
        'Lỗi',
        'Không thể nhận quà. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
    } finally {
      isClaimingAll.value = false;
    }
  }

  /// Xóa thư
  Future<void> deleteMail(MailItem mail) async {
    if (mail.canClaimReward) {
      Get.snackbar(
        'Cảnh báo',
        'Hãy nhận quà trước khi xóa thư',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.orange,
        colorText: Colors.white,
      );
      return;
    }

    await _mailboxService.deleteMail(mail.id);
  }

  /// Lấy màu theo loại thư
  Color getMailTypeColor(MailType type) {
    switch (type) {
      case MailType.system:
        return AppColors.primary;
      case MailType.reward:
        return AppColors.yellow;
      case MailType.event:
        return AppColors.orange;
      case MailType.welcome:
        return AppColors.green;
      case MailType.update:
        return AppColors.purple;
    }
  }

  /// Làm mới danh sách thư từ Firebase
  Future<void> refreshMails() async {
    isLoading.value = true;
    try {
      await _mailboxService.syncFromFirebase();
    } finally {
      isLoading.value = false;
    }
  }
}
