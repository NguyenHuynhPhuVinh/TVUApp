import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/components/widgets.dart';
import '../../../core/extensions/animation_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../controllers/bug_report_controller.dart';
import '../models/bug_report_model.dart';

class BugReportView extends GetView<BugReportController> {
  const BugReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Báo cáo lỗi',
        showLogo: false,
        leading: const DuoBackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppStyles.space4),
            _buildCategorySelector(),
            SizedBox(height: AppStyles.space4),
            _buildTitleInput(),
            SizedBox(height: AppStyles.space4),
            _buildDescriptionInput(),
            SizedBox(height: AppStyles.space4),
            _buildDeviceInfo(),
            SizedBox(height: AppStyles.space6),
            _buildSubmitButton(),
            SizedBox(height: AppStyles.space6),
            _buildMyReports(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        DuoCard(
          padding: EdgeInsets.all(AppStyles.space4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppStyles.roundedLg,
                ),
                child: Icon(Iconsax.message_question,
                    color: AppColors.primary, size: AppStyles.iconLg),
              ),
              SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gặp vấn đề?',
                      style: TextStyle(
                        fontSize: AppStyles.textLg,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppStyles.space1),
                    Text(
                      'Hãy cho chúng tôi biết để cải thiện ứng dụng',
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
        ),
        SizedBox(height: AppStyles.space3),
        // Reward banner
        DuoCard(
          backgroundColor: AppColors.yellowSoft,
          padding: EdgeInsets.all(AppStyles.space3),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppStyles.space2),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: AppStyles.roundedFull,
                ),
                child: Icon(Iconsax.gift, color: Colors.white, size: AppStyles.iconSm),
              ),
              SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhận quà khủng!',
                      style: TextStyle(
                        fontSize: AppStyles.textBase,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.yellowDark,
                      ),
                    ),
                    SizedBox(height: AppStyles.space1),
                    Text(
                      'Báo cáo lỗi chính xác sẽ được thưởng Coins & Diamonds!',
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
        ),
      ],
    ).animateFadeSlide();
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại lỗi',
          style: TextStyle(
            fontSize: AppStyles.textBase,
            fontWeight: AppStyles.fontSemibold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppStyles.space2),
        Obx(() => Wrap(
              spacing: AppStyles.space2,
              runSpacing: AppStyles.space2,
              children: BugCategory.values.map((category) {
                final isSelected = controller.selectedCategory.value == category;
                return GestureDetector(
                  onTap: () => controller.selectCategory(category),
                  child: AnimatedContainer(
                    duration: AppStyles.durationFast,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppStyles.space3,
                      vertical: AppStyles.space2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.backgroundWhite,
                      borderRadius: AppStyles.roundedLg,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: AppStyles.border2,
                      ),
                    ),
                    child: Text(
                      category.label,
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        fontWeight: AppStyles.fontSemibold,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
        Obx(() {
          if (controller.categoryError.value != null) {
            return Padding(
              padding: EdgeInsets.only(top: AppStyles.space2),
              child: Text(
                controller.categoryError.value!,
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: AppStyles.textSm,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    ).animateFadeSlide(delay: 100);
  }

  Widget _buildTitleInput() {
    return Obx(() => DuoInput(
          controller: controller.titleController,
          label: 'Tiêu đề',
          hint: 'VD: Không thể xem điểm học kỳ 2',
          prefixIcon: Iconsax.edit,
          errorText: controller.titleError.value,
        )).animateFadeSlide(delay: 150);
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả chi tiết',
          style: TextStyle(
            fontSize: AppStyles.textBase,
            fontWeight: AppStyles.fontSemibold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppStyles.space2),
        Obx(() => Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: AppStyles.roundedXl,
                border: Border.all(
                  color: controller.descriptionError.value != null
                      ? AppColors.red
                      : AppColors.border,
                  width: AppStyles.border2,
                ),
                boxShadow: AppColors.cardBoxShadow(),
              ),
              child: TextField(
                controller: controller.descriptionController,
                maxLines: 5,
                style: TextStyle(
                  fontSize: AppStyles.textBase,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Mô tả chi tiết lỗi bạn gặp phải...\n'
                      '- Lỗi xảy ra khi nào?\n'
                      '- Các bước để tái hiện lỗi?',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: AppStyles.textSm,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(AppStyles.space4),
                ),
              ),
            )),
        Obx(() {
          if (controller.descriptionError.value != null) {
            return Padding(
              padding: EdgeInsets.only(top: AppStyles.space2, left: AppStyles.space3),
              child: Text(
                controller.descriptionError.value!,
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: AppStyles.textSm,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    ).animateFadeSlide(delay: 200);
  }

  Widget _buildDeviceInfo() {
    return DuoCard(
      backgroundColor: AppColors.background,
      padding: EdgeInsets.all(AppStyles.space3),
      child: Row(
        children: [
          Icon(Iconsax.mobile, color: AppColors.textSecondary, size: AppStyles.iconSm),
          SizedBox(width: AppStyles.space2),
          Expanded(
            child: Text(
              '${controller.deviceInfo ?? 'Unknown'} • v${controller.appVersion ?? '?'}',
              style: TextStyle(
                fontSize: AppStyles.textSm,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ).animateFadeSlide(delay: 250);
  }

  Widget _buildSubmitButton() {
    return Obx(() => DuoButton(
          text: 'Gửi báo cáo',
          icon: Iconsax.send_1,
          variant: DuoButtonVariant.primary,
          isLoading: controller.isSubmitting.value,
          onPressed: controller.submitReport,
        )).animateFadeSlide(delay: 300);
  }

  Widget _buildMyReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.document_text, color: AppColors.textSecondary, size: AppStyles.iconSm),
            SizedBox(width: AppStyles.space2),
            Text(
              'Báo cáo của tôi',
              style: TextStyle(
                fontSize: AppStyles.textBase,
                fontWeight: AppStyles.fontSemibold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppStyles.space3),
        Obx(() {
          if (controller.isLoadingReports.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.myReports.isEmpty) {
            return DuoCard(
              padding: EdgeInsets.all(AppStyles.space4),
              child: Center(
                child: Text(
                  'Chưa có báo cáo nào',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppStyles.textSm,
                  ),
                ),
              ),
            );
          }
          return Column(
            children: controller.myReports
                .map((report) => Padding(
                      padding: EdgeInsets.only(bottom: AppStyles.space2),
                      child: _buildReportItem(report),
                    ))
                .toList(),
          );
        }),
      ],
    ).animateFadeSlide(delay: 350);
  }

  Widget _buildReportItem(BugReportModel report) {
    final statusColor = switch (report.status) {
      'resolved' => AppColors.green,
      'in_progress' => AppColors.orange,
      _ => AppColors.textSecondary,
    };
    final statusText = switch (report.status) {
      'resolved' => 'Đã xử lý',
      'in_progress' => 'Đang xử lý',
      _ => 'Chờ xử lý',
    };

    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppStyles.space2,
                  vertical: AppStyles.space1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(statusColor, 0.1),
                  borderRadius: AppStyles.roundedSm,
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    fontWeight: AppStyles.fontSemibold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space1),
          Text(
            report.description,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
