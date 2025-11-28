import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/components/widgets.dart';

/// Card preview tiền ảo từ học phí trong game setup
class DuoTuitionPreviewCard extends StatelessWidget {
  final int tuitionPaid;
  final int virtualBalance;

  const DuoTuitionPreviewCard({
    super.key,
    required this.tuitionPaid,
    required this.virtualBalance,
  });

  String _formatCurrency(int amount) => '${NumberFormatter.currency(amount)}đ';

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      backgroundColor: AppColors.greenSoft,
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                AppAssets.tvuCash,
                width: 40.w,
                height: 40.w,
              ),
              SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tiền ảo từ học phí',
                          style: TextStyle(
                            fontSize: AppStyles.textBase,
                            fontWeight: AppStyles.fontBold,
                            color: AppColors.green,
                          ),
                        ),
                        SizedBox(width: AppStyles.space2),
                        DuoBadge.tag(text: 'BONUS', color: AppColors.green),
                      ],
                    ),
                    SizedBox(height: AppStyles.space1),
                    Text(
                      'Đã đóng: ${_formatCurrency(tuitionPaid)}',
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
          SizedBox(height: AppStyles.space3),
          Container(
            padding: EdgeInsets.all(AppStyles.space3),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: AppStyles.roundedLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bạn sẽ nhận: ',
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    color: AppColors.textSecondary,
                  ),
                ),
                Image.asset(
                  AppAssets.tvuCash,
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(width: AppStyles.space1),
                Text(
                  NumberFormatter.withCommas(virtualBalance),
                  style: TextStyle(
                    fontSize: AppStyles.textLg,
                    fontWeight: AppStyles.fontBold,
                    color: AppColors.green,
                  ),
                ),
                Text(
                  ' tiền ảo',
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
    );
  }
}



