import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';
import '../base/duo_button.dart';
import '../base/duo_card.dart';
import '../feedback/duo_tag.dart';

/// Trạng thái của card thưởng học phí
enum DuoTuitionBonusState {
  canClaim,    // Có thể nhận
  claimed,     // Đã nhận
  loading,     // Đang xử lý
}

/// Card hiển thị thưởng học phí - có đủ trạng thái theo UI guidelines
class DuoTuitionBonusCard extends StatelessWidget {
  final DuoTuitionBonusState state;
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
      state: isLoading ? DuoTuitionBonusState.loading : DuoTuitionBonusState.canClaim,
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
      state: DuoTuitionBonusState.claimed,
      tuitionPaid: 0,
      virtualBalance: virtualBalance,
    );
  }

  String _formatCurrency(int amount) => '${NumberFormatter.currency(amount)}đ';

  @override
  Widget build(BuildContext context) {
    if (state == DuoTuitionBonusState.claimed) {
      return _buildClaimedCard();
    }
    return _buildCanClaimCard();
  }

  Widget _buildCanClaimCard() {
    final isLoading = state == DuoTuitionBonusState.loading;
    
    return DuoCard(
      backgroundColor: AppColors.greenSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                AppAssets.tvuCash,
                width: 32.w,
                height: 32.w,
              ),
              SizedBox(width: AppStyles.space2),
              Expanded(
                child: Text(
                  'Thưởng học phí',
                  style: TextStyle(
                    fontSize: AppStyles.textLg,
                    fontWeight: AppStyles.fontBold,
                    color: AppColors.green,
                  ),
                ),
              ),
              const DuoTag(text: 'Mới', color: AppColors.green),
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
            'Nhận ngay ${NumberFormatter.withCommas(virtualBalance)} TVUCash!',
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
          Image.asset(
            AppAssets.tvuCash,
            width: 32.w,
            height: 32.w,
          ),
          SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thưởng học phí',
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Đã nhận ${NumberFormatter.withCommas(virtualBalance)} TVUCash',
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
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
