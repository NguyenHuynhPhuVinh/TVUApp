import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../utils/number_formatter.dart';

/// Widget hiển thị card tiền tệ (coins, diamonds)
class DuoCurrencyCard extends StatelessWidget {
  final String? iconPath;
  final IconData fallbackIcon;
  final String label;
  final int value;
  final Color color;
  final Color bgColor;

  const DuoCurrencyCard({
    super.key,
    this.iconPath,
    required this.fallbackIcon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  /// Factory cho Coins
  factory DuoCurrencyCard.coins(int value) {
    return DuoCurrencyCard(
      iconPath: 'assets/game/currency/coin_golden_coin_1st_64px.png',
      fallbackIcon: Icons.monetization_on_rounded,
      label: 'Coins',
      value: value,
      color: AppColors.yellow,
      bgColor: AppColors.yellowSoft,
    );
  }

  /// Factory cho Diamonds
  factory DuoCurrencyCard.diamonds(int value) {
    return DuoCurrencyCard(
      iconPath: 'assets/game/currency/diamond_blue_diamond_1st_64px.png',
      fallbackIcon: Icons.diamond_rounded,
      label: 'Diamonds',
      value: value,
      color: AppColors.primary,
      bgColor: AppColors.primarySoft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        children: [
          if (iconPath != null)
            Image.asset(
              iconPath!,
              width: 32.w,
              height: 32.w,
              errorBuilder: (_, __, ___) =>
                  Icon(fallbackIcon, size: 32.w, color: color),
            )
          else
            Icon(fallbackIcon, size: 32.w, color: color),
          SizedBox(height: AppStyles.space2),
          Text(
            NumberFormatter.compact(value),
            style: TextStyle(
              fontSize: AppStyles.textLg,
              fontWeight: AppStyles.fontBold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppStyles.textXs,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
