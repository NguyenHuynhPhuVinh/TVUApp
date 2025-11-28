import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/diamond_shop_controller.dart';

class DiamondShopView extends GetView<DiamondShopController> {
  const DiamondShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Nạp Diamond',
        leading: const DuoBackButton(),
      ),
      body: Obx(() => Column(
        children: [
          DuoShopBalanceHeader.diamondShop(
            virtualBalance: controller.virtualBalance,
            diamonds: controller.diamonds,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppStyles.space4),
              itemCount: controller.packages.length,
              itemBuilder: (context, index) {
                final package = controller.packages[index];
                return DuoShopPackageCard.diamond(
                  diamonds: package.diamonds,
                  bonus: package.bonus,
                  cost: package.cost,
                  canBuy: controller.canBuy(package),
                  tag: _getTag(package),
                  tagColor: _getTagColor(package),
                  onTap: () => _showConfirmDialog(package),
                );
              },
            ),
          ),
        ],
      )),
    );
  }

  String? _getTag(DiamondPackage package) {
    if (package.isBestValue) return 'BEST VALUE';
    if (package.isFirstBuy) return 'STARTER';
    if (package.bonus > 0) return '+${package.bonusPercent.toInt()}%';
    return null;
  }

  Color? _getTagColor(DiamondPackage package) {
    if (package.isBestValue) return AppColors.purple;
    if (package.isFirstBuy) return AppColors.green;
    return AppColors.orange;
  }

  void _showConfirmDialog(DiamondPackage package) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.rounded2xl),
        title: const Text('Xác nhận mua'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/game/currency/diamond_blue_diamond_1st_64px.png',
              width: 64.w,
              height: 64.w,
            ),
            SizedBox(height: AppStyles.space3),
            Text(
              'Mua ${NumberFormatter.compact(package.total)} Diamond',
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
                  'assets/game/currency/cash_green_cash_1st_64px.png',
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(width: AppStyles.space1),
                Text(
                  NumberFormatter.withCommas(package.cost),
                  style: TextStyle(
                    fontWeight: AppStyles.fontBold,
                    color: AppColors.green,
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
                : () => _buyDiamonds(package),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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

  Future<void> _buyDiamonds(DiamondPackage package) async {
    final result = await controller.buyDiamonds(package);
    Get.back();

    if (result != null) {
      await DuoRewardDialog.showCustom(
        title: 'Mua thành công!',
        rewards: [
          RewardItem(
            icon: 'assets/game/currency/diamond_blue_diamond_1st_64px.png',
            label: 'Diamond',
            value: result['diamondAmount'],
            color: AppColors.primary,
          ),
        ],
      );
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể mua diamond. Vui lòng thử lại.',
        backgroundColor: AppColors.redSoft,
        colorText: AppColors.red,
      );
    }
  }
}
