import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/enums/reward_claim_status.dart';
import '../../../../core/extensions/animation_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/components/widgets.dart';
import '../../../../features/academic/widgets/academic_widgets.dart';
import '../../../../features/gamification/shared/widgets/game_widgets.dart';
import '../../../../features/academic/models/tuition_semester.dart';
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
    ).animateFadeSlide(slideBegin: -0.1);
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
        ).animateFadeSlide();
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
        RewardClaimStatus bonusState;
        if (item.paidAmount <= 0) {
          bonusState = RewardClaimStatus.locked;
        } else if (controller.isSemesterClaimed(item.tenHocKy)) {
          bonusState = RewardClaimStatus.claimed;
        } else if (controller.claimingId.value == item.tenHocKy) {
          bonusState = RewardClaimStatus.claiming;
        } else {
          bonusState = RewardClaimStatus.canClaim;
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
          onClaimBonus: bonusState.canPerformAction
              ? () => _claimBonus(context)
              : null,
        );
      }),
    ).animateFadeSlideRight(delay: (index * 50).toDouble(), slideBegin: 0.05);
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



