import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/reward_claim_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/components/base/duo_button.dart';
import '../../../../core/components/base/duo_card.dart';
import '../../../../core/components/feedback/duo_badge.dart';
import 'duo_currency_row.dart';

/// Card hiển thị thưởng học phí - có đủ trạng thái theo UI guidelines
class DuoTuitionBonusCard extends StatelessWidget {
  final RewardClaimStatus state;
  final int tuitionPaid;
  final int virtualBalance;
  final VoidCallback? onClaim;

  const DuoTuitionBonusCard({
    super.key,
    required this.state,
    required this.tuitionPaid,
    required this.virtualBalance,
    this.onClaim,
  });

  /// Factory cho trạng thái có thể nhận
  factory DuoTuitionBonusCard.canClaim({
    required int tuitionPaid,
    required int virtualBalance,
    required VoidCallback onClaim,
    bool isLoading = false,
  }) {
    return DuoTuitionBonusCard(
      state: isLoading ? RewardClaimStatus.claiming : RewardClaimStatus.canClaim,
      tuitionPaid: tuitionPaid,
      virtualBalance: virtualBalance,
      onClaim: onClaim,
    );
  }

  /// Factory cho trạng thái đã nhận
  factory DuoTuitionBonusCard.claimed({
    required int virtualBalance,
  }) {
    return DuoTuitionBonusCard(
      state: RewardClaimStatus.claimed,
      tuitionPaid: 0,
      virtualBalance: virtualBalance,
    );
  }

  String _formatCurrency(int amount) => '${NumberFormatter.currency(amount)}đ';

  @override
  Widget build(BuildContext context) {
    if (state.isCompleted) {
      return _buildClaimedCard();
    }
    return _buildCanClaimCard();
  }

  Widget _buildCanClaimCard() {
    final isLoading = state.isLoading;
    
    return DuoCard(
      backgroundColor: AppColors.greenSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DuoCurrencyRow.tvuCash(
                value: virtualBalance,
                size: DuoCurrencySize.lg,
                compact: false,
              ),
              const Spacer(),
              DuoBadge.tag(text: 'Mới', color: AppColors.green),
            ],
          ),
          SizedBox(height: AppStyles.space3),
          Text(
            'Bạn đã đóng ${_formatCurrency(tuitionPaid)} học phí.',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppStyles.space1),
          Text(
            'Nhận ngay thưởng TVUCash!',
            style: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontSemibold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppStyles.space4),
          DuoButton(
            text: isLoading ? 'Đang xử lý...' : 'Nhận thưởng',
            variant: DuoButtonVariant.success,
            isLoading: isLoading,
            onPressed: isLoading ? null : onClaim,
          ),
        ],
      ),
    );
  }

  Widget _buildClaimedCard() {
    return DuoCard(
      backgroundColor: AppColors.background,
      child: Row(
        children: [
          DuoCurrencyRow.tvuCash(
            value: virtualBalance,
            size: DuoCurrencySize.md,
            showPlus: true,
            valueStyle: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontSemibold,
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          Text(
            'Đã nhận',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(width: AppStyles.space2),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.green,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}



