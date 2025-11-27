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
