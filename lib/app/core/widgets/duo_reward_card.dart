import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Reward Card - hiển thị coins, diamonds, XP với animation
class DuoRewardCard extends StatelessWidget {
  final String? iconAsset;
  final IconData? fallbackIcon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final int value;
  final bool showPlus;
  final bool animated;
  final VoidCallback? onTap;

  const DuoRewardCard({
    super.key,
    this.iconAsset,
    this.fallbackIcon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    this.showPlus = true,
    this.animated = true,
    this.onTap,
  });

  /// Factory cho Coin card
  factory DuoRewardCard.coin({
    required int value,
    bool showPlus = true,
    bool animated = true,
    VoidCallback? onTap,
  }) {
    return DuoRewardCard(
      iconAsset: 'assets/game/currency/coin_golden_coin_1st_64px.png',
      fallbackIcon: Icons.monetization_on_rounded,
      iconColor: AppColors.yellow,
      backgroundColor: AppColors.yellowSoft,
      label: 'Coins',
      value: value,
      showPlus: showPlus,
      animated: animated,
      onTap: onTap,
    );
  }

  /// Factory cho Coin card lớn (horizontal)
  factory DuoRewardCard.coinLarge({
    required int value,
    bool showPlus = true,
    bool animated = true,
  }) {
    return DuoRewardCard(
      iconAsset: 'assets/game/currency/coin_golden_coin_1st_64px.png',
      fallbackIcon: Icons.monetization_on_rounded,
      iconColor: AppColors.yellow,
      backgroundColor: AppColors.yellowSoft,
      label: 'COINS',
      value: value,
      showPlus: showPlus,
      animated: animated,
    );
  }

  /// Factory cho Diamond card
  factory DuoRewardCard.diamond({
    required int value,
    bool showPlus = true,
    bool animated = true,
    VoidCallback? onTap,
  }) {
    return DuoRewardCard(
      iconAsset: 'assets/game/currency/diamond_blue_diamond_1st_64px.png',
      fallbackIcon: Icons.diamond_rounded,
      iconColor: AppColors.primary,
      backgroundColor: AppColors.primarySoft,
      label: 'Diamonds',
      value: value,
      showPlus: showPlus,
      animated: animated,
      onTap: onTap,
    );
  }

  /// Factory cho XP card
  factory DuoRewardCard.xp({
    required int value,
    bool showPlus = true,
    bool animated = true,
    VoidCallback? onTap,
  }) {
    return DuoRewardCard(
      iconAsset: 'assets/game/main/star_golden_star_1st_64px.png',
      fallbackIcon: Icons.star_rounded,
      iconColor: AppColors.green,
      backgroundColor: AppColors.greenSoft,
      label: 'XP',
      value: value,
      showPlus: showPlus,
      animated: animated,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppStyles.space4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppStyles.rounded2xl,
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: AppStyles.border2,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.2),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            _buildIcon(),
            SizedBox(height: AppStyles.space2),
            // Value
            Text(
              '${showPlus && value > 0 ? '+' : ''}$value',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: AppStyles.fontBold,
                color: AppColors.textPrimary,
              ),
            ),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: AppStyles.textSm,
                fontWeight: AppStyles.fontMedium,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    if (animated) {
      card = card
          .animate()
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.elasticOut,
          )
          .fadeIn(duration: 300.ms);
    }

    return card;
  }

  Widget _buildIcon() {
    Widget icon;
    if (iconAsset != null) {
      icon = Image.asset(
        iconAsset!,
        width: 48.w,
        height: 48.w,
        errorBuilder: (_, __, ___) => Icon(
          fallbackIcon ?? Icons.star,
          size: 48.w,
          color: iconColor,
        ),
      );
    } else {
      icon = Icon(
        fallbackIcon ?? Icons.star,
        size: 48.w,
        color: iconColor,
      );
    }

    return icon
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Duolingo-style Animated Counter - số đếm tăng dần
class DuoAnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  const DuoAnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1500),
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  @override
  State<DuoAnimatedCounter> createState() => _DuoAnimatedCounterState();
}

class _DuoAnimatedCounterState extends State<DuoAnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(DuoAnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(begin: _animation.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value}${widget.suffix}',
          style: widget.style ??
              TextStyle(
                fontSize: 24.sp,
                fontWeight: AppStyles.fontBold,
                color: AppColors.textPrimary,
              ),
        );
      },
    );
  }
}


/// Duolingo-style Big Reward Row - hiển thị reward lớn dạng horizontal
class DuoBigRewardRow extends StatelessWidget {
  final String? iconAsset;
  final IconData? fallbackIcon;
  final Color color;
  final Color backgroundColor;
  final String label;
  final int value;
  final bool showPlus;
  final bool animated;
  final bool hasGlow;

