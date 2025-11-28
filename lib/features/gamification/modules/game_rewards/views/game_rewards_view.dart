import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/extensions/animation_extensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/components/widgets.dart';
import '../../../shared/widgets/game_widgets.dart';
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
                  ).animateBounce(scaleBegin: 0),

                  SizedBox(height: AppStyles.space4),

                  // Title
                  Text(
                    'Phần thưởng của bạn',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.textPrimary,
                    ),
                  ).animateFadeSlide(delay: 200),

                  SizedBox(height: AppStyles.space1),

                  Text(
                    'Dựa trên thành tích học tập',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: AppColors.textSecondary,
                    ),
                  ).animateFadeSlide(delay: 300),

                  SizedBox(height: 32.h),

                  // Coins Card
                  Obx(() => controller.showCoins.value
                      ? DuoRewardTile.coin(
                          value: controller.animatedCoins.value,
                          size: DuoRewardTileSize.md,
                        ).animateFadeSlideLeft(slideBegin: -0.1)
                      : SizedBox(height: 72.h)),

                  SizedBox(height: 12.h),

                  // Diamonds Card
                  Obx(() => controller.showDiamonds.value
                      ? DuoRewardTile.diamond(
                          value: controller.animatedDiamonds.value,
                          size: DuoRewardTileSize.md,
                        ).animateFadeSlideRight(slideBegin: 0.1)
                      : SizedBox(height: 72.h)),

                  SizedBox(height: 12.h),

                  SizedBox(height: 24.h),

                  // XP Progress Animation - chạy vèo vèo qua các level
                  Obx(() => controller.showLevel.value
                      ? DuoXpProgress(
                          totalXp: controller.earnedXp,
                          finalLevel: controller.level,
                          onComplete: () => controller.showButton.value = true,
                        ).animateFadeSlide()
                      : SizedBox(height: 120.h)),

                  SizedBox(height: 40.h),

                  // Continue Button
                  Obx(() => controller.showButton.value
                      ? DuoButton(
                          text: 'Bắt đầu học',
                          variant: DuoButtonVariant.success,
                          onPressed: controller.continueToMain,
                        ).animateFadeSlide()
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



