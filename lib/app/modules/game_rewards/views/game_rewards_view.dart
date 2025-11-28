import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/game_rewards_controller.dart';

class GameRewardsView extends GetView<GameRewardsController> {
  const GameRewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Start confetti when all cards shown
    Future.delayed(const Duration(milliseconds: 2500), () {
      confettiController.play();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppStyles.space6),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Header icon
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        size: 36.w,
                        color: AppColors.green,
                      ),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                  SizedBox(height: AppStyles.space4),

                  // Title
                  Text(
                    'Phần thưởng của bạn',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                  SizedBox(height: AppStyles.space1),

                  Text(
                    'Dựa trên thành tích học tập',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

                  SizedBox(height: 32.h),

                  // Coins Card
                  Obx(() => controller.showCoins.value
                      ? DuoRewardRow(
                          iconPath: AppAssets.coin,
                          fallbackIcon: Icons.monetization_on_rounded,
                          label: 'Coins',
                          value: controller.animatedCoins.value,
                          color: AppColors.yellow,
                          bgColor: AppColors.yellowSoft,
                        )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.1, end: 0)
                      : SizedBox(height: 72.h)),

                  SizedBox(height: 12.h),

                  // Diamonds Card
                  Obx(() => controller.showDiamonds.value
                      ? DuoRewardRow(
                          iconPath: AppAssets.diamond,
                          fallbackIcon: Icons.diamond_rounded,
                          label: 'Diamonds',
                          value: controller.animatedDiamonds.value,
                          color: AppColors.primary,
                          bgColor: AppColors.primarySoft,
                        )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 0.1, end: 0)
                      : SizedBox(height: 72.h)),

                  SizedBox(height: 12.h),

                  SizedBox(height: 24.h),

                  // XP Progress Animation - chạy vèo vèo qua các level
                  Obx(() => controller.showLevel.value
                      ? DuoXpProgress(
                          totalXp: controller.earnedXp,
                          finalLevel: controller.level,
                          onComplete: () => controller.showButton.value = true,
                        )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0)
                      : SizedBox(height: 120.h)),

                  SizedBox(height: 40.h),

                  // Continue Button
                  Obx(() => controller.showButton.value
                      ? DuoButton(
                          text: 'Bắt đầu học',
                          variant: DuoButtonVariant.success,
                          onPressed: controller.continueToMain,
                        )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0)
                      : const SizedBox.shrink()),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.yellow,
                AppColors.primary,
                AppColors.green,
                AppColors.purple,
                AppColors.orange,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
