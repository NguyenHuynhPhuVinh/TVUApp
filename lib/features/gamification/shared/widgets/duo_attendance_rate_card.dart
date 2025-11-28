import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/components/widgets.dart';

class DuoAttendanceRateCard extends StatelessWidget {
  final double rate;
  final String? title;

  const DuoAttendanceRateCard({
    super.key,
    required this.rate,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorByRate(rate);

    return DuoCard(
      child: Column(
        children: [
          Text(
            title ?? 'Tỷ lệ chuyên cần',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppStyles.space3),
          Text(
            '${rate.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: AppStyles.fontBold,
              color: color,
            ),
          ),
          SizedBox(height: AppStyles.space3),
          DuoProgressBar(
            progress: rate / 100,
            height: 12.h,
            progressColor: color,
            shadowColor: _getDarkColorByRate(rate),
            showShimmer: false,
          ),
        ],
      ),
    );
  }

  Color _getColorByRate(double rate) {
    if (rate >= 80) return AppColors.green;
    if (rate >= 50) return AppColors.orange;
    return AppColors.red;
  }

  Color _getDarkColorByRate(double rate) {
    if (rate >= 80) return AppColors.greenDark;
    if (rate >= 50) return AppColors.orangeDark;
    return AppColors.redDark;
  }
}




