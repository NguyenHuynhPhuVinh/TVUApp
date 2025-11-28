import 'package:flutter/material.dart';
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
          _SummarySection(controller: controller),
          Expanded(child: _TuitionListSection(controller: controller)),
        ],
      ),
    );
  }
}

/// Section tổng quan học phí
class _SummarySection extends StatelessWidget {
  final TuitionController controller;

  const _SummarySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Obx(() => DuoTuitionSummary(
            totalTuition: controller.formatCurrency(controller.totalTuition.value),
            totalPaid: controller.formatCurrency(controller.totalPaid.value),
            totalDebt: controller.formatCurrency(controller.totalDebt.value),
            hasDebt: controller.totalDebt.value > 0,
          )),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

/// Section danh sách học phí
class _TuitionListSection extends StatelessWidget {
  final TuitionController controller;

  const _TuitionListSection({required this.controller});

  @override
  Widget build(BuildContext context) {
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
        itemBuilder: (context, index) => _TuitionItem(
          item: reversedList[index],
          index: index,
          controller: controller,
        ),
      );
    });
  }
}

/// Item học phí
class _TuitionItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final TuitionController controller;

  const _TuitionItem({
    required this.item,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
      child: DuoTuitionCard(
        tenHocKy: item['ten_hoc_ky'] ?? 'N/A',
        hocPhi: controller.formatCurrency(hocPhi),
        mienGiam: mienGiam > 0 ? controller.formatCurrency(mienGiam) : null,
        duocHoTro: duocHoTro > 0 ? controller.formatCurrency(duocHoTro) : null,
        phaiThu: controller.formatCurrency(phaiThu),
        daThu: controller.formatCurrency(daThu),
        conNo: controller.formatCurrency(conNo),
        donGia: donGia > 0 ? controller.formatCurrency(donGia) : null,
        hasDebt: hasDebt,
      ),
    ).animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideX(begin: 0.05, end: 0);
  }
}
