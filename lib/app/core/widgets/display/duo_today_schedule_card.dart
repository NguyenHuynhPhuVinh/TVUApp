import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';
import 'duo_info_row.dart';

/// Card hiển thị lịch học hôm nay
class DuoTodayScheduleCard extends StatelessWidget {
  final String tenMon;
  final int tietBatDau;
  final int soTiet;
  final String maPhong;
  final String tenGiangVien;
  final Color accentColor;

  const DuoTodayScheduleCard({
    super.key,
    required this.tenMon,
    required this.tietBatDau,
    required this.soTiet,
    required this.maPhong,
    required this.tenGiangVien,
    required this.accentColor,
  });

  int get tietKetThuc => tietBatDau + soTiet - 1;

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: AppStyles.roundedFull,
            ),
          ),
          SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenMon,
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppStyles.space2),
                DuoInfoRow(
                  icon: Iconsax.clock,
                  text: 'Tiết $tietBatDau - $tietKetThuc',
                ),
                SizedBox(height: AppStyles.space1),
                DuoInfoRow(icon: Iconsax.location, text: maPhong),
                SizedBox(height: AppStyles.space1),
                DuoInfoRow(icon: Iconsax.teacher, text: tenGiangVien),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyles.space3,
              vertical: AppStyles.space2,
            ),
            decoration: BoxDecoration(
              color: AppColors.withAlpha(accentColor, 0.1),
              borderRadius: AppStyles.roundedLg,
            ),
            child: Column(
              children: [
                Text(
                  '$soTiet',
                  style: TextStyle(
                    fontSize: AppStyles.textXl,
                    fontWeight: AppStyles.fontBold,
                    color: accentColor,
                  ),
                ),
                Text(
                  'tiết',
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: accentColor,
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
