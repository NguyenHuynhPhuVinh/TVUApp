import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/shop_controller.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: const DuoBackButton(color: AppColors.backgroundWhite),
          title: Text(
            'Cửa hàng',
            style: TextStyle(
              fontSize: AppStyles.textXl,
              fontWeight: AppStyles.fontBold,
              color: AppColors.backgroundWhite,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.backgroundWhite,
            indicatorWeight: 3,
            labelColor: AppColors.backgroundWhite,
            unselectedLabelColor: AppColors.backgroundWhite.withValues(alpha: 0.6),
            labelStyle: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontBold,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.diamond,
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(width: AppStyles.space2),
                    const Text('Diamond'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.coin,
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(width: AppStyles.space2),
                    const Text('Coin'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DiamondShopTab(controller: controller),
            _CoinShopTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

/// Tab mua Diamond
class _DiamondShopTab extends StatelessWidget {
  final ShopController controller;

  const _DiamondShopTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppStyles.space4),
      itemCount: controller.diamondPackages.length,
      itemBuilder: (context, index) {
        final package = controller.diamondPackages[index];
        return DuoShopPackageCard.diamond(
          diamonds: package.diamonds,
          bonus: package.bonus,
          cost: package.cost,
          canBuy: true, // Check trong bottom sheet
          tag: _getTag(package),
          tagColor: _getTagColor(package),
          onTap: () => _showPurchaseSheet(package),
        );
      },
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

  Future<void> _showPurchaseSheet(DiamondPackage package) async {
    final confirmed = await DuoPurchaseBottomSheet.showDiamondPurchase(
      diamonds: package.diamonds,
      bonus: package.bonus > 0 ? package.bonus : null,
      cost: package.cost,
      tvuCashBalance: controller.virtualBalance,
    );

    if (confirmed == true) {
      final result = await controller.buyDiamonds(package);
      if (result != null) {
        await DuoRewardDialog.showCustom(
          title: 'Mua thành công!',
          rewards: [
            RewardItem(
              icon: AppAssets.diamond,
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
}

/// Tab mua Coin
class _CoinShopTab extends StatelessWidget {
  final ShopController controller;

  const _CoinShopTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppStyles.space4),
      itemCount: controller.coinPackages.length,
      itemBuilder: (context, index) {
        final package = controller.coinPackages[index];
        return DuoShopPackageCard.coin(
          coins: package.coins,
          bonus: package.bonus,
          diamondCost: package.diamonds,
          canBuy: true, // Check trong bottom sheet
          tag: package.bonus > 0 ? 'HOT' : null,
          tagColor: AppColors.orange,
          onTap: () => _showPurchaseSheet(package),
        );
      },
    );
  }

  Future<void> _showPurchaseSheet(CoinPackage package) async {
    final confirmed = await DuoPurchaseBottomSheet.showCoinPurchase(
      coins: package.coins,
      bonus: package.bonus > 0 ? package.bonus : null,
      diamondCost: package.diamonds,
      diamondBalance: controller.diamonds,
    );

    if (confirmed == true) {
      final result = await controller.buyCoins(package);
      if (result != null) {
        await DuoRewardDialog.showCustom(
          title: 'Mua thành công!',
          rewards: [
            RewardItem(
              icon: AppAssets.coin,
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
}
