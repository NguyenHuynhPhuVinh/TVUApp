import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style Progress Bar
class DuoProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final Color? shadowColor;
  final double height;
  final bool showShimmer;
  final bool animated;

  const DuoProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.shadowColor,
    this.height = 12,
    this.showShimmer = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.backgroundDark;
    final fgColor = progressColor ?? AppColors.green;
    final shadow = shadowColor ?? AppColors.greenDark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.roundedFull,
      ),
      child: Stack(
        children: [
          // Progress fill
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: animated ? AppStyles.durationNormal : Duration.zero,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fgColor,
                  borderRadius: AppStyles.roundedFull,
                  boxShadow: [
                    BoxShadow(
                      color: shadow,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Shimmer effect
          if (showShimmer && progress > 0)
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppStyles.roundedFull,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1500.ms, color: AppColors.withAlpha(Colors.white, 0.4)),
            ),
        ],
      ),
    );
  }
}

/// Duolingo-style Circular Progress
class DuoCircularProgress extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? child;

  const DuoCircularProgress({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1,
            strokeWidth: strokeWidth,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              backgroundColor ?? AppColors.backgroundDark,
            ),
          ),
          // Progress circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: AppStyles.durationSlow,
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? AppColors.green,
                ),
                strokeCap: StrokeCap.round,
              );
            },
          ),
          // Center content
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Duolingo-style Loading Dots
class DuoLoadingDots extends StatelessWidget {
  final Color? color;
  final double dotSize;
  final int dotCount;

  const DuoLoadingDots({
    super.key,
    this.color,
    this.dotSize = 16,
    this.dotCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = color ?? Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dotCount, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppStyles.space1),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.2, 1.2),
              duration: 600.ms,
              delay: (index * 200).ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(0.5, 0.5),
              duration: 600.ms,
              curve: Curves.easeInOut,
            );
      }),
    );
  }
}

/// Progress bar với label - thay thế pattern lặp lại trong:
/// DuoLevelProgressCard, DuoXpProgress, DuoRankProgress, DuoAttendanceCard
class DuoLabeledProgressBar extends StatelessWidget {
  final String? leftLabel;
  final String? rightLabel;
  final double progress;
  final Color? progressColor;
  final Color? shadowColor;
  final double height;
  final bool showShimmer;
  final TextStyle? labelStyle;

  const DuoLabeledProgressBar({
    super.key,
    this.leftLabel,
    this.rightLabel,
    required this.progress,
    this.progressColor,
    this.shadowColor,
    this.height = 12,
    this.showShimmer = true,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = TextStyle(
      fontSize: AppStyles.textSm,
      fontWeight: AppStyles.fontMedium,
      color: AppColors.textSecondary,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leftLabel != null || rightLabel != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leftLabel != null)
                Text(leftLabel!, style: labelStyle ?? defaultLabelStyle)
              else
                const SizedBox.shrink(),
              if (rightLabel != null)
                Text(rightLabel!, style: labelStyle ?? defaultLabelStyle)
              else
                const SizedBox.shrink(),
            ],
          ),
          SizedBox(height: AppStyles.space2),
        ],
        DuoProgressBar(
          progress: progress,
          progressColor: progressColor,
          shadowColor: shadowColor,
          height: height,
          showShimmer: showShimmer,
        ),
      ],
    );
  }
}

