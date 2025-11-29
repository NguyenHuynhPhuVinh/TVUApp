import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/components/widgets.dart';
import '../../../../../core/extensions/animation_extensions.dart';
import '../controllers/reward_code_controller.dart';
import '../widgets/duo_claimed_code_item.dart';

class RewardCodeView extends GetView<RewardCodeController> {
  const RewardCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DuoAppBar(
        title: 'Nhập mã thưởng',
        showLogo: false,
        leading: DuoBackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection().animateFadeSlide(),
            SizedBox(height: AppStyles.space5),
            _buildHistorySection().animateFadeSlide(delay: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppStyles.space2),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppStyles.roundedMd,
                ),
                child: Icon(
                  Iconsax.ticket_discount,
                  color: AppColors.primary,
                  size: AppStyles.iconMd,
                ),
              ),
              SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhập mã thưởng',
                      style: TextStyle(
                        fontSize: AppStyles.textLg,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Nhập mã để nhận quà',
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space4),

          // Input field
          Obx(() => TextField(
            controller: controller.codeController,
            focusNode: controller.codeFocusNode,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              fontSize: AppStyles.textLg,
              fontWeight: AppStyles.fontSemibold,
              letterSpacing: 2,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'VD: TVUAPP2024',
              hintStyle: TextStyle(
                fontSize: AppStyles.textBase,
                fontWeight: AppStyles.fontNormal,
                letterSpacing: 1,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: AppStyles.roundedLg,
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppStyles.roundedLg,
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppStyles.roundedLg,
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppStyles.roundedLg,
                borderSide: BorderSide(color: AppColors.red),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppStyles.space4,
                vertical: AppStyles.space3,
              ),
              errorText: controller.errorMessage.value.isNotEmpty 
                  ? controller.errorMessage.value 
                  : null,
              suffixIcon: controller.codeController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textTertiary),
                      onPressed: () {
                        controller.codeController.clear();
                        controller.errorMessage.value = '';
                      },
                    )
                  : null,
            ),
            onChanged: controller.onCodeChanged,
            onSubmitted: (_) => controller.redeemCode(),
          )),
          SizedBox(height: AppStyles.space4),

          // Submit button
          Obx(() => DuoButton(
            text: controller.isLoading.value ? 'Đang xử lý...' : 'Nhận thưởng',
            variant: DuoButtonVariant.primary,
            onPressed: controller.isLoading.value ? null : controller.redeemCode,
            fullWidth: true,
            isLoading: controller.isLoading.value,
          )),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Obx(() {
      final history = controller.claimedHistory;
      
      if (history.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Iconsax.clock,
                color: AppColors.textSecondary,
                size: AppStyles.iconSm,
              ),
              SizedBox(width: AppStyles.space2),
              Text(
                'Lịch sử nhận mã',
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  fontWeight: AppStyles.fontSemibold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space3),

          // List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, __) => SizedBox(height: AppStyles.space2),
            itemBuilder: (context, index) {
              return DuoClaimedCodeItem(
                claimedCode: history[index],
              ).animateFadeSlide(delay: (index * 50).toDouble() + 150);
            },
          ),
        ],
      );
    });
  }
}
