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

  /// Số thư có thể xóa (đã đọc + đã nhận quà nếu có)
  int get deletableCount =>
      mails.where((m) => m.isRead && (!m.hasReward || m.isClaimed)).length;

  /// Có thư chưa đọc (không tính thư có quà chưa nhận)
  bool get hasUnreadWithoutReward =>
      mails.any((m) => !m.isRead && !m.canClaimReward);

  /// Đánh dấu đã đọc
  Future<void> markAsRead(MailItem mail) async {
    if (mail.isRead) return;
    await _mailboxService.markAsRead(mail.id);
  }

  /// Nhận quà từ thư - trả về bool để sheet biết kết quả
  Future<bool> claimReward(MailItem mail) async {
    if (!mail.canClaimReward) return false;

    try {
      final success = await _mailboxService.claimReward(mail.id);
      return success;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể nhận quà. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Nhận tất cả quà
  Future<void> claimAllRewards() async {
    if (unclaimedCount == 0 || isClaimingAll.value) return;

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

    try {
      final count = await _mailboxService.claimAllRewards();

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

  /// Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;
    await _mailboxService.markAllAsRead();
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

  /// Xóa tất cả thư đã đọc (và đã nhận quà nếu có)
  Future<void> deleteReadMails() async {
    final count = await _mailboxService.deleteReadMails();
    if (count > 0) {
      Get.snackbar(
        'Thành công',
        'Đã xóa $count thư',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Thông báo',
        'Không có thư nào để xóa',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    }
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
