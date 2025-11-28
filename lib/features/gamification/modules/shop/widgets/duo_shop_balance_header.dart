import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';

/// Header hiển thị số dư trong shop - sử dụng DuoCurrencyRow
class DuoShopBalanceHeader extends StatelessWidget {
  final String leftIcon;
  final String leftLabel;
  final int leftValue;
  final Color leftColor;
  final String rightIcon;
  final String rightLabel;
  final int rightValue;
  final Color rightColor;

  const DuoShopBalanceHeader({
    super.key,
    required this.leftIcon,
    required this.leftLabel,
    required this.leftValue,
    required this.leftColor,
    required this.rightIcon,
    required this.rightLabel,
    required this.rightValue,
    required this.rightColor,
  });

  /// Factory cho Diamond Shop
  factory DuoShopBalanceHeader.diamondShop({
    required int virtualBalance,
    required int diamonds,
  }) {
    return DuoShopBalanceHeader(
      leftIcon: AppAssets.tvuCash,
      leftLabel: 'TVUCash',
      leftValue: virtualBalance,
      leftColor: AppColors.green,
      rightIcon: AppAssets.diamond,
      rightLabel: 'Diamond',
      rightValue: diamonds,
      rightColor: AppColors.primary,
    );
  }

  /// Factory cho Coin Shop
  factory DuoShopBalanceHeader.coinShop({
    required int diamonds,
    required int coins,
  }) {
    return DuoShopBalanceHeader(
      leftIcon: AppAssets.diamond,
      leftLabel: 'Diamond',
      leftValue: diamonds,
      leftColor: AppColors.primary,
      rightIcon: AppAssets.coin,
      rightLabel: 'Coin',
      rightValue: coins,
      rightColor: AppColors.yellow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Row(
        children: [
          Expanded(child: _buildBalanceItem(leftIcon, leftLabel, leftValue, leftColor)),
          Container(width: 1, height: 40.h, color: AppColors.border),
          Expanded(child: _buildBalanceItem(rightIcon, rightLabel, rightValue, rightColor)),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String icon, String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(icon, width: 28.w, height: 28.w),
        SizedBox(width: AppStyles.space2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppStyles.textXs,
                color: AppColors.textSecondary,
              ),
            ),
            // Chỉ hiển thị value, icon đã có ở trên
            Text(
              _formatValue(value),
              style: TextStyle(
                fontSize: AppStyles.textLg,
                fontWeight: AppStyles.fontBold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatValue(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toString();
  }
}



