import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
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
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              SizedBox(height: AppStyles.space4),

              // Title
              Text(
                'Thống kê học tập',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

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
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              SizedBox(height: 24.h),

              // Attendance Rate Card
              DuoAttendanceRateCard(rate: controller.attendanceRate)
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              SizedBox(height: 24.h),

              // Message Card
              DuoFeedbackMessage.fromAttendanceRate(controller.attendanceRate)
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 400.ms),

              SizedBox(height: 40.h),

              // Continue Button
              DuoButton(
                text: 'Xem phần thưởng',
                variant: DuoButtonVariant.success,
                onPressed: controller.continueToRewards,
              )
                  .animate()
                  .fadeIn(delay: 900.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

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
