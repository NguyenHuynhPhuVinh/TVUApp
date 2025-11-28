import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/coin_shop_controller.dart';

class CoinShopView extends GetView<CoinShopController> {
  const CoinShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Mua Coin',
        leading: const DuoBackButton(),
      ),
      body: Obx(() => Column(
        children: [
          DuoShopBalanceHeader.coinShop(
            diamonds: controller.diamonds,
            coins: controller.coins,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppStyles.space4),
              itemCount: controller.packages.length,
              itemBuilder: (context, index) {
                final package = controller.packages[index];
                return DuoShopPackageCard.coin(
                  coins: package.coins,
                  bonus: package.bonus,
                  diamondCost: package.diamonds,
                  canBuy: controller.canBuy(package),
                  tag: package.bonus > 0 ? 'HOT' : null,
                  tagColor: AppColors.orange,
                  onTap: () => _showConfirmDialog(package),
                );
              },
            ),
          ),
        ],
      )),
    );
  }

  void _showConfirmDialog(CoinPackage package) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.rounded2xl),
        title: const Text('Xác nhận mua'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/game/currency/coin_golden_coin_1st_64px.png',
              width: 64.w,
              height: 64.w,
            ),
            SizedBox(height: AppStyles.space3),
            Text(
              'Mua ${NumberFormatter.compact(package.total)} Coin',
              style: TextStyle(
                fontSize: AppStyles.textLg,
                fontWeight: AppStyles.fontBold,
              ),
            ),
            SizedBox(height: AppStyles.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Giá: '),
                Image.asset(
                  'assets/game/currency/diamond_blue_diamond_1st_64px.png',
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(width: AppStyles.space1),
                Text(
                  NumberFormatter.compact(package.diamonds),
                  style: TextStyle(
                    fontWeight: AppStyles.fontBold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value 
                ? null 
                : () => _buyCoins(package),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.backgroundWhite,
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.backgroundWhite,
                    ),
                  )
                : const Text('Mua ngay'),
          )),
        ],
      ),
    );
  }

  Future<void> _buyCoins(CoinPackage package) async {
    final result = await controller.buyCoins(package);
    Get.back();

    if (result != null) {
      await DuoRewardDialog.showCustom(
        title: 'Mua thành công!',
        rewards: [
          RewardItem(
            icon: 'assets/game/currency/coin_golden_coin_1st_64px.png',
            label: 'Coin',
            value: result['totalCoins'] ?? result['coinAmount'],
            color: AppColors.yellow,
          ),
        ],
      );
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể mua coin. Vui lòng thử lại.',
        backgroundColor: AppColors.redSoft,
        colorText: AppColors.red,
      );
    }
  }
}
