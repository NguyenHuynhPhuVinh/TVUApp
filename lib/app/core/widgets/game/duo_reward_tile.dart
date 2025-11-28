import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';

/// Kích thước của DuoRewardTile
enum DuoRewardTileSize { sm, md, lg }

/// Layout của DuoRewardTile
enum DuoRewardTileLayout { horizontal, vertical }

/// Unified Reward Tile - thay thế DuoRewardRow, DuoBigRewardRow, DuoMediumRewardRow, DuoCurrencyCard
/// Hỗ trợ nhiều kích thước và layout khác nhau
class DuoRewardTile extends StatelessWidget {
  final String? iconAsset;
  final IconData? fallbackIcon;
  final Color color;
  final Color backgroundColor;
  final String label;
  final int value;
  final bool showPlus;
  final bool animated;
  final bool hasGlow;
  final bool hasShadow;
  final DuoRewardTileSize size;
  final DuoRewardTileLayout layout;
  final VoidCallback? onTap;

  const DuoRewardTile({
    super.key,
    this.iconAsset,
    this.fallbackIcon,
    required this.color,
    required this.backgroundColor,
    required this.label,
    required this.value,
    this.showPlus = true,
    this.animated = true,
    this.hasGlow = false,
    this.hasShadow = true,
    this.size = DuoRewardTileSize.md,
    this.layout = DuoRewardTileLayout.horizontal,
    this.onTap,
  });

  // ============ COIN FACTORIES ============

  factory DuoRewardTile.coin({
    required int value,
    bool showPlus = true,
    bool animated = true,
    bool hasShadow = true,
    DuoRewardTileSize size = DuoRewardTileSize.md,
    DuoRewardTileLayout layout = DuoRewardTileLayout.horizontal,
    VoidCallback? onTap,
  }) {
    return DuoRewardTile(
      iconAsset: AppAssets.coin,
      fallbackIcon: Icons.monetization_on_rounded,
      color: AppColors.yellow,
      backgroundColor: AppColors.yellowSoft,
      label: size == DuoRewardTileSize.lg ? 'COINS' : 'Coins',
      value: value,
      showPlus: showPlus,
      animated: animated,
      hasGlow: size == DuoRewardTileSize.lg,
      hasShadow: hasShadow,
      size: size,
      layout: layout,
      onTap: onTap,
    );
  }

  /// Factory cho Coins dạng card (thay thế DuoCurrencyCard.coins)
  factory DuoRewardTile.coinCard({required int value}) {
    return DuoRewardTile.coin(
      value: value,
      showPlus: false,
      animated: false,
      hasShadow: false,
      size: DuoRewardTileSize.sm,
      layout: DuoRewardTileLayout.vertical,
    );
  }

  // ============ DIAMOND FACTORIES ============

  factory DuoRewardTile.diamond({
    required int value,
    bool showPlus = true,
    bool animated = true,
    bool hasShadow = true,
    DuoRewardTileSize size = DuoRewardTileSize.md,
    DuoRewardTileLayout layout = DuoRewardTileLayout.horizontal,
    VoidCallback? onTap,
  }) {
    return DuoRewardTile(
      iconAsset: AppAssets.diamond,
      fallbackIcon: Icons.diamond_rounded,
      color: AppColors.primary,
      backgroundColor: AppColors.primarySoft,
      label: size == DuoRewardTileSize.lg ? 'DIAMONDS' : 'Diamonds',
      value: value,
      showPlus: showPlus,
      animated: animated,
      hasShadow: hasShadow,
      size: size,
      layout: layout,
      onTap: onTap,
    );
  }

  /// Factory cho Diamonds dạng card (thay thế DuoCurrencyCard.diamonds)
  factory DuoRewardTile.diamondCard({required int value}) {
    return DuoRewardTile.diamond(
      value: value,
      showPlus: false,
      animated: false,
      hasShadow: false,
      size: DuoRewardTileSize.sm,
      layout: DuoRewardTileLayout.vertical,
    );
  }

  // ============ XP FACTORIES ============

  factory DuoRewardTile.xp({
    required int value,
    bool showPlus = true,
    bool animated = true,
    bool hasShadow = true,
    DuoRewardTileSize size = DuoRewardTileSize.md,
    DuoRewardTileLayout layout = DuoRewardTileLayout.horizontal,
    VoidCallback? onTap,
  }) {
    return DuoRewardTile(
      iconAsset: AppAssets.xpStar,
      fallbackIcon: Icons.star_rounded,
      color: AppColors.green,
      backgroundColor: AppColors.greenSoft,
      label: 'XP',
      value: value,
      showPlus: showPlus,
      animated: animated,
      hasShadow: hasShadow,
      size: size,
      layout: layout,
      onTap: onTap,
    );
  }

