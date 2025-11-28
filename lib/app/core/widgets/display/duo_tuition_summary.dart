import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Card tổng quan học phí
class DuoTuitionSummary extends StatelessWidget {
  final String totalTuition;
  final String totalPaid;
  final String totalDebt;
  final bool hasDebt;

  const DuoTuitionSummary({
    super.key,
    required this.totalTuition,
    required this.totalPaid,
    required this.totalDebt,
    required this.hasDebt,
  });

  @override
  Widget build(BuildContext context) {
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
                child: _SummaryItem(
                  label: 'Tổng phải thu',
                  value: totalTuition,
                  icon: Iconsax.receipt,
                  iconColor: Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: AppColors.withAlpha(Colors.white, 0.3),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Đã đóng',
                  value: totalPaid,
                  icon: Iconsax.tick_circle,
                  iconColor: AppColors.greenLight,
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space4),
          _buildDebtStatus(),
        ],
      ),
    );
  }

  Widget _buildDebtStatus() {
    return Container(
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
            hasDebt ? 'Còn nợ: $totalDebt' : 'Đã đóng đủ học phí',
            style: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontBold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
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
}
