import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/tuition_bonus_controller.dart';

class TuitionBonusView extends GetView<TuitionBonusController> {
  const TuitionBonusView({super.key});

  @override
  Widget build(BuildContext context) {
    // Bắt đầu animation khi view được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        controller.startCountAnimation();
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppStyles.space4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              SizedBox(height: AppStyles.space2),
              
              // Title với confetti effect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 24.sp))
                      .animate(onPlay: (c) => c.repeat())
                      .shake(duration: 1000.ms, delay: 2000.ms),
                  SizedBox(width: AppStyles.space2),
                  Flexible(
                    child: Text(
                      'Thưởng học phí!',
                      style: TextStyle(
                        fontSize: AppStyles.textXl,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  SizedBox(width: AppStyles.space2),
                  Text('🎉', style: TextStyle(fontSize: 24.sp))
                      .animate(onPlay: (c) => c.repeat())
                      .shake(duration: 1000.ms, delay: 2500.ms),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
              
              SizedBox(height: AppStyles.space2),
              
              // Subtitle
              Obx(() => Text(
                'Bạn đã đóng ${controller.formatCurrency(controller.tuitionPaid.value)} học phí',
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )).animate().fadeIn(delay: 200.ms),
              
              SizedBox(height: AppStyles.space6),
              
              // Animated amount display
              Obx(() => _BonusAmountCard(
                amount: controller.displayedBalance.value,
                isAnimating: controller.isAnimating.value,
              )).animate()
                .fadeIn(delay: 600.ms)
                .scale(begin: const Offset(0.9, 0.9)),
              
              SizedBox(height: AppStyles.space3),
              
              // Info text
              Container(
                padding: EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppStyles.roundedLg,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppStyles.space2),
                    Expanded(
                      child: Text(
                        'Dùng TVUCash để mua Diamond và nhiều vật phẩm hấp dẫn!',
                        style: TextStyle(
                          fontSize: AppStyles.textXs,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms),
              
              SizedBox(height: AppStyles.space6),
              
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
              
              SizedBox(height: AppStyles.space2),
              
              // Skip button
              Obx(() => controller.isAnimating.value || controller.isClaiming.value
                  ? SizedBox(height: 40.h)
                  : TextButton(
                      onPressed: controller.skip,
                      child: Text(
                        'Bỏ qua',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: AppStyles.textSm,
                        ),
                      ),
                    ).animate().fadeIn(delay: 1200.ms),
              ),
              
              SizedBox(height: AppStyles.space2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card hiển thị số tiền bonus - thiết kế tinh tế
class _BonusAmountCard extends StatelessWidget {
  final int amount;
  final bool isAnimating;

  const _BonusAmountCard({
    required this.amount,
    required this.isAnimating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space5,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Label nhỏ phía trên
          Text(
            'Bạn nhận được',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textTertiary,
            ),
          ),
          
          SizedBox(height: AppStyles.space3),
          
          // Amount với icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Image.asset(
                'assets/game/currency/cash_green_cash_1st_256px.png',
                width: 40.w,
                height: 40.w,
              ).animate(
                onPlay: isAnimating ? (c) => c.repeat() : null,
              ).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 500.ms,
                curve: Curves.easeInOut,
              ),
              
              SizedBox(width: AppStyles.space3),
              
              // Số tiền
              Text(
                '+${NumberFormatter.withCommas(amount)}',
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.green,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppStyles.space2),
          
          // Currency label
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyles.space3,
              vertical: AppStyles.space1,
            ),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: AppStyles.roundedFull,
            ),
            child: Text(
              'TVUCash',
              style: TextStyle(
                fontSize: AppStyles.textSm,
                color: AppColors.green,
                fontWeight: AppStyles.fontSemibold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
