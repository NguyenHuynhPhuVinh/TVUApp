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
          // Nút nhận tất cả (chỉ hiện khi có quà)
          Obx(() {
            if (controller.unclaimedCount == 0) {
              return Padding(
                padding: EdgeInsets.only(right: AppStyles.space3),
                child: DuoIconButton(
                  icon: Icons.refresh_rounded,
                  variant: DuoIconButtonVariant.white,
                  size: DuoIconButtonSize.md,
                  onTap: controller.refreshMails,
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.only(right: AppStyles.space3),
              child: GestureDetector(
                onTap: controller.claimAllRewards,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppStyles.space3,
                    vertical: AppStyles.space2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: AppStyles.roundedLg,
                    boxShadow: AppColors.buttonBoxShadow(AppColors.yellowDark, offset: 3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppAssets.giftPurple, width: 16, height: 16),
                      SizedBox(width: AppStyles.space1),
                      Text(
                        'Nhận tất cả',
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
}
