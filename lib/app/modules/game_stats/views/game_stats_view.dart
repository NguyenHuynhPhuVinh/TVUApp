import 'package:confetti/confetti.dart';
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
    final confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Start confetti after level animation
    Future.delayed(const Duration(milliseconds: 1800), () {
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
                  SizedBox(height: 10.h),

                  // Mascot
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showStats.value ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: const TVUMascot(
                          mood: TVUMascotMood.excited,
                          size: TVUMascotSize.md,
                          color: AppColors.green,
                        ),
                      )),

                  // Title
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showStats.value ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            Text(
                              '🎉 Chúc mừng!',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: AppStyles.fontBold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppStyles.space1),
                            Text(
                              'Đây là thành tích học tập của bạn',
                              style: TextStyle(
                                fontSize: AppStyles.textBase,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )),

                  SizedBox(height: 24.h),

                  // Attendance Card using DuoAttendanceCard
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showStats.value ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: DuoAttendanceCard(
                          attendanceRate: controller.attendanceRate,
                          totalLessons: controller.totalLessons,
                          attendedLessons: controller.attendedLessons,
                          missedLessons: controller.missedLessons,
                          animated: false,
                        ),
                      )),

                  SizedBox(height: 20.h),

                  // Rewards Section using DuoRewardCard
                  Row(
                    children: [
                      // Coins Card
                      Expanded(
                        child: Obx(() => AnimatedOpacity(
                              opacity: controller.showCoins.value ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: _buildAnimatedRewardCard(
                                type: 'coin',
                                value: controller.animatedCoins.value,
                                show: controller.showCoins.value,
                              ),
                            )),
                      ),
                      SizedBox(width: AppStyles.space3),
                      // Diamonds Card
                      Expanded(
                        child: Obx(() => AnimatedOpacity(
                              opacity: controller.showDiamonds.value ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: _buildAnimatedRewardCard(
                                type: 'diamond',
                                value: controller.animatedDiamonds.value,
                                show: controller.showDiamonds.value,
                              ),
                            )),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Level Card using DuoLevelCard
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showLevel.value ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: DuoLevelCard(
                          level: controller.animatedLevel.value,
                          currentXp: controller.earnedXp % (controller.level * 100),
                          xpToNextLevel: controller.level * 100,
                          earnedXp: controller.animatedXp.value,
                          animated: false,
                        ),
                      ))
                      .animate(target: controller.showLevel.value ? 1 : 0)
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        curve: Curves.easeOutBack,
                        duration: 600.ms,
                      ),

                  SizedBox(height: 32.h),

                  // Continue Button
                  Obx(() => AnimatedOpacity(
                        opacity: controller.showButton.value ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: DuoButton(
                          text: 'Bắt đầu hành trình!',
                          variant: DuoButtonVariant.success,
                          icon: Icons.rocket_launch_rounded,
                          onPressed: controller.continueToMain,
                        ),
                      ))
                      .animate(target: controller.showButton.value ? 1 : 0)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 400.ms,
                      ),

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

  Widget _buildAnimatedRewardCard({
    required String type,
    required int value,
    required bool show,
  }) {
    Widget card;
    if (type == 'coin') {
      card = DuoRewardCard.coin(value: value, animated: false);
    } else {
      card = DuoRewardCard.diamond(value: value, animated: false);
    }

    return card
        .animate(target: show ? 1 : 0)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 800.ms,
        );
  }
}
