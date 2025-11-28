import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/components/widgets.dart';
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
              SizedBox(height: 40.h),

              // Mascot
              const TVUMascot(
                mood: TVUMascotMood.happy,
                size: TVUMascotSize.lg,
                color: AppColors.primary,
                hasAnimation: false,
              ),

              SizedBox(height: AppStyles.space6),

              // Title
              Text(
                'Chào mừng bạn!',
                style: TextStyle(
                  fontSize: AppStyles.text2xl,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: AppStyles.space2),

              Text(
                'Cho mình biết bạn đã nghỉ học\nbao nhiêu buổi từ trước tới nay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 40.h),

              // Number input
              Obx(() => DuoNumberInput(
                    controller: controller.missedSessionsController,
                    label: 'Số buổi đã nghỉ',
                    subtitle: '1 buổi = 4 tiết',
                    hint: '0',
                    icon: Icons.event_busy_rounded,
                    iconColor: AppColors.orange,
                    maxValue: controller.maxMissedSessions,
                  )),

              SizedBox(height: AppStyles.space3),

              Text(
                'Nhập 0 nếu bạn chưa nghỉ buổi nào',
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textTertiary,
                ),
              ),

              SizedBox(height: 48.h),

              // Button
              Obx(() => DuoButton(
                    text: 'Tiếp tục',
                    variant: DuoButtonVariant.success,
                    isLoading: controller.isCalculating.value,
                    onPressed: controller.startCalculation,
                  )),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}



