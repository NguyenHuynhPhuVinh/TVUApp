import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_accent_card.dart';
import 'duo_info_row.dart';

/// Card hiển thị lịch học hôm nay - sử dụng DuoAccentCard base
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
    return DuoAccentCard(
      accentColor: accentColor,
      accentHeight: 80,
      trailing: DuoCountBadge(
        count: soTiet,
        label: 'tiết',
        color: accentColor,
      ),
      content: Column(
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
    );
  }
}
