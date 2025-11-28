import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';

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
          _DuoStatItem(
            icon: Icons.star_rounded,
            value: 'Lv.$level',
            color: AppColors.yellow,
          ),
          _buildDivider(),
          _DuoStatItem(
            iconPath: 'assets/game/currency/coin_golden_coin_1st_256px.png',
            fallbackIcon: Icons.monetization_on_rounded,
            value: NumberFormatter.compact(coins),
            color: AppColors.yellow,
          ),
          _buildDivider(),
          _DuoStatItem(
            iconPath: 'assets/game/currency/diamond_blue_diamond_1st_256px.png',
            fallbackIcon: Icons.diamond_rounded,
            value: NumberFormatter.compact(diamonds),
            color: Colors.cyan,
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

class _DuoStatItem extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final IconData? fallbackIcon;
  final String value;
  final Color color;

  const _DuoStatItem({
    this.icon,
    this.iconPath,
    this.fallbackIcon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconPath != null)
          Image.asset(
            iconPath!,
            width: 18.w,
            height: 18.w,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon ?? Icons.star,
              size: 18.w,
              color: color,
            ),
          )
        else
          Icon(icon, size: 18.w, color: color),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textSm,
            fontWeight: AppStyles.fontBold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

