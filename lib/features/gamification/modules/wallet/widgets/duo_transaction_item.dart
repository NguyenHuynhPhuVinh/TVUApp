import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_styles.dart';
import '../../../../../core/utils/number_formatter.dart';

/// Item hiển thị một giao dịch trong lịch sử
class DuoTransactionItem extends StatelessWidget {
  final String title;
  final String description;
  final int amount;
  final bool isIncome;
  final DateTime? createdAt;

  const DuoTransactionItem({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.isIncome,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.green : AppColors.red;

    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space2),
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppStyles.roundedMd,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}${NumberFormatter.compact(amount)}',
            style: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontBold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}



