import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../../routes/app_routes.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Ví của tôi',
        leading: const DuoBackButton(),
      ),
      body: Obx(() => ListView(
        padding: EdgeInsets.all(AppStyles.space4),
        children: [
          // Thẻ ví
          DuoWalletBalanceCard(
            virtualBalance: controller.virtualBalance,
            diamonds: controller.diamonds,
            coins: controller.coins,
            cardHolder: controller.fullName,
          ),
          SizedBox(height: AppStyles.space4),
          
          // Quick actions
          Row(
            children: [
              Expanded(
                child: DuoButton(
                  text: 'Nạp Diamond',
                  variant: DuoButtonVariant.primary,
                  onPressed: () => Get.toNamed(Routes.diamondShop),
                ),
              ),
              SizedBox(width: AppStyles.space3),
              Expanded(
                child: DuoButton(
                  text: 'Mua Coin',
                  variant: DuoButtonVariant.warning,
                  onPressed: () => Get.toNamed(Routes.coinShop),
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space4),
          
          // Tuition bonus card
          if (controller.canClaimTuitionBonus.value)
            Obx(() => DuoTuitionBonusCard.canClaim(
              tuitionPaid: controller.tuitionPaid.value,
              virtualBalance: controller.tuitionPaid.value, // 1:1
              onClaim: _claimBonus,
              isLoading: controller.isLoading.value,
            ))
          else if (controller.tuitionBonusClaimed)
            DuoTuitionBonusCard.claimed(
              virtualBalance: controller.virtualBalance,
            ),
          
          if (controller.canClaimTuitionBonus.value || controller.tuitionBonusClaimed)
            SizedBox(height: AppStyles.space4),
          
          // Lịch sử giao dịch
          Text(
            'Lịch sử giao dịch',
            style: TextStyle(
              fontSize: AppStyles.textLg,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppStyles.space3),
          
          if (controller.transactions.isEmpty)
            DuoEmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Chưa có giao dịch',
              subtitle: 'Các giao dịch của bạn sẽ hiển thị ở đây',
            )
          else
            ...controller.transactions.map((tx) => DuoTransactionItem(
              title: tx.type.displayName,
              description: tx.description,
              amount: tx.amount,
              isIncome: tx.type.isIncome,
              createdAt: tx.createdAt,
            )),
        ],
      )),
    );
  }

  Future<void> _claimBonus() async {
    final result = await controller.claimTuitionBonus();
    if (result != null) {
      await DuoRewardDialog.showCustom(
        title: 'Nhận thưởng thành công!',
        rewards: [
          RewardItem(
            icon: 'assets/game/currency/cash_green_cash_1st_64px.png',
            label: 'TVUCash',
            value: result['virtualBalance'],
            color: AppColors.green,
          ),
        ],
      );
    }
  }
}
