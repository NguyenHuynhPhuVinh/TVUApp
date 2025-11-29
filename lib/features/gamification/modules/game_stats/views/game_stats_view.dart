import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/extensions/animation_extensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/components/widgets.dart';
import '../../../shared/widgets/game_widgets.dart';

import '../controllers/game_stats_controller.dart';

class GameStatsView extends GetView<GameStatsController> {
  const GameStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppStyles.space6),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Header with icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.school_rounded,
                    size: 40.w,
                    color: AppColors.primary,
                  ),
                ),
              ).animateBounce(scaleBegin: 0),

              SizedBox(height: AppStyles.space4),

              // Title
              Text(
                'Thống kê học tập',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ).animateFadeSlide(delay: 200),

              SizedBox(height: 32.h),

              // Stats Card
              DuoStatCard(
                title: 'KẾT QUẢ CHUYÊN CẦN',
                backgroundColor: _getColorByRate(controller.attendanceRate),
                shadowColor: _getDarkColorByRate(controller.attendanceRate),
                stats: [
                  DuoStatItem(
                    label: 'Tổng tiết',
                    value: '${controller.totalLessons}',
                  ),
                  DuoStatItem(
                    label: 'Đã học',
                    value: '${controller.attendedLessons}',
                  ),
                  DuoStatItem(
                    label: 'Nghỉ',
                    value: '${controller.missedLessons}',
                  ),
                ],
              ).animateFadeSlide(delay: 300),

              SizedBox(height: 24.h),

              // Attendance Rate Card
              DuoAttendanceRateCard(rate: controller.attendanceRate)
                  .animateFadeSlide(delay: 500),

              SizedBox(height: 24.h),

              // Message Card
              DuoFeedbackCard.fromAttendanceRate(controller.attendanceRate)
                  .animateFadeSlide(delay: 700),

              SizedBox(height: 40.h),

              // Continue Button
              DuoButton(
                text: 'Xem phần thưởng',
                variant: DuoButtonVariant.success,
                onPressed: controller.continueToRewards,
              ).animateFadeSlide(delay: 900, slideBegin: 0.2),

              SizedBox(height: 20.h),
            ],
          ),
        ),
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



