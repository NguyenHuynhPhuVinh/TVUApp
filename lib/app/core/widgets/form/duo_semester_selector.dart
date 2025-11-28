import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';

/// Widget chọn học kỳ
class DuoSemesterSelector extends StatelessWidget {
  final String tenHocKy;
  final bool isCurrent;
  final VoidCallback? onTap;

  const DuoSemesterSelector({
    super.key,
    required this.tenHocKy,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppStyles.space4,
        AppStyles.space4,
        AppStyles.space4,
        AppStyles.space2,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: DuoCard(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyles.space4,
            vertical: AppStyles.space3,
          ),
          child: Row(
            children: [
              _buildIcon(),
              SizedBox(width: AppStyles.space3),
              Expanded(child: _buildContent()),
              if (isCurrent) _buildCurrentBadge(),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(AppStyles.space2),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(AppColors.primary, 0.1),
        borderRadius: AppStyles.roundedLg,
      ),
      child: Icon(
        Iconsax.calendar_1,
        color: AppColors.primary,
        size: AppStyles.iconSm,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Học kỳ',
          style: TextStyle(
            fontSize: AppStyles.textXs,
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          tenHocKy,
          style: TextStyle(
            fontSize: AppStyles.textBase,
            fontWeight: AppStyles.fontSemibold,
            color: isCurrent ? AppColors.primary : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCurrentBadge() {
    return Container(
      margin: EdgeInsets.only(right: AppStyles.space2),
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space2,
        vertical: AppStyles.space1,
      ),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: AppStyles.roundedFull,
      ),
      child: Text(
        'Hiện tại',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: AppStyles.fontBold,
          color: AppColors.green,
        ),
      ),
    );
  }
}
