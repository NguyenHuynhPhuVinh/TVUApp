import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../models/achievement_reward.dart';
import '../data/achievement_icons.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';

/// Toast hiển thị khi mở khóa thành tựu mới
class DuoAchievementUnlockedToast extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const DuoAchievementUnlockedToast({
    super.key,
    required this.achievement,
    this.onTap,
  });

  Color get _tierColor =>
      Color(AchievementTierHelper.getTierColorValue(achievement.tier));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppStyles.space4,
          vertical: AppStyles.space2,
        ),
        padding: EdgeInsets.all(AppStyles.space3),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppStyles.roundedLg,
          border: Border.all(
            color: AppColors.withAlpha(_tierColor, 0.5),
            width: AppStyles.border2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.withAlpha(_tierColor, 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.withAlpha(_tierColor, 0.15),
                borderRadius: AppStyles.roundedLg,
              ),
              child: Center(
                child: Image.asset(
                  AchievementIcons.getAchievementAsset(achievement),
                  width: 28,
                  height: 28,
                ),
              ),
            ),
            SizedBox(width: AppStyles.space3),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Image.asset(AppAssets.crown, width: 14, height: 14),
                      SizedBox(width: AppStyles.space1),
                      Text(
                        'Thành tựu mới!',
                        style: TextStyle(
                          fontSize: AppStyles.textXs,
                          fontWeight: AppStyles.fontSemibold,
                          color: AppColors.yellow,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppStyles.space2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.withAlpha(_tierColor, 0.15),
                          borderRadius: AppStyles.roundedSm,
                        ),
                        child: Text(
                          AchievementTierHelper.getTierName(achievement.tier),
                          style: TextStyle(
                            fontSize: AppStyles.textXs,
                            fontWeight: AppStyles.fontSemibold,
                            color: _tierColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppStyles.space1),
                  Text(
                    achievement.name,
                    style: TextStyle(
                      fontWeight: AppStyles.fontBold,
                      fontSize: AppStyles.textSm,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Nhấn để nhận thưởng',
                    style: TextStyle(
                      fontSize: AppStyles.textXs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị toast với animation
  static void show(
    BuildContext context,
    Achievement achievement, {
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + AppStyles.space2,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: AppStyles.durationNormal,
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: DuoAchievementUnlockedToast(
              achievement: achievement,
              onTap: () {
                entry.remove();
                onTap?.call();
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}
