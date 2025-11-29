import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/achievement_model.dart';
import '../models/achievement_reward.dart';
import '../services/achievement_service.dart';
import '../data/achievement_icons.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../core/components/widgets.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';

/// Card preview thành tựu cho Home/Profile
class DuoAchievementPreviewCard extends StatefulWidget {
  const DuoAchievementPreviewCard({super.key});

  @override
  State<DuoAchievementPreviewCard> createState() => _DuoAchievementPreviewCardState();
}

class _DuoAchievementPreviewCardState extends State<DuoAchievementPreviewCard> {
  @override
  Widget build(BuildContext context) {
    // Kiểm tra service đã đăng ký chưa
    if (!Get.isRegistered<AchievementService>()) {
      return _buildLoadingCard();
    }

    final service = Get.find<AchievementService>();

    // Wrap toàn bộ trong Obx để reactive khi achievements load xong
    return Obx(() {
      // Nếu achievements chưa load xong, hiện loading
      if (service.achievements.isEmpty) {
        return _buildLoadingCard();
      }
      
      final totalUnlocked = service.totalUnlocked.value;
      final totalAchievements = service.achievements.length;
      final unclaimedCount = service.unclaimedCount.value;
      final nearCompletion =
          service.nearCompletionAchievements.take(3).toList();

      return DuoCard(
        onTap: () => Get.toNamed(Routes.achievements),
        shadowColor:
            unclaimedCount > 0 ? AppColors.yellow : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Image.asset(AppAssets.crown, width: 28, height: 28),
                SizedBox(width: AppStyles.space2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thành tựu',
                        style: TextStyle(
                          fontWeight: AppStyles.fontBold,
                          fontSize: AppStyles.textBase,
                        ),
                      ),
                      Text(
                        '$totalUnlocked / $totalAchievements đã mở',
                        style: TextStyle(
                          fontSize: AppStyles.textXs,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unclaimedCount > 0)
                  DuoBadge(
                    text: '$unclaimedCount',
                    variant: DuoBadgeVariant.warning,
                    size: DuoBadgeSize.sm,
                    style: DuoBadgeStyle.solid,
                  ),
                SizedBox(width: AppStyles.space2),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
              ],
            ),

            // Progress bar
            SizedBox(height: AppStyles.space3),
            DuoProgressBar(
              progress: totalAchievements > 0
                  ? totalUnlocked / totalAchievements
                  : 0,
              progressColor: AppColors.purple,
              shadowColor: AppColors.purpleDark,
              height: 8,
            ),

            // Near completion achievements
            if (nearCompletion.isNotEmpty) ...[
              SizedBox(height: AppStyles.space3),
              Text(
                'Sắp hoàn thành',
                style: TextStyle(
                  fontSize: AppStyles.textXs,
                  fontWeight: AppStyles.fontSemibold,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppStyles.space2),
              ...nearCompletion.map((achievement) => Padding(
                    padding: EdgeInsets.only(bottom: AppStyles.space2),
                    child: _buildNearCompletionItem(achievement),
                  )),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildNearCompletionItem(Achievement achievement) {
    final tierColor = Color(
      AchievementTierHelper.getTierColorValue(achievement.tier),
    );

    return Row(
      children: [
        Image.asset(
          AchievementIcons.getAchievementAsset(achievement),
          width: 18,
          height: 18,
        ),
        SizedBox(width: AppStyles.space2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.name,
                style: TextStyle(fontSize: AppStyles.textXs),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppStyles.space1),
              DuoProgressBar(
                progress: achievement.progress,
                progressColor: tierColor,
                height: 4,
                showShimmer: false,
              ),
            ],
          ),
        ),
        SizedBox(width: AppStyles.space2),
        Text(
          '${achievement.progressPercent}%',
          style: TextStyle(
            fontSize: AppStyles.textXs,
            fontWeight: AppStyles.fontSemibold,
            color: tierColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingCard() {
    return DuoCard(
      onTap: () => Get.toNamed(Routes.achievements),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AppAssets.crown, width: 28, height: 28),
              SizedBox(width: AppStyles.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thành tựu',
                      style: TextStyle(
                        fontWeight: AppStyles.fontBold,
                        fontSize: AppStyles.textBase,
                      ),
                    ),
                    Text(
                      'Đang tải...',
                      style: TextStyle(
                        fontSize: AppStyles.textXs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppStyles.space2),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.purple,
                ),
              ),
              SizedBox(width: AppStyles.space2),
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
          SizedBox(height: AppStyles.space3),
          DuoProgressBar(
            progress: 0,
            progressColor: AppColors.purple,
            shadowColor: AppColors.purpleDark,
            height: 8,
          ),
        ],
      ),
    );
  }
}