  /// Factory cho XP dạng card
  factory DuoRewardTile.xpCard({required int value}) {
    return DuoRewardTile.xp(
      value: value,
      showPlus: false,
      animated: false,
      hasShadow: false,
      size: DuoRewardTileSize.sm,
      layout: DuoRewardTileLayout.vertical,
    );
  }

  // ============ SIZE CONFIGS ============

  double get _iconSize {
    switch (size) {
      case DuoRewardTileSize.sm:
        return 32.w;
      case DuoRewardTileSize.md:
        return 36.w;
      case DuoRewardTileSize.lg:
        return 52.w;
    }
  }

  double get _fontSize {
    switch (size) {
      case DuoRewardTileSize.sm:
        return 20.sp;
      case DuoRewardTileSize.md:
        return 26.sp;
      case DuoRewardTileSize.lg:
        return 36.sp;
    }
  }

  double get _labelSize {
    switch (size) {
      case DuoRewardTileSize.sm:
        return AppStyles.textSm;
      case DuoRewardTileSize.md:
        return AppStyles.textBase;
      case DuoRewardTileSize.lg:
        return AppStyles.textSm;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case DuoRewardTileSize.sm:
        return EdgeInsets.symmetric(
          horizontal: AppStyles.space3,
          vertical: AppStyles.space2,
        );
      case DuoRewardTileSize.md:
        return EdgeInsets.all(AppStyles.space4);
      case DuoRewardTileSize.lg:
        return EdgeInsets.symmetric(
          horizontal: AppStyles.space5,
          vertical: AppStyles.space4,
        );
    }
  }

  double get _borderWidth {
    switch (size) {
      case DuoRewardTileSize.sm:
        return 2;
      case DuoRewardTileSize.md:
        return 2;
      case DuoRewardTileSize.lg:
        return 3;
    }
  }

  double get _shadowOffset {
    switch (size) {
      case DuoRewardTileSize.sm:
        return 3;
      case DuoRewardTileSize.md:
        return 4;
      case DuoRewardTileSize.lg:
        return 5;
    }
  }

  String get _formattedValue {
    final prefix = showPlus && value > 0 ? '+' : '';
    return '$prefix${NumberFormatter.compact(value)}';
  }

  @override
  Widget build(BuildContext context) {
    Widget tile = GestureDetector(
      onTap: onTap,
      child: Container(
        width: layout == DuoRewardTileLayout.horizontal ? double.infinity : null,
        padding: _padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppStyles.rounded2xl,
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: _borderWidth,
          ),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    offset: Offset(0, _shadowOffset),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: layout == DuoRewardTileLayout.vertical
            ? _buildVerticalLayout()
            : _buildHorizontalLayout(),
      ),
    );

    if (animated) {
      tile = _applyAnimation(tile);
    }

    return tile;
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        _buildIconContainer(),
        SizedBox(width: size == DuoRewardTileSize.lg ? AppStyles.space4 : AppStyles.space3),
        if (size == DuoRewardTileSize.lg) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: _labelSize,
                    fontWeight: AppStyles.fontBold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _formattedValue,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: AppStyles.fontExtrabold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            label,
            style: TextStyle(
              fontSize: _labelSize,
              fontWeight: AppStyles.fontBold,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            _formattedValue,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        SizedBox(height: AppStyles.space2),
        Text(
          _formattedValue,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: _labelSize,
            fontWeight: AppStyles.fontMedium,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer() {
    if (size == DuoRewardTileSize.lg && hasGlow) {
      return Container(
        padding: EdgeInsets.all(AppStyles.space3),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppColors.glowEffect(color, blur: 20, spread: 5),
        ),
        child: _buildIcon(),
      );
    }
    return _buildIcon();
  }

  Widget _buildIcon() {
    Widget icon;
    if (iconAsset != null) {
      icon = Image.asset(
        iconAsset!,
        width: _iconSize,
        height: _iconSize,
        errorBuilder: (_, _, _) => Icon(
          fallbackIcon ?? Icons.star,
          size: _iconSize,
          color: color,
        ),
      );
    } else {
      icon = Icon(
        fallbackIcon ?? Icons.star,
        size: _iconSize,
        color: color,
      );
    }

    if (animated) {
      icon = icon
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 1000.ms,
          );
    }

    return icon;
  }

  Widget _applyAnimation(Widget widget) {
    switch (size) {
      case DuoRewardTileSize.lg:
        return widget
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 400.ms);
      case DuoRewardTileSize.md:
        return widget
            .animate()
            .slideX(begin: -0.5, end: 0, duration: 400.ms)
            .fadeIn(duration: 300.ms);
      case DuoRewardTileSize.sm:
        return widget
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms);
    }
  }
}
