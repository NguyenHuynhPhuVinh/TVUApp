import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/game_rewards_controller.dart';

class GameRewardsView extends GetView<GameRewardsController> {
  const GameRewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final confettiController =
        ConfettiController(duration: const Duration(seconds: 4));

    // Start confetti when level shows
    Future.delayed(const Duration(milliseconds: 2100), () {
      confettiController.play();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primarySoft,
                  AppColors.background,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppStyles.space6),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    '🎁 Phần thưởng của bạn!',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.3, end: 0),

                  SizedBox(height: 8.h),

                  Text(
                    'Dựa trên thành tích học tập của bạn',
                    style: TextStyle(
                      fontSize: AppStyles.textBase,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  SizedBox(height: 40.h),

                  // Coins Card - BIG using DuoBigRewardRow
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showCoins.value ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: DuoBigRewardRow.coin(
                          value: controller.animatedCoins.value,
                          animated: false,
                        ),
                      ))
                      .animate(target: controller.showCoins.value ? 1 : 0)
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: 800.ms,
                      ),

                  SizedBox(height: 16.h),

                  // Diamonds Card using DuoMediumRewardRow
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showDiamonds.value ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: DuoMediumRewardRow.diamond(
                          value: controller.animatedDiamonds.value,
                          animated: false,
                        ),
                      ))
                      .animate(target: controller.showDiamonds.value ? 1 : 0)
                      .slideX(begin: -1, end: 0, duration: 500.ms)
                      .fadeIn(),

                  SizedBox(height: 16.h),

                  // Level Card using DuoLevelCard
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showLevel.value ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: DuoLevelCard(
                          level: controller.animatedLevel.value,
                          currentXp: controller.earnedXp % (controller.level * 100),
                          xpToNextLevel: controller.level * 100,
                          earnedXp: controller.animatedXp.value,
                          showProgress: false,
                          animated: false,
                        ),
                      ))
                      .animate(target: controller.showLevel.value ? 1 : 0)
                      .slideX(begin: 1, end: 0, duration: 500.ms)
                      .fadeIn(),

                  const Spacer(),

                  // Continue Button
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showButton.value ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            DuoButton(
                              text: 'Bắt đầu hành trình!',
                              variant: DuoButtonVariant.success,
                              icon: Icons.rocket_launch_rounded,
                              onPressed: controller.continueToMain,
                            ),
                            SizedBox(height: AppStyles.space3),
                            Text(
                              'Tiếp tục học để nhận thêm phần thưởng!',
                              style: TextStyle(
                                fontSize: AppStyles.textSm,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ))
                      .animate(target: controller.showButton.value ? 1 : 0)
                      .slideY(begin: 0.5, end: 0, duration: 400.ms),

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
              numberOfParticles: 40,
              gravity: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}
