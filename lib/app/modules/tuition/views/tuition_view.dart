import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/tuition_semester.dart';
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
  final TuitionSemester item;
  final int index;
  final TuitionController controller;

  const _TuitionItem({
    required this.item,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: Obx(() {
        // Xác định trạng thái bonus
        TuitionBonusState bonusState;
        if (item.paidAmount <= 0) {
          bonusState = TuitionBonusState.noPaid;
        } else if (controller.isSemesterClaimed(item.tenHocKy)) {
          bonusState = TuitionBonusState.claimed;
        } else if (controller.claimingId.value == item.tenHocKy) {
          bonusState = TuitionBonusState.loading;
        } else {
          bonusState = TuitionBonusState.canClaim;
        }

        return DuoTuitionCard(
          tenHocKy: item.tenHocKy.isNotEmpty ? item.tenHocKy : 'N/A',
          hocPhi: controller.formatCurrency(item.phaiThu), // phaiThu = hocPhi sau miễn giảm
          phaiThu: controller.formatCurrency(item.phaiThu),
          daThu: controller.formatCurrency(item.daThu),
          conNo: controller.formatCurrency(item.conNo),
          hasDebt: item.conNo > 0,
          bonusState: bonusState,
          daThuAmount: item.paidAmount,
          onClaimBonus: bonusState == TuitionBonusState.canClaim
              ? () => _claimBonus(context)
              : null,
        );
      }),
    ).animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideX(begin: 0.05, end: 0);
  }

  Future<void> _claimBonus(BuildContext context) async {
    final result = await controller.claimSemesterBonus(item);
    if (result != null) {
      await DuoRewardDialog.showCustom(
        title: 'Nhận thưởng thành công!',
        rewards: [
          RewardItem(
            icon: AppAssets.tvuCash,
            label: 'TVUCash',
            value: result['virtualBalance'],
            color: AppColors.green,
          ),
        ],
      );
    }
  }
}
