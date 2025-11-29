import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../data/achievement_icons.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';

/// Widget filter theo category
class DuoCategoryFilter extends StatelessWidget {
  final AchievementCategory? selectedCategory;
  final Function(AchievementCategory?) onCategorySelected;
  final String Function(AchievementCategory) getCategoryIcon;
  final String Function(AchievementCategory) getCategoryName;

  const DuoCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.getCategoryIcon,
    required this.getCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppStyles.space1),
        child: Row(
          children: [
            // All categories
            _buildCategoryChip(
              context,
              asset: AppAssets.crown,
              label: 'Tất cả',
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
            ),
            SizedBox(width: AppStyles.space2),
            // Each category
            ...AchievementCategory.values.map((category) {
              return Padding(
                padding: EdgeInsets.only(right: AppStyles.space2),
                child: _buildCategoryChip(
                  context,
                  asset: _getCategoryAsset(category),
                  label: getCategoryName(category),
                  isSelected: selectedCategory == category,
                  onTap: () => onCategorySelected(category),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getCategoryAsset(AchievementCategory category) {
    return AchievementIcons.getCategoryAsset(category);
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String asset,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppStyles.durationFast,
        padding: EdgeInsets.symmetric(
          horizontal: AppStyles.space3,
          vertical: AppStyles.space2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundWhite,
          borderRadius: AppStyles.roundedFull,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: AppStyles.border2,
          ),
          boxShadow: isSelected
              ? AppColors.buttonBoxShadow(AppColors.primaryDark, offset: 3)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              asset,
              width: 18,
              height: 18,
              color: isSelected ? Colors.white : null,
              colorBlendMode: isSelected ? BlendMode.srcIn : null,
            ),
            SizedBox(width: AppStyles.space2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight:
                    isSelected ? AppStyles.fontSemibold : AppStyles.fontMedium,
                fontSize: AppStyles.textSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
