import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';
import '../base/duo_button.dart';

/// Bottom sheet mua hàng style Google Play
class DuoPurchaseBottomSheet extends StatelessWidget {
  final String itemIcon;
  final String itemName;
  final int itemAmount;
  final int? bonusAmount;
  final int cost;
  final String costIcon;
  final String costLabel;
  final Color costColor;
  final int currentBalance;
  final bool canAfford;
  final bool isLoading;
  final VoidCallback onConfirm;

  const DuoPurchaseBottomSheet({
    super.key,
    required this.itemIcon,
    required this.itemName,
    required this.itemAmount,
    this.bonusAmount,
    required this.cost,
    required this.costIcon,
    required this.costLabel,
    required this.costColor,
    required this.currentBalance,
    required this.canAfford,
    this.isLoading = false,
    required this.onConfirm,
  });

  /// Show bottom sheet để mua Diamond bằng TVUCash
  static Future<bool?> showDiamondPurchase({
    required int diamonds,
    int? bonus,
    required int cost,
    required int tvuCashBalance,
  }) {
    final total = diamonds + (bonus ?? 0);
    final canAfford = tvuCashBalance >= cost;

    return Get.bottomSheet<bool>(
      DuoPurchaseBottomSheet(
        itemIcon: AppAssets.diamond,
        itemName: 'Diamond',
        itemAmount: total,
        bonusAmount: bonus,
        cost: cost,
        costIcon: AppAssets.tvuCash,
        costLabel: 'TVUCash',
        costColor: AppColors.green,
        currentBalance: tvuCashBalance,
        canAfford: canAfford,
        onConfirm: () => Get.back(result: true),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Show bottom sheet để mua Coin bằng Diamond
  static Future<bool?> showCoinPurchase({
    required int coins,
    int? bonus,
    required int diamondCost,
    required int diamondBalance,
  }) {
    final total = coins + (bonus ?? 0);
    final canAfford = diamondBalance >= diamondCost;

    return Get.bottomSheet<bool>(
      DuoPurchaseBottomSheet(
        itemIcon: AppAssets.coin,
        itemName: 'Coin',
        itemAmount: total,
        bonusAmount: bonus,
        cost: diamondCost,
        costIcon: AppAssets.diamond,
        costLabel: 'Diamond',
        costColor: AppColors.primary,
        currentBalance: diamondBalance,
        canAfford: canAfford,
        onConfirm: () => Get.back(result: true),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppStyles.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: AppStyles.space5),

              // Item preview
              _buildItemPreview(),
              SizedBox(height: AppStyles.space5),

              Divider(color: AppColors.border),
              SizedBox(height: AppStyles.space4),

              // Payment method (thẻ thanh toán)
              _buildPaymentMethod(),
              SizedBox(height: AppStyles.space5),

              // Price breakdown
              _buildPriceBreakdown(),
              SizedBox(height: AppStyles.space5),

              // Buy button
              _buildBuyButton(),
              SizedBox(height: AppStyles.space2),

              // Cancel button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppStyles.textBase,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemPreview() {
    return Row(
      children: [
        // Item icon
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: AppStyles.roundedXl,
          ),
          child: Center(
            child: Image.asset(itemIcon, width: 48.w, height: 48.w),
          ),
        ),
        SizedBox(width: AppStyles.space4),

        // Item info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mua $itemName',
                style: TextStyle(
                  fontSize: AppStyles.textLg,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppStyles.space1),
              Row(
                children: [
                  Text(
                    NumberFormatter.withCommas(itemAmount),
                    style: TextStyle(
                      fontSize: AppStyles.text2xl,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (bonusAmount != null && bonusAmount! > 0) ...[
                    SizedBox(width: AppStyles.space2),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppStyles.space2,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: AppStyles.roundedFull,
                      ),
                      child: Text(
                        '+${NumberFormatter.compact(bonusAmount!)} bonus',
                        style: TextStyle(
                          fontSize: AppStyles.textXs,
                          fontWeight: AppStyles.fontSemibold,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phương thức thanh toán',
          style: TextStyle(
            fontSize: AppStyles.textSm,
            fontWeight: AppStyles.fontSemibold,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppStyles.space3),

        // Payment card (selected)
        Container(
          padding: EdgeInsets.all(AppStyles.space4),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: AppStyles.roundedXl,
            border: Border.all(
              color: canAfford ? AppColors.primary : AppColors.red,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Card icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppStyles.roundedLg,
                ),
                child: Center(
                  child: Image.asset(costIcon, width: 28.w, height: 28.w),
                ),
              ),
              SizedBox(width: AppStyles.space3),

              // Card info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ví $costLabel',
                      style: TextStyle(
                        fontSize: AppStyles.textBase,
                        fontWeight: AppStyles.fontSemibold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          'Số dư: ',
                          style: TextStyle(
                            fontSize: AppStyles.textSm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          NumberFormatter.withCommas(currentBalance),
                          style: TextStyle(
                            fontSize: AppStyles.textSm,
                            fontWeight: AppStyles.fontBold,
                            color: canAfford ? costColor : AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Check icon
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: canAfford ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.backgroundWhite,
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),

        // Insufficient balance warning
        if (!canAfford) ...[
          SizedBox(height: AppStyles.space3),
          Container(
            padding: EdgeInsets.all(AppStyles.space3),
            decoration: BoxDecoration(
              color: AppColors.redSoft,
              borderRadius: AppStyles.roundedLg,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.red,
                  size: 20.sp,
                ),
                SizedBox(width: AppStyles.space2),
                Expanded(
                  child: Text(
                    'Số dư không đủ. Cần thêm ${NumberFormatter.withCommas(cost - currentBalance)} $costLabel.',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final balanceAfter = currentBalance - cost;

    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.roundedXl,
      ),
      child: Column(
        children: [
          // Total price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Image.asset(costIcon, width: 20.w, height: 20.w),
                  SizedBox(width: AppStyles.space1),
                  Text(
                    NumberFormatter.withCommas(cost),
                    style: TextStyle(
                      fontSize: AppStyles.textLg,
                      fontWeight: AppStyles.fontBold,
                      color: costColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (canAfford) ...[
            SizedBox(height: AppStyles.space3),
            Divider(color: AppColors.border),
            SizedBox(height: AppStyles.space3),

            // Balance after
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Số dư sau giao dịch',
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  NumberFormatter.withCommas(balanceAfter),
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBuyButton() {
    return DuoButton(
      text: canAfford ? 'Xác nhận mua' : 'Không đủ số dư',
      variant: canAfford ? DuoButtonVariant.primary : DuoButtonVariant.ghost,
      isLoading: isLoading,
      isDisabled: !canAfford,
      onPressed: canAfford ? onConfirm : null,
    );
  }
}
