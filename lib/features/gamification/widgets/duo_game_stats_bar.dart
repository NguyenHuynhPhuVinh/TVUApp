import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import 'duo_currency_row.dart';

/// Widget hiển thị thanh game stats (level, coins, diamonds) - dùng trong welcome card
class DuoGameStatsBar extends StatelessWidget {
  final int level;
  final int coins;
  final int diamonds;

  const DuoGameStatsBar({
    super.key,
    required this.level,
    required this.coins,
    required this.diamonds,
  });

  @override
  Widget build(BuildContext context) {
    final whiteTextStyle = TextStyle(
      fontSize: AppStyles.textSm,
      fontWeight: AppStyles.fontBold,
      color: Colors.white,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space3,
        vertical: AppStyles.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(Colors.white, 0.15),
        borderRadius: AppStyles.roundedLg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Level - giữ nguyên vì không phải currency
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 18.w, color: AppColors.yellow),
              SizedBox(width: 4.w),
              Text('Lv.$level', style: whiteTextStyle),
            ],
          ),
          _buildDivider(),
          // Coins - sử dụng DuoCurrencyRow
          DuoCurrencyRow.coin(
            value: coins,
            size: DuoCurrencySize.sm,
            valueStyle: whiteTextStyle,
          ),
          _buildDivider(),
          // Diamonds - sử dụng DuoCurrencyRow
          DuoCurrencyRow.diamond(
            value: diamonds,
            size: DuoCurrencySize.sm,
            valueStyle: whiteTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 16.h,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}




