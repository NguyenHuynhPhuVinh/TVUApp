import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/components/widgets.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() => controller.showLoginForm.value
            ? _buildLoginScreen()
            : _buildIntroScreen()),
      ),
    );
  }

  /// Màn hình giới thiệu ban đầu
  Widget _buildIntroScreen() {
    return SingleChildScrollView(
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
            _buildIntroWelcomeText(),
            SizedBox(height: AppStyles.space8),
            _buildIntroFeatures(),
            SizedBox(height: AppStyles.space8),
            _buildLoginWithTTSVButton(),
            SizedBox(height: AppStyles.space8),
            _buildFooterDecoration(),
            SizedBox(height: AppStyles.space10),
          ],
        ),
      ),
    );
  }

  /// Màn hình form đăng nhập
  Widget _buildLoginScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space6),
        child: Column(
          children: [
            SizedBox(height: AppStyles.space6),
            _buildBackButton(),
            SizedBox(height: AppStyles.space4),
            const TVUMascot(
              mood: TVUMascotMood.happy,
              size: TVUMascotSize.md,
              hasGlow: true,
              hasAnimation: true,
              hasHat: true,
            ),
            SizedBox(height: AppStyles.space4),
            _buildWelcomeText(),
            SizedBox(height: AppStyles.space6),
            _buildLoginForm(),
            SizedBox(height: AppStyles.space4),
            _buildTermsCheckbox(),
            SizedBox(height: AppStyles.space4),
            _buildLoginButton(),
            SizedBox(height: AppStyles.space4),
            _buildErrorMessage(),
            SizedBox(height: AppStyles.space8),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: controller.hideForm,
        child: Container(
          padding: EdgeInsets.all(AppStyles.space2),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: AppStyles.roundedFull,
          ),
          child: Icon(
            Iconsax.arrow_left,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildIntroWelcomeText() {
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
                  WavyAnimatedText('TVU App', speed: const Duration(milliseconds: 100)),
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
          'Ứng dụng hỗ trợ sinh viên TVU',
          style: TextStyle(fontSize: AppStyles.textLg, color: AppColors.textSecondary),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildIntroFeatures() {
    final features = [
      {'icon': Iconsax.calendar, 'text': 'Xem thời khóa biểu', 'color': AppColors.primary},
      {'icon': Iconsax.chart, 'text': 'Tra cứu điểm học tập', 'color': AppColors.green},
      {'icon': Iconsax.wallet, 'text': 'Quản lý học phí', 'color': AppColors.orange},
      {'icon': Iconsax.game, 'text': 'Trò chơi hóa học tập', 'color': AppColors.purple},
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: AppStyles.space3),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: (feature['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: AppStyles.roundedLg,
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: feature['color'] as Color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppStyles.space3),
              Text(
                feature['text'] as String,
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: AppColors.textPrimary,
                  fontWeight: AppStyles.fontMedium,
                ),
              ),
            ],
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: (600 + index * 100).ms)
            .slideX(begin: -0.2, end: 0);
      }).toList(),
    );
  }

  Widget _buildLoginWithTTSVButton() {
    return DuoButton(
      text: 'Đăng nhập với TTSV',
      icon: Iconsax.login,
      variant: DuoButtonVariant.primary,
      size: DuoButtonSize.xl,
      onPressed: controller.showForm,
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1000.ms)
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

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Đăng nhập TTSV',
          style: TextStyle(
            fontSize: AppStyles.text2xl,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        SizedBox(height: AppStyles.space2),
        Text(
          'Sử dụng tài khoản Thông tin sinh viên',
          style: TextStyle(fontSize: AppStyles.textBase, color: AppColors.textSecondary),
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
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

  Widget _buildTermsCheckbox() {
    return Obx(() => DuoCheckbox(
          value: controller.acceptedTerms.value,
          onChanged: (_) => controller.toggleAcceptedTerms(),
          label: Row(
            children: [
              Text(
                'Tôi đồng ý với ',
                style: TextStyle(fontSize: AppStyles.textSm, color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => DuoTermsDialog.show(),
                child: Text(
                  'điều khoản sử dụng',
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    color: AppColors.primary,
                    fontWeight: AppStyles.fontSemibold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        )).animate().fadeIn(duration: 500.ms, delay: 700.ms);
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



