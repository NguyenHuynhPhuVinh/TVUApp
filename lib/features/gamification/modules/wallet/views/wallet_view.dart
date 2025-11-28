import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/components/widgets.dart';
import '../../../shared/models/wallet_transaction.dart';
import '../widgets/wallet_widgets.dart';
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
            cardHolder: controller.fullName,
            cardNumber: controller.mssv,
          ),
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
}




