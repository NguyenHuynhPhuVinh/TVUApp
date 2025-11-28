import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/tuition_bonus_controller.dart';

class TuitionBonusView extends GetView<TuitionBonusController> {
  const TuitionBonusView({super.key});

  @override
  Widget build(BuildContext context) {
    // Bắt đầu animation khi view được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        controller.startCountAnimation();
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppStyles.space6),
          child: Column(
            children: [
              const Spacer(),
              
              // Icon tiền
              Image.asset(
                'assets/game/currency/cash_green_cash_1st_64px.png',
                width: 100.w,
                height: 100.w,
              ).animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),
              
              SizedBox(height: AppStyles.space6),
              
              // Title
              Text(
                'Thưởng học phí!',
                style: TextStyle(
                  fontSize: AppStyles.text2xl,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.green,
                ),
              ).animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.2),
              
              SizedBox(height: AppStyles.space2),
              
              // Subtitle
              Obx(() => Text(
                'Từ ${controller.formatCurrency(controller.tuitionPaid.value)} học phí đã đóng',
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )).animate()
                .fadeIn(delay: 400.ms),
              
              SizedBox(height: AppStyles.space8),
              
              // Animated balance
              DuoCard(
                backgroundColor: AppColors.greenSoft,
                child: Column(
                  children: [
                    Text(
                      'Bạn nhận được',
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppStyles.space2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/game/currency/cash_green_cash_1st_64px.png',
                          width: 32.w,
                          height: 32.w,
                        ),
                        SizedBox(width: AppStyles.space2),
                        Obx(() => Text(
                          controller.formatBalance(controller.displayedBalance.value),
                          style: TextStyle(
                            fontSize: AppStyles.text4xl,
                            fontWeight: AppStyles.fontBold,
                            color: AppColors.green,
                          ),
                        )),
                      ],
                    ),
                    SizedBox(height: AppStyles.space1),
                    Text(
                      'tiền ảo',
                      style: TextStyle(
                        fontSize: AppStyles.textBase,
                        color: AppColors.green,
                        fontWeight: AppStyles.fontSemibold,
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),
              
              SizedBox(height: AppStyles.space4),
              
              // Info text
              Text(
                'Dùng tiền ảo để mua Diamond\nvà nhiều vật phẩm hấp dẫn khác!',
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(delay: 800.ms),
              
              const Spacer(),
              
              // Buttons
              Obx(() => DuoButton(
                text: controller.isClaimed.value 
                    ? 'Đã nhận!' 
                    : (controller.isClaiming.value ? 'Đang xử lý...' : 'Nhận ngay'),
                variant: DuoButtonVariant.success,
                isLoading: controller.isClaiming.value,
                isDisabled: controller.isAnimating.value,
                onPressed: controller.isAnimating.value || controller.isClaiming.value
                    ? null
                    : controller.claimAndContinue,
              )).animate()
                .fadeIn(delay: 1000.ms)
                .slideY(begin: 0.2),
              
              SizedBox(height: AppStyles.space3),
              
              // Skip button
              Obx(() => controller.isAnimating.value || controller.isClaiming.value
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: controller.skip,
                      child: Text(
                        'Bỏ qua',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: AppStyles.textSm,
                        ),
                      ),
                    ).animate()
                      .fadeIn(delay: 1200.ms),
              ),
              
              SizedBox(height: AppStyles.space4),
            ],
          ),
        ),
      ),
    );
  }
}
