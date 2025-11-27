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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppStyles.space6),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    '🎁 Phần thưởng!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.3, end: 0),

                  SizedBox(height: 4.h),

                  Text(
                    'Dựa trên thành tích học tập',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  SizedBox(height: 40.h),

                  // Coins Card - BIG
                  Obx(() => controller.showCoins.value
                      ? _buildCoinsCard()
                      : const SizedBox.shrink()),

                  SizedBox(height: 16.h),

                  // Diamonds Card
                  Obx(() => controller.showDiamonds.value
                      ? _buildDiamondsCard()
                      : const SizedBox.shrink()),

                  SizedBox(height: 16.h),

                  // Level Card
                  Obx(() => controller.showLevel.value
                      ? _buildLevelCard()
                      : const SizedBox.shrink()),

                  SizedBox(height: 40.h),

                  // Continue Button
                  Obx(() => controller.showButton.value
                      ? _buildContinueButton()
                      : const SizedBox.shrink()),

                  SizedBox(height: 30.h),
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

  Widget _buildCoinsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space5,
        vertical: AppStyles.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        borderRadius: AppStyles.rounded2xl,
        border: Border.all(
          color: AppColors.yellow.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon with glow
          Container(
            padding: EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppColors.glowEffect(AppColors.yellow, blur: 15, spread: 3),
            ),
            child: Image.asset(
              'assets/game/currency/coin_golden_coin_1st_64px.png',
              width: 44.w,
              height: 44.w,
              errorBuilder: (_, __, ___) => Icon(
                Icons.monetization_on_rounded,
                size: 44.w,
                color: AppColors.yellow,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
              ),
          SizedBox(width: AppStyles.space3),
          // Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COINS',
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    fontWeight: AppStyles.fontBold,
                    color: AppColors.yellow,
                    letterSpacing: 1,
                  ),
                ),
                Obx(() => Text(
                      '+${_formatNumber(controller.animatedCoins.value)}',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: AppStyles.fontExtrabold,
                        color: AppColors.textPrimary,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 600.ms,
        );
  }

  Widget _buildDiamondsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppStyles.rounded2xl,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/game/currency/diamond_blue_diamond_1st_64px.png',
            width: 40.w,
            height: 40.w,
            errorBuilder: (_, __, ___) => Icon(
              Icons.diamond_rounded,
              size: 40.w,
              color: AppColors.primary,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -0.05, end: 0.05, duration: 500.ms),
          SizedBox(width: AppStyles.space3),
          Text(
            'DIAMONDS',
            style: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontBold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Obx(() => Text(
                '+${controller.animatedDiamonds.value}',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              )),
        ],
      ),
    )
        .animate()
        .slideX(begin: -1, end: 0, duration: 500.ms)
        .fadeIn();
  }

  Widget _buildLevelCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppStyles.space5),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: AppStyles.rounded2xl,
        boxShadow: AppColors.buttonBoxShadow(AppColors.purpleDark),
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.yellow, width: 3),
            ),
            child: Center(
              child: Image.asset(
                'assets/game/main/star_golden_star_1st_64px.png',
                width: 32.w,
                height: 32.w,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.star_rounded,
                  size: 32.w,
                  color: AppColors.yellow,
                ),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 800.ms,
              ),
          SizedBox(width: AppStyles.space4),
          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CẤP ĐỘ',
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    fontWeight: AppStyles.fontBold,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1,
                  ),
                ),
                Obx(() => Text(
                      'Level ${controller.animatedLevel.value}',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: AppStyles.fontBold,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
          ),
          // XP earned
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'XP',
                style: TextStyle(
                  fontSize: AppStyles.textXs,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Obx(() => Text(
                    '+${_formatNumber(controller.animatedXp.value)}',
                    style: TextStyle(
                      fontSize: AppStyles.textXl,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.yellow,
                    ),
                  )),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideX(begin: 1, end: 0, duration: 500.ms)
        .fadeIn();
  }

  Widget _buildContinueButton() {
    return Column(
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
    )
        .animate()
        .slideY(begin: 0.5, end: 0, duration: 400.ms)
        .fadeIn();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