  const DuoBigRewardRow({
    super.key,
    this.iconAsset,
    this.fallbackIcon,
    required this.color,
    required this.backgroundColor,
    required this.label,
    required this.value,
    this.showPlus = true,
    this.animated = true,
    this.hasGlow = true,
  });

  /// Factory cho Coin row lớn
  factory DuoBigRewardRow.coin({required int value, bool animated = true}) {
    return DuoBigRewardRow(
      iconAsset: 'assets/game/currency/coin_golden_coin_1st_64px.png',
      fallbackIcon: Icons.monetization_on_rounded,
      color: AppColors.yellow,
      backgroundColor: AppColors.yellowSoft,
      label: 'COINS',
      value: value,
      animated: animated,
    );
  }

  /// Factory cho Diamond row
  factory DuoBigRewardRow.diamond({required int value, bool animated = true}) {
    return DuoBigRewardRow(
      iconAsset: 'assets/game/currency/diamond_blue_diamond_1st_64px.png',
      fallbackIcon: Icons.diamond_rounded,
      color: AppColors.primary,
      backgroundColor: AppColors.primarySoft,
      label: 'DIAMONDS',
      value: value,
      animated: animated,
      hasGlow: false,
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    Widget row = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space5,
        vertical: AppStyles.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppStyles.rounded2xl,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon with optional glow
          Container(
            padding: EdgeInsets.all(AppStyles.space3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: hasGlow
                  ? AppColors.glowEffect(color, blur: 20, spread: 5)
                  : null,
            ),
            child: _buildIcon(),
          ),
          SizedBox(width: AppStyles.space4),
          // Value and label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    fontWeight: AppStyles.fontBold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${showPlus && value > 0 ? '+' : ''}${_formatNumber(value)}',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: AppStyles.fontExtrabold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (animated) {
      row = row
          .animate()
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.elasticOut,
          )
          .fadeIn(duration: 400.ms);
    }

    return row;
  }

  Widget _buildIcon() {
    Widget icon;
    if (iconAsset != null) {
      icon = Image.asset(
        iconAsset!,
        width: 52.w,
        height: 52.w,
        errorBuilder: (_, __, ___) => Icon(
          fallbackIcon ?? Icons.star,
          size: 52.w,
          color: color,
        ),
      );
    } else {
      icon = Icon(
        fallbackIcon ?? Icons.star,
        size: 52.w,
        color: color,
      );
    }

    return icon
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1000.ms,
        );
  }
}

/// Duolingo-style Medium Reward Row - hiển thị reward vừa dạng horizontal
class DuoMediumRewardRow extends StatelessWidget {
  final String? iconAsset;
  final IconData? fallbackIcon;
  final Color color;
  final Color backgroundColor;
  final String label;
  final int value;
  final bool showPlus;
  final bool animated;

  const DuoMediumRewardRow({
    super.key,
    this.iconAsset,
    this.fallbackIcon,
    required this.color,
    required this.backgroundColor,
    required this.label,
    required this.value,
    this.showPlus = true,
    this.animated = true,
  });

  /// Factory cho Diamond row
  factory DuoMediumRewardRow.diamond({required int value, bool animated = true}) {
    return DuoMediumRewardRow(
      iconAsset: 'assets/game/currency/diamond_blue_diamond_1st_64px.png',
      fallbackIcon: Icons.diamond_rounded,
      color: AppColors.primary,
      backgroundColor: AppColors.primarySoft,
      label: 'DIAMONDS',
      value: value,
      animated: animated,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget row = Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppStyles.rounded2xl,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: AppStyles.space3),
          Text(
            label,
            style: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontBold,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            '${showPlus && value > 0 ? '+' : ''}$value',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );

    if (animated) {
      row = row
          .animate()
          .slideX(begin: -0.5, end: 0, duration: 400.ms)
          .fadeIn(duration: 300.ms);
    }

    return row;
  }

  Widget _buildIcon() {
    Widget icon;
    if (iconAsset != null) {
      icon = Image.asset(
        iconAsset!,
        width: 36.w,
        height: 36.w,
        errorBuilder: (_, __, ___) => Icon(
          fallbackIcon ?? Icons.star,
          size: 36.w,
          color: color,
        ),
      );
    } else {
      icon = Icon(
        fallbackIcon ?? Icons.star,
        size: 36.w,
        color: color,
      );
    }

    return icon
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.05, end: 0.05, duration: 500.ms);
  }
}
