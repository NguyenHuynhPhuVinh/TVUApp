import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/tuition_controller.dart';

class TuitionView extends GetView<TuitionController> {
  const TuitionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DuoAppBar(
        title: 'Học phí',
        showLogo: false,
        leading: const DuoBackButton(),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(child: _buildTuitionList()),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Obx(() {
        final hasDebt = controller.totalDebt.value > 0;

        return Container(
          padding: EdgeInsets.all(AppStyles.space5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppStyles.rounded2xl,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Tổng phải thu',
                      controller.formatCurrency(controller.totalTuition.value),
                      Iconsax.receipt,
                      Colors.white,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50.h,
                    color: AppColors.withAlpha(Colors.white, 0.3),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Đã đóng',
                      controller.formatCurrency(controller.totalPaid.value),
                      Iconsax.tick_circle,
                      AppColors.greenLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppStyles.space4),
              Container(
                padding: EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: hasDebt
                      ? AppColors.withAlpha(AppColors.red, 0.3)
                      : AppColors.withAlpha(AppColors.green, 0.3),
                  borderRadius: AppStyles.roundedXl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasDebt ? Iconsax.warning_2 : Iconsax.tick_circle,
                      color: Colors.white,
                      size: AppStyles.iconSm,
                    ),
                    SizedBox(width: AppStyles.space2),
                    Text(
                      hasDebt
                          ? 'Còn nợ: ${controller.formatCurrency(controller.totalDebt.value)}'
                          : 'Đã đóng đủ học phí',
                      style: TextStyle(
                        fontSize: AppStyles.textBase,
                        fontWeight: AppStyles.fontBold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppStyles.iconXs, color: iconColor),
            SizedBox(width: AppStyles.space1),
            Text(
              label,
              style: TextStyle(
                fontSize: AppStyles.textXs,
                color: AppColors.withAlpha(Colors.white, 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: AppStyles.space2),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textLg,
            fontWeight: AppStyles.fontBold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTuitionList() {
    return Obx(() {
      if (controller.tuitionList.isEmpty) {
        return DuoEmptyState(
          icon: Iconsax.wallet,
          title: 'Chưa có thông tin học phí',
          subtitle: 'Thông tin sẽ được cập nhật khi có dữ liệu',
          iconColor: AppColors.textTertiary,
          iconBackgroundColor: AppColors.backgroundDark,
        ).animate().fadeIn(duration: 300.ms);
      }

      final reversedList = controller.tuitionList.reversed.toList();

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
        itemCount: reversedList.length,
        itemBuilder: (context, index) => _buildTuitionCard(reversedList[index], index),
      );
    });
  }

  Widget _buildTuitionCard(Map<String, dynamic> item, int index) {
    final hocPhi = NumberFormatter.parseDouble(item['hoc_phi']);
    final mienGiam = NumberFormatter.parseDouble(item['mien_giam']);
    final duocHoTro = NumberFormatter.parseDouble(item['duoc_ho_tro']);
    final phaiThu = NumberFormatter.parseDouble(item['phai_thu']);
    final daThu = NumberFormatter.parseDouble(item['da_thu']);
    final conNo = NumberFormatter.parseDouble(item['con_no']);
    final donGia = NumberFormatter.parseDouble(item['don_gia']);
    final hasDebt = conNo > 0;

    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: DuoCard(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: hasDebt ? AppColors.red : AppColors.green,
                    borderRadius: AppStyles.roundedFull,
                  ),
                ),
                SizedBox(width: AppStyles.space3),
                Expanded(
                  child: Text(
                    item['ten_hoc_ky'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: AppStyles.textBase,
                      fontWeight: AppStyles.fontBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppStyles.space3,
                    vertical: AppStyles.space1,
                  ),
                  decoration: BoxDecoration(
                    color: hasDebt ? AppColors.redSoft : AppColors.greenSoft,
                    borderRadius: AppStyles.roundedFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasDebt ? Iconsax.warning_2 : Iconsax.tick_circle,
                        size: 12.sp,
                        color: hasDebt ? AppColors.red : AppColors.green,
                      ),
                      SizedBox(width: AppStyles.space1),
                      Text(
                        hasDebt ? 'Còn nợ' : 'Đã đóng đủ',
                        style: TextStyle(
                          fontSize: AppStyles.textXs,
                          fontWeight: AppStyles.fontBold,
                          color: hasDebt ? AppColors.red : AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppStyles.space4),
            _buildTuitionRow('Học phí', controller.formatCurrency(hocPhi)),
            if (mienGiam > 0)
              _buildTuitionRow(
                'Miễn giảm',
                '-${controller.formatCurrency(mienGiam)}',
                color: AppColors.orange,
              ),
            if (duocHoTro > 0)
              _buildTuitionRow(
                'Được hỗ trợ',
                '-${controller.formatCurrency(duocHoTro)}',
                color: AppColors.primary,
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppStyles.space2),
              child: Divider(color: AppColors.border, height: 1),
            ),
            _buildTuitionRow(
              'Phải thu',
              controller.formatCurrency(phaiThu),
              isBold: true,
            ),
            _buildTuitionRow(
              'Đã đóng',
              controller.formatCurrency(daThu),
              color: AppColors.green,
            ),
            if (conNo > 0)
              _buildTuitionRow(
                'Còn nợ',
                controller.formatCurrency(conNo),
                color: AppColors.red,
                isBold: true,
              ),
            if (donGia > 0) ...[
              SizedBox(height: AppStyles.space2),
              Text(
                'Đơn giá: ${controller.formatCurrency(donGia)}/TC',
                style: TextStyle(
                  fontSize: AppStyles.textXs,
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildTuitionRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppStyles.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: isBold ? AppStyles.fontBold : AppStyles.fontMedium,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
