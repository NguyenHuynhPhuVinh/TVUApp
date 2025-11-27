import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = controller;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            ..._buildFloatingParticles(),
            Column(
              children: [
                const Spacer(flex: 2),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedLogo(),
                      SizedBox(height: AppStyles.space8),
                      _buildAnimatedTitle(),
                      SizedBox(height: AppStyles.space2),
                      _buildAnimatedSubtitle(),
                      SizedBox(height: AppStyles.space12),
                      Obx(() => controller.isFirstTimeSync.value
                          ? _buildSyncProgress()
                          : const DuoLoadingDots()),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                _buildFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    final colors = [AppColors.green, AppColors.orange, AppColors.purple, Colors.white];
    final sizes = [8.0, 12.0, 16.0, 10.0];
    final positions = [
      Offset(30.w, 100.h),
      Offset(320.w, 150.h),
      Offset(50.w, 400.h),
      Offset(300.w, 500.h),
      Offset(80.w, 600.h),
      Offset(280.w, 300.h),
      Offset(150.w, 200.h),
      Offset(200.w, 550.h),
    ];

    return List.generate(8, (index) {
      return Positioned(
        left: positions[index].dx,
        top: positions[index].dy,
        child: Container(
          width: sizes[index % 4].w,
          height: sizes[index % 4].w,
          decoration: BoxDecoration(
            color: AppColors.withAlpha(colors[index % 4], 0.6),
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 600.ms, delay: (index * 100).ms)
            .then()
            .moveY(begin: 0, end: -20, duration: (1500 + index * 200).ms, curve: Curves.easeInOut)
            .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: (1800 + index * 150).ms),
      );
    });
  }

  Widget _buildAnimatedLogo() {
    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space8),
      backgroundColor: AppColors.backgroundWhite,
      shadowColor: AppColors.primaryDark,
      shadowOffset: AppStyles.shadowLg,
      borderRadius: AppStyles.rounded4xl,
      hasBorder: false,
      child: Icon(Icons.school_rounded, size: AppStyles.icon3xl * 1.5, color: AppColors.primary),
    )
        .animate()
        .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 2000.ms, color: AppColors.withAlpha(Colors.white, 0.3));
  }

  Widget _buildAnimatedTitle() {
    return Text(
      'TVU Sinh Viên',
      style: TextStyle(
        fontSize: AppStyles.text5xl,
        fontWeight: AppStyles.fontExtrabold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildAnimatedSubtitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space4, vertical: AppStyles.space2),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: AppStyles.roundedFull,
      ),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: AppStyles.textSm, fontWeight: AppStyles.fontSemibold, color: Colors.white),
        child: AnimatedTextKit(
          animatedTexts: [TypewriterAnimatedText('Cổng thông tin Sinh viên', speed: const Duration(milliseconds: 80))],
          isRepeatingAnimation: false,
          displayFullTextOnTap: true,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildSyncProgress() {
    return Column(
      children: [
        SizedBox(
          width: 200.w,
          child: Obx(() => DuoProgressBar(
                progress: controller.syncProgress.value,
                backgroundColor: AppColors.primaryDark,
                progressColor: Colors.white,
                shadowColor: AppColors.withAlpha(Colors.white, 0.3),
              )),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0, duration: 400.ms),
        SizedBox(height: AppStyles.space4),
        Obx(() => Text(
              controller.syncStatus.value,
              style: TextStyle(fontSize: AppStyles.textSm, fontWeight: AppStyles.fontSemibold, color: Colors.white),
            ).animate().fadeIn(duration: 300.ms)),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppStyles.space6),
      child: Column(
        children: [
          const DuoVersionBadge(version: 'v1.0'),
          SizedBox(height: AppStyles.space3),
          Text(
            'Tạo bởi TomiSakae',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontSemibold,
              color: AppColors.withAlpha(Colors.white, 0.8),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 1000.ms).slideY(begin: 0.5, end: 0, duration: 500.ms);
  }
}
