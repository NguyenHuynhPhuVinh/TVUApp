import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/achievements_controller.dart';
import '../widgets/duo_achievement_card.dart';
import '../widgets/duo_achievement_stats_card.dart';
import '../widgets/duo_category_filter.dart';
import '../../../../../core/components/widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';

class AchievementsView extends GetView<AchievementsController> {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Thành tựu',
        showLogo: false,
        leading: const DuoBackButton(),
        actions: [
          // Nút nhận tất cả
          Obx(() {
            if (controller.unclaimedCount == 0) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(right: AppStyles.space2),
              child: DuoButton(
                text: 'Nhận (${controller.unclaimedCount})',
                onPressed: controller.isClaiming.value
                    ? null
                    : controller.claimAllRewards,
                size: DuoButtonSize.sm,
                variant: DuoButtonVariant.purple,
                icon: Icons.redeem,
                fullWidth: false,
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.achievements.isEmpty) {
          return const Center(child: DuoLoadingDots());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAchievements,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Stats card
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppStyles.space4),
                  child: DuoAchievementStatsCard(
                    totalUnlocked: controller.totalUnlocked,
                    totalAchievements: controller.totalAchievements,
                    completionRate: controller.completionRate,
                    unclaimedCount: controller.unclaimedCount,
                    totalClaimableReward: controller.totalClaimableReward,
                  ),
                ),
              ),

              // Category filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
                  child: DuoCategoryFilter(
                    selectedCategory: controller.selectedCategory.value,
                    onCategorySelected: controller.selectCategory,
                    getCategoryIcon: controller.getCategoryIcon,
                    getCategoryName: controller.getCategoryName,
                  ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppStyles.space4,
                    vertical: AppStyles.space3,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Đã mở khóa',
                        isSelected: controller.showOnlyUnlocked.value,
                        onTap: controller.toggleUnlockedFilter,
                      ),
                      SizedBox(width: AppStyles.space3),
                      _buildFilterChip(
                        label: 'Có thể nhận',
                        isSelected: controller.showOnlyClaimable.value,
                        onTap: controller.toggleClaimableFilter,
                      ),
                    ],
                  ),
                ),
              ),

              // Achievement list
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final achievement =
                          controller.filteredAchievements[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppStyles.space3),
                        child: DuoAchievementCard(
                          achievement: achievement,
                          onClaim: () => controller.claimReward(achievement),
                        ),
                      );
                    },
                    childCount: controller.filteredAchievements.length,
                  ),
                ),
              ),

              // Empty state
              if (controller.filteredAchievements.isEmpty)
                SliverFillRemaining(
                  child: DuoEmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: 'Không có thành tựu nào',
                    subtitle: 'Thử thay đổi bộ lọc để xem thêm',
                  ),
                ),

              SliverPadding(
                  padding: EdgeInsets.only(bottom: AppStyles.space8)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppStyles.space3,
          vertical: AppStyles.space2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundWhite,
          borderRadius: AppStyles.roundedFull,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: AppStyles.textSm,
            fontWeight:
                isSelected ? AppStyles.fontSemibold : AppStyles.fontMedium,
          ),
        ),
      ),
    );
  }
}
