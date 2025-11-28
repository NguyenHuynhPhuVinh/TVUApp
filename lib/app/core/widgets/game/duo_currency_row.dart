import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';

/// Kích thước của DuoCurrencyRow
enum DuoCurrencySize { xs, sm, md, lg }

/// Widget nguyên tử hiển thị [Icon + Value] cho tiền tệ game
/// Thay thế pattern lặp lại trong: DuoRewardTile, DuoGameStatsBar, 
/// DuoShopPackageCard, DuoTransactionItem, DuoTuitionBonusCard, DuoShopBalanceHeader
class DuoCurrencyRow extends StatelessWidget {
  final String assetPath;
  final IconData? fallbackIcon;
  final int value;
  final Color? color;
  final DuoCurrencySize size;
  final bool showPlus;
  final bool compact; // Hiển thị số rút gọn (1K, 1M)
  final TextStyle? valueStyle;

  const DuoCurrencyRow({
    super.key,
    required this.assetPath,
    this.fallbackIcon,
    required this.value,
    this.color,
    this.size = DuoCurrencySize.md,
    this.showPlus = false,
    this.compact = true,
    this.valueStyle,
  });

  // ============ COIN FACTORIES ============
  
  factory DuoCurrencyRow.coin({
    required int value,
    DuoCurrencySize size = DuoCurrencySize.md,
    bool showPlus = false,
    bool compact = true,
    TextStyle? valueStyle,
  }) {
    return DuoCurrencyRow(
      assetPath: AppAssets.coin,
      fallbackIcon: Icons.monetization_on_rounded,
      value: value,
      color: AppColors.yellow,
      size: size,
      showPlus: showPlus,
      compact: compact,
      valueStyle: valueStyle,
    );
  }

  // ============ DIAMOND FACTORIES ============
  
  factory DuoCurrencyRow.diamond({
    required int value,
    DuoCurrencySize size = DuoCurrencySize.md,
    bool showPlus = false,
    bool compact = true,
    TextStyle? valueStyle,
  }) {
    return DuoCurrencyRow(
      assetPath: AppAssets.diamond,
      fallbackIcon: Icons.diamond_rounded,
      value: value,
      color: AppColors.primary,
      size: size,
      showPlus: showPlus,
      compact: compact,
      valueStyle: valueStyle,
    );
  }

  // ============ XP FACTORIES ============
  
  factory DuoCurrencyRow.xp({
    required int value,
    DuoCurrencySize size = DuoCurrencySize.md,
    bool showPlus = false,
    bool compact = true,
    TextStyle? valueStyle,
  }) {
    return DuoCurrencyRow(
      assetPath: AppAssets.xpStar,
      fallbackIcon: Icons.star_rounded,
      value: value,
      color: AppColors.green,
      size: size,
      showPlus: showPlus,
      compact: compact,
      valueStyle: valueStyle,
    );
  }

  // ============ TVU CASH FACTORIES ============
  
  factory DuoCurrencyRow.tvuCash({
    required int value,
    DuoCurrencySize size = DuoCurrencySize.md,
    bool showPlus = false,
    bool compact = true,
    TextStyle? valueStyle,
  }) {
    return DuoCurrencyRow(
      assetPath: AppAssets.tvuCash,
      fallbackIcon: Icons.account_balance_wallet_rounded,
      value: value,
      color: AppColors.green,
      size: size,
      showPlus: showPlus,
      compact: compact,
      valueStyle: valueStyle,
    );
  }

  // ============ SIZE CONFIGS ============

  double get _iconSize {
    switch (size) {
      case DuoCurrencySize.xs:
        return 14.w;
      case DuoCurrencySize.sm:
        return 18.w;
      case DuoCurrencySize.md:
        return 24.w;
      case DuoCurrencySize.lg:
        return 32.w;
    }
  }

  double get _fontSize {
    switch (size) {
      case DuoCurrencySize.xs:
        return AppStyles.textXs;
      case DuoCurrencySize.sm:
        return AppStyles.textSm;
      case DuoCurrencySize.md:
        return AppStyles.textBase;
      case DuoCurrencySize.lg:
        return AppStyles.textXl;
    }
  }

  double get _spacing {
    switch (size) {
      case DuoCurrencySize.xs:
        return 2.w;
      case DuoCurrencySize.sm:
        return 4.w;
      case DuoCurrencySize.md:
        return 6.w;
      case DuoCurrencySize.lg:
        return 8.w;
    }
  }

  String get _formattedValue {
    final prefix = showPlus && value > 0 ? '+' : '';
    final formatted = compact 
        ? NumberFormatter.compact(value)
        : NumberFormatter.withCommas(value);
    return '$prefix$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetPath,
          width: _iconSize,
          height: _iconSize,
          errorBuilder: (context, error, stackTrace) => Icon(
            fallbackIcon ?? Icons.star,
            size: _iconSize,
            color: color,
          ),
        ),
        SizedBox(width: _spacing),
        Text(
          _formattedValue,
          style: valueStyle ?? TextStyle(
            fontSize: _fontSize,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
