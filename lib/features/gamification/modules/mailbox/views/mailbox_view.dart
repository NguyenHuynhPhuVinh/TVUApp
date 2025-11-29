import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/components/widgets.dart';
import '../../../../../core/extensions/animation_extensions.dart';
import '../controllers/mailbox_controller.dart';
import '../models/mail_item.dart';
import '../widgets/duo_mail_card.dart';
import '../widgets/duo_mail_detail_sheet.dart';

class MailboxView extends GetView<MailboxController> {
  const MailboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Hòm thư',
        showLogo: false,
        leading: const DuoBackButton(),
        actions: [
          Obx(() {
            // Nếu có quà chưa nhận → chỉ hiện nút "Nhận tất cả"
            if (controller.unclaimedCount > 0) {
              final isLoading = controller.isClaimingAll.value;
              return Padding(
                padding: EdgeInsets.only(right: AppStyles.space2),
                child: GestureDetector(
                  onTap: isLoading ? null : controller.claimAllRewards,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppStyles.space3,
                      vertical: AppStyles.space2,
                    ),
                    decoration: BoxDecoration(
                      color: isLoading ? AppColors.yellowDark : AppColors.yellow,
                      borderRadius: AppStyles.roundedLg,
                      boxShadow: AppColors.buttonBoxShadow(AppColors.yellowDark, offset: 3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          Image.asset(AppAssets.giftPurple, width: 16, height: 16),
                        SizedBox(width: AppStyles.space1),
                        Text(
                          isLoading ? 'Đang nhận...' : 'Nhận tất cả',
                          style: TextStyle(
                            fontSize: AppStyles.textSm,
                            fontWeight: AppStyles.fontBold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Không có quà → hiện 3 nút: đọc full, refresh, xóa
            final canMarkRead = controller.hasUnreadWithoutReward;
            final canDelete = controller.deletableCount > 0;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút đọc tất cả (mờ khi không còn thư chưa đọc)
                Opacity(
                  opacity: canMarkRead ? 1.0 : 0.4,
                  child: DuoIconButton(
                    icon: Icons.done_all_rounded,
                    variant: DuoIconButtonVariant.white,
                    size: DuoIconButtonSize.md,
                    onTap: canMarkRead ? controller.markAllAsRead : null,
                  ),
                ),
                SizedBox(width: AppStyles.space1),
                // Nút refresh
                DuoIconButton(
                  icon: Icons.refresh_rounded,
                  variant: DuoIconButtonVariant.white,
                  size: DuoIconButtonSize.md,
                  onTap: controller.refreshMails,
                ),
                SizedBox(width: AppStyles.space1),
                // Nút xóa tất cả thư đã đọc (mờ khi không có thư để xóa)
                Opacity(
                  opacity: canDelete ? 1.0 : 0.4,
                  child: DuoIconButton(
                    icon: Icons.delete_sweep_rounded,
                    variant: DuoIconButtonVariant.white,
                    size: DuoIconButtonSize.md,
                    onTap: canDelete ? () => _showDeleteConfirmDialog() : null,
                  ),
                ),
                SizedBox(width: AppStyles.space2),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.mails.isEmpty) {
          return Center(
            child: DuoEmptyState(
              icon: Icons.mail_outline_rounded,
              title: 'Hòm thư trống',
              subtitle: 'Bạn chưa có thư nào',
              iconColor: AppColors.primary,
              iconBackgroundColor: AppColors.primarySoft,
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(AppStyles.space4),
          itemCount: controller.mails.length,
          separatorBuilder: (_, index) => SizedBox(height: AppStyles.space3),
          itemBuilder: (context, index) {
            final mail = controller.mails[index];
            return DuoMailCard(
              mail: mail,
              accentColor: controller.getMailTypeColor(mail.type),
              onTap: () => _openMailDetail(mail),
              onDelete: () => controller.deleteMail(mail),
            ).animateFadeSlide(delay: (index * 50).toDouble());
          },
        );
      }),
    );
  }

  void _openMailDetail(MailItem mail) {
    controller.markAsRead(mail);
    DuoMailDetailSheet.show(
      mail: mail,
      accentColor: controller.getMailTypeColor(mail.type),
      onClaimReward: () => controller.claimReward(mail),
    );
  }

  Future<void> _showDeleteConfirmDialog() async {
    final confirmed = await DuoConfirmDialog.showDelete(
      title: 'Xóa thư đã đọc?',
      message: 'Tất cả thư đã đọc (và đã nhận quà) sẽ bị xóa vĩnh viễn. Bạn có chắc chắn không?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
    );
    if (confirmed) {
      controller.deleteReadMails();
    }
  }
}
