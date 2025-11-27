import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppStyles.space6),
            child: Column(
              children: [
                SizedBox(height: AppStyles.space10),
                const TVUMascot(
                  mood: TVUMascotMood.happy,
                  size: TVUMascotSize.lg,
                  hasGlow: true,
                  hasAnimation: true,
                  hasHat: true,
                ),
                SizedBox(height: AppStyles.space6),
                _buildWelcomeText(),
                SizedBox(height: AppStyles.space8),
                _buildLoginForm(),
                SizedBox(height: AppStyles.space6),
                _buildLoginButton(),
                SizedBox(height: AppStyles.space4),
                _buildErrorMessage(),
                SizedBox(height: AppStyles.space8),
                _buildFooterDecoration(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontSize: AppStyles.text2xl,
                fontWeight: AppStyles.fontBold,
                color: AppColors.textPrimary,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText('Chào mừng đến TVU!', speed: const Duration(milliseconds: 100)),
                ],
                isRepeatingAnimation: false,
                displayFullTextOnTap: true,
              ),
            ),
            SizedBox(width: AppStyles.space2),
            Icon(Icons.school_rounded, color: AppColors.primary, size: AppStyles.iconLg),
          ],
        ),
        SizedBox(height: AppStyles.space2),
        Text(
          'Đăng nhập để bắt đầu hành trình học tập',
          style: TextStyle(fontSize: AppStyles.textBase, color: AppColors.textSecondary),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        DuoInput(
          controller: controller.usernameController,
          label: 'Mã số sinh viên',
          hint: 'Nhập MSSV của bạn',
          prefixIcon: Iconsax.user,
          iconColor: AppColors.primary,
          keyboardType: TextInputType.number,
        ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: -0.2, end: 0),
        SizedBox(height: AppStyles.space4),
        Obx(() => DuoInput(
              controller: controller.passwordController,
              label: 'Mật khẩu',
              hint: 'Nhập mật khẩu',
              prefixIcon: Iconsax.lock,
              iconColor: AppColors.purple,
              isPassword: true,
              isPasswordVisible: controller.isPasswordVisible.value,
              onTogglePassword: controller.togglePasswordVisibility,
            )).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideX(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => DuoButton(
          text: 'BẮT ĐẦU HỌC THÔI!',
          icon: Iconsax.login,
          variant: DuoButtonVariant.primary,
          size: DuoButtonSize.xl,
          isLoading: controller.isLoading.value,
          onPressed: controller.login,
        ))
        .animate()
        .fadeIn(duration: 500.ms, delay: 800.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
      return DuoAlert(
        message: controller.errorMessage.value,
        variant: DuoAlertVariant.error,
        animated: true,
      );
    });
  }

  Widget _buildFooterDecoration() {
    final colors = [AppColors.orange, AppColors.primary, AppColors.green, AppColors.purple];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppStyles.space1),
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: colors[index],
              shape: BoxShape.circle,
              boxShadow: AppColors.glowEffect(colors[index]),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 1000.ms,
                delay: (index * 100).ms,
                curve: Curves.easeInOut,
              ),
        );
      }),
    ).animate().fadeIn(duration: 500.ms, delay: 1000.ms);
  }
}
