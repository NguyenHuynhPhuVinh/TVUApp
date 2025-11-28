import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../enums/reward_claim_status.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_button.dart';
import '../base/duo_card.dart';
import '../game/duo_currency_row.dart';

/// Card hiển thị học phí theo học kỳ
class DuoTuitionCard extends StatelessWidget {
  final String tenHocKy;
  final String hocPhi;
  final String? mienGiam;
  final String? duocHoTro;
  final String phaiThu;
  final String daThu;
  final String conNo;
  final String? donGia;
  final bool hasDebt;
  final RewardClaimStatus bonusState;
  final int daThuAmount; // Số tiền đã đóng (để hiển thị bonus)
  final VoidCallback? onClaimBonus;

  const DuoTuitionCard({
    super.key,
    required this.tenHocKy,
    required this.hocPhi,
    this.mienGiam,
    this.duocHoTro,
    required this.phaiThu,
    required this.daThu,
    required this.conNo,
    this.donGia,
    required this.hasDebt,
    this.bonusState = RewardClaimStatus.locked,
    this.daThuAmount = 0,
    this.onClaimBonus,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppStyles.space4),
          _TuitionRow(label: 'Học phí', value: hocPhi),
          if (mienGiam != null)
            _TuitionRow(label: 'Miễn giảm', value: '-$mienGiam', color: AppColors.orange),
          if (duocHoTro != null)
            _TuitionRow(label: 'Được hỗ trợ', value: '-$duocHoTro', color: AppColors.primary),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppStyles.space2),
            child: Divider(color: AppColors.border, height: 1),
          ),
          _TuitionRow(label: 'Phải thu', value: phaiThu, isBold: true),
          _TuitionRow(label: 'Đã đóng', value: daThu, color: AppColors.green),
          if (hasDebt)
            _TuitionRow(label: 'Còn nợ', value: conNo, color: AppColors.red, isBold: true),
          if (donGia != null) ...[
            SizedBox(height: AppStyles.space2),
            Text(
              'Đơn giá: $donGia/TC',
              style: TextStyle(
                fontSize: AppStyles.textXs,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          // Bonus section
          if (!bonusState.isLocked) ...[
            SizedBox(height: AppStyles.space3),
            _buildBonusSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildBonusSection() {
    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: bonusState.isCompleted ? AppColors.backgroundDark : AppColors.greenSoft,
        borderRadius: AppStyles.roundedLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DuoCurrencyRow.tvuCash(
                value: daThuAmount,
                size: DuoCurrencySize.sm,
                showPlus: true,
                valueStyle: TextStyle(
                  fontSize: AppStyles.textSm,
                  fontWeight: AppStyles.fontSemibold,
                  color: bonusState.isCompleted ? AppColors.textTertiary : AppColors.green,
                ),
              ),
              const Spacer(),
              Text(
                bonusState.isCompleted ? 'Đã nhận thưởng' : 'Thưởng học phí',
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  fontWeight: AppStyles.fontSemibold,
                  color: bonusState.isCompleted ? AppColors.textTertiary : AppColors.green,
                ),
              ),
              if (bonusState.isCompleted) ...[
                SizedBox(width: AppStyles.space1),
                Icon(Icons.check_circle_rounded, size: 16.sp, color: AppColors.green),
              ],
            ],
          ),
          if (!bonusState.isCompleted) ...[
            SizedBox(height: AppStyles.space3),
            DuoButton(
              text: bonusState.isLoading ? 'Đang xử lý...' : 'Nhận thưởng',
              variant: DuoButtonVariant.success,
              size: DuoButtonSize.sm,
              isLoading: bonusState.isLoading,
              onPressed: bonusState.isLoading ? null : onClaimBonus,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
            tenHocKy,
            style: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
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
    );
  }
}

class _TuitionRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  const _TuitionRow({
    required this.label,
    required this.value,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
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
