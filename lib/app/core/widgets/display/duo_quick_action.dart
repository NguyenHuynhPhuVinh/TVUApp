import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';

/// Item action nhanh trong grid
class DuoQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool showBadge;

  const DuoQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return DuoPressableCard(
      padding: EdgeInsets.all(AppStyles.space2),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(AppStyles.space2),
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(color, 0.1),
                  borderRadius: AppStyles.roundedLg,
                ),
                child: Icon(icon, size: AppStyles.iconMd, color: color),
              ),
              if (showBadge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.backgroundWhite, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppStyles.space1),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: AppStyles.fontSemibold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
