import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';
import '../base/duo_card.dart';

/// Card hiển thị số dư ví với tiền ảo, diamond, coin
class DuoWalletBalanceCard extends StatelessWidget {
  final int virtualBalance;
  final int diamonds;
  final int coins;

  const DuoWalletBalanceCard({
    super.key,
    required this.virtualBalance,
    required this.diamonds,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/game/currency/cash_green_cash_1st_64px.png',
                width: 48.w,
                height: 48.w,
              ),
              SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số dư ví',
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      NumberFormatter.withCommas(virtualBalance),
                      style: TextStyle(
                        fontSize: AppStyles.text2xl,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space4),
          Divider(color: AppColors.border),
          SizedBox(height: AppStyles.space3),
          Row(
            children: [
              Expanded(child: _DuoMiniBalance(
                icon: 'assets/game/currency/diamond_blue_diamond_1st_64px.png',
                label: 'Diamond',
                value: diamonds,
                color: AppColors.primary,
              )),
              SizedBox(width: AppStyles.space3),
              Expanded(child: _DuoMiniBalance(
                icon: 'assets/game/currency/coin_golden_coin_1st_64px.png',
                label: 'Coin',
                value: coins,
                color: AppColors.yellow,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _DuoMiniBalance extends StatelessWidget {
  final String icon;
  final String label;
  final int value;
  final Color color;

  const _DuoMiniBalance({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppStyles.roundedLg,
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 24.w, height: 24.w),
          SizedBox(width: AppStyles.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  NumberFormatter.compact(value),
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontBold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
