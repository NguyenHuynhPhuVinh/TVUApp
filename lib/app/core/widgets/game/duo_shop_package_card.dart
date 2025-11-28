import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';
import '../base/duo_card.dart';
import '../feedback/duo_tag.dart';

/// Loại gói shop
enum DuoShopPackageType { diamond, coin }

/// Card hiển thị gói mua hàng trong shop
class DuoShopPackageCard extends StatelessWidget {
  final DuoShopPackageType type;
  final int amount;
  final int bonus;
  final int cost;
  final bool canBuy;
  final String? tag;
  final Color? tagColor;
  final VoidCallback? onTap;

  const DuoShopPackageCard({
    super.key,
    required this.type,
    required this.amount,
    required this.bonus,
    required this.cost,
    required this.canBuy,
    this.tag,
    this.tagColor,
    this.onTap,
  });

  /// Factory cho gói Diamond
  factory DuoShopPackageCard.diamond({
    required int diamonds,
    required int bonus,
    required int cost,
    required bool canBuy,
    String? tag,
    Color? tagColor,
    VoidCallback? onTap,
  }) {
    return DuoShopPackageCard(
      type: DuoShopPackageType.diamond,
      amount: diamonds,
      bonus: bonus,
      cost: cost,
      canBuy: canBuy,
      tag: tag,
      tagColor: tagColor,
      onTap: onTap,
    );
  }

  /// Factory cho gói Coin
  factory DuoShopPackageCard.coin({
    required int coins,
    required int bonus,
    required int diamondCost,
    required bool canBuy,
    String? tag,
    Color? tagColor,
    VoidCallback? onTap,
  }) {
    return DuoShopPackageCard(
      type: DuoShopPackageType.coin,
      amount: coins,
      bonus: bonus,
      cost: diamondCost,
      canBuy: canBuy,
      tag: tag,
      tagColor: tagColor,
      onTap: onTap,
    );
  }

  int get total => amount + bonus;

  String get _iconPath => type == DuoShopPackageType.diamond
      ? 'assets/game/currency/diamond_blue_diamond_1st_256px.png'
      : 'assets/game/currency/coin_golden_coin_1st_256px.png';

  String get _costIconPath => type == DuoShopPackageType.diamond
      ? 'assets/game/currency/cash_green_cash_1st_256px.png'
      : 'assets/game/currency/diamond_blue_diamond_1st_256px.png';

  Color get _primaryColor =>
      type == DuoShopPackageType.diamond ? AppColors.primary : AppColors.yellow;

  Color get _bgColor => type == DuoShopPackageType.diamond
      ? AppColors.primarySoft
      : AppColors.yellowSoft;

  Color get _costColor =>
      type == DuoShopPackageType.diamond ? AppColors.green : AppColors.primary;

  String get _label =>
      type == DuoShopPackageType.diamond ? 'Diamond' : 'Coin';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: DuoCard(
        backgroundColor: canBuy ? AppColors.backgroundWhite : AppColors.background,
        onTap: canBuy ? onTap : null,
        child: Row(
          children: [
            // Icon + amount
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: AppStyles.roundedLg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(_iconPath, width: 36.w, height: 36.w),
                  SizedBox(height: AppStyles.space1),
                  Text(
                    NumberFormatter.compact(amount),
                    style: TextStyle(
                      fontSize: AppStyles.textBase,
                      fontWeight: AppStyles.fontBold,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppStyles.space3),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${NumberFormatter.compact(total)} $_label',
                          style: TextStyle(
                            fontSize: AppStyles.textLg,
                            fontWeight: AppStyles.fontBold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tag != null) ...[
                        SizedBox(width: AppStyles.space2),
                        DuoTag(
                          text: tag!,
                          color: tagColor ?? AppColors.orange,
                        ),
                      ],
                    ],
                  ),
                  if (bonus > 0)
                    Text(
                      'Tặng thêm ${NumberFormatter.compact(bonus)} ${_label.toLowerCase()}',
                      style: TextStyle(
                        fontSize: AppStyles.textXs,
                        color: AppColors.orange,
                      ),
                    ),
                  SizedBox(height: AppStyles.space2),
                  Row(
                    children: [
                      Image.asset(_costIconPath, width: 16.w, height: 16.w),
                      SizedBox(width: AppStyles.space1),
                      Text(
                        type == DuoShopPackageType.diamond
                            ? NumberFormatter.withCommas(cost)
                            : NumberFormatter.compact(cost),
                        style: TextStyle(
                          fontSize: AppStyles.textSm,
                          fontWeight: AppStyles.fontSemibold,
                          color: canBuy ? _costColor : AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: canBuy ? _primaryColor : AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
