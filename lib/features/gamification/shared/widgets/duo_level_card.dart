import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/components/widgets.dart';

/// Duolingo-style Level Card - hiển thị level và XP progress
class DuoLevelCard extends StatelessWidget {
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int? earnedXp;
  final Color? backgroundColor;
  final Color? shadowColor;
  final bool showProgress;
  final bool animated;

  const DuoLevelCard({
    super.key,
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
    this.earnedXp,
    this.backgroundColor,
    this.shadowColor,
    this.showProgress = true,
    this.animated = true,
  });

  double get _progress => currentXp / xpToNextLevel;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: EdgeInsets.all(AppStyles.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? AppColors.purple,
            (backgroundColor ?? AppColors.purple).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppStyles.rounded2xl,
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? AppColors.purpleDark,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Level badge
              _buildLevelBadge(),
              SizedBox(width: AppStyles.space4),
              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cấp độ',
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'Level $level',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: AppStyles.fontBold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Earned XP (if provided)
              if (earnedXp != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'XP kiếm được',
                      style: TextStyle(
                        fontSize: AppStyles.textXs,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '+$earnedXp',
                      style: TextStyle(
                        fontSize: AppStyles.textXl,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.yellow,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (showProgress) ...[
            SizedBox(height: AppStyles.space4),
            // XP Progress
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentXp XP',
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        fontWeight: AppStyles.fontMedium,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$xpToNextLevel XP',
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppStyles.space2),
                DuoProgressBar(
                  progress: _progress,
                  height: 10.h,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  progressColor: AppColors.yellow,
                  shadowColor: AppColors.yellowDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (animated) {
      card = card
          .animate()
          .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut)
          .fadeIn(duration: 400.ms);
    }

    return card;
  }

  Widget _buildLevelBadge() {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.yellow,
          width: 3,
        ),
      ),
      child: Center(
        child: Image.asset(
          AppAssets.xpStar,
          width: 32.w,
          height: 32.w,
          errorBuilder: (_, _, _) => Icon(
            Icons.star_rounded,
            size: 32.w,
            color: AppColors.yellow,
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Duolingo-style Level Up Animation
class DuoLevelUpOverlay extends StatelessWidget {
  final int newLevel;
  final VoidCallback? onDismiss;

  const DuoLevelUpOverlay({
    super.key,
    required this.newLevel,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stars burst
              Icon(
                Icons.auto_awesome,
                size: 60.w,
                color: AppColors.yellow,
              )
                  .animate(onPlay: (c) => c.repeat())
                  .rotate(duration: 2000.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 500.ms,
                  ),
              SizedBox(height: AppStyles.space4),
              // Level up text
              Text(
                'LEVEL UP!',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: AppStyles.fontExtrabold,
                  color: AppColors.yellow,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              SizedBox(height: AppStyles.space2),
              // New level
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppStyles.space6,
                  vertical: AppStyles.space3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: AppStyles.roundedFull,
                  boxShadow: AppColors.buttonBoxShadow(AppColors.purpleDark),
                ),
                child: Text(
                  'Level $newLevel',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: AppStyles.fontBold,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate()
                  .slideY(begin: 1, end: 0, duration: 500.ms, delay: 300.ms)
                  .fadeIn(delay: 300.ms),
              SizedBox(height: AppStyles.space6),
              // Tap to continue
              Text(
                'Nhấn để tiếp tục',
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(delay: 800.ms)
                  .then()
                  .fadeOut(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}




