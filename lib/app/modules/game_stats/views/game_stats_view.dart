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
        child: Padding(
          padding: EdgeInsets.all(AppStyles.space6),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Mascot
              const TVUMascot(
                mood: TVUMascotMood.happy,
                size: TVUMascotSize.md,
                color: AppColors.primary,
              ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

              SizedBox(height: AppStyles.space4),

              // Title
              Text(
                'Thống kê học tập',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),

              SizedBox(height: AppStyles.space2),

              Text(
                'Đây là kết quả chuyên cần của bạn',
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 400.ms),

              SizedBox(height: 32.h),

              // Attendance Card
              DuoAttendanceCard(
                attendanceRate: controller.attendanceRate,
                totalLessons: controller.totalLessons,
                attendedLessons: controller.attendedLessons,
                missedLessons: controller.missedLessons,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

              SizedBox(height: 24.h),

              // Summary message using DuoMessageCard
              DuoMessageCard.fromAttendance(controller.attendanceRate)
                  .animate()
                  .fadeIn(delay: 800.ms)
                  .slideY(begin: 0.2, end: 0),

              const Spacer(),

              // Continue Button
              DuoButton(
                text: 'Xem phần thưởng',
                variant: DuoButtonVariant.success,
                icon: Icons.card_giftcard_rounded,
                onPressed: controller.continueToRewards,
              ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
