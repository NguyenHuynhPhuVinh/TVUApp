import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/game_setup_controller.dart';

class GameSetupView extends GetView<GameSetupController> {
  const GameSetupView({super.key});

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

              // Mascot
              const TVUMascot(
                mood: TVUMascotMood.excited,
                size: TVUMascotSize.lg,
                color: AppColors.yellow,
              ),

              SizedBox(height: AppStyles.space4),

              // Title
              Text(
                'Khởi tạo hành trình!',
                style: TextStyle(
                  fontSize: AppStyles.text2xl,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: AppStyles.space2),

              Text(
                'Hãy cho mình biết bạn đã nghỉ học bao nhiêu buổi\ntừ trước tới nay để tính toán thành tích',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 32.h),

              // Stats card using DuoStatCard
              Obx(() => DuoStatCard(
                    title: 'THỐNG KÊ HỌC TẬP',
                    backgroundColor: AppColors.primary,
                    shadowColor: AppColors.primaryDark,
                    stats: [
                      DuoStatItem(
                        label: 'Học kỳ',
                        value: '${controller.totalSemesters.value}',
                      ),
                      DuoStatItem(
                        label: 'Tổng tiết',
                        value: '${controller.totalLessons.value}',
                      ),
                      DuoStatItem(
                        label: 'Buổi tối đa',
                        value: '${controller.maxMissedSessions}',
                      ),
                    ],
                  )),

              SizedBox(height: 24.h),

              // Number input using DuoNumberInput
              Obx(() => DuoNumberInput(
                    controller: controller.missedSessionsController,
                    label: 'Số buổi đã nghỉ',
                    subtitle: '1 buổi = 4 tiết',
                    hint: '0',
                    icon: Icons.event_busy_rounded,
                    iconColor: AppColors.purple,
                    maxValue: controller.maxMissedSessions,
                  )),

              SizedBox(height: AppStyles.space2),

              Text(
                'Nhập 0 nếu bạn chưa nghỉ buổi nào',
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textTertiary,
                ),
              ),

              SizedBox(height: 32.h),

              // Button
              Obx(() => DuoButton(
                    text: 'Tính toán thành tích',
                    variant: DuoButtonVariant.success,
                    icon: Icons.calculate_rounded,
                    isLoading: controller.isCalculating.value,
                    onPressed: controller.startCalculation,
                  )),

              SizedBox(height: AppStyles.space4),

              Text(
                'Bạn có thể cập nhật sau trong phần Cài đặt',
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
