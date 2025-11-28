import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/services/game_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';
import '../feedback/duo_badge.dart';
import '../display/duo_info_row.dart';
import 'duo_currency_row.dart';
import 'duo_lesson_checkin.dart';

/// Widget hiển thị card lịch học với check-in
class DuoScheduleCard extends StatelessWidget {
  final String tenMon;
  final int soTinChi;
  final int tietBatDau;
  final int soTiet;
  final String maPhong;
  final String tenGiangVien;
  final String? maNhom;
  final Color accentColor;
  final bool canCheckIn;
  final bool hasCheckedIn;
  final bool isCheckingIn;
  final bool isBeforeGameInit;
  final bool isExpired;
  final Duration? timeRemaining;
  final VoidCallback? onCheckIn;

  const DuoScheduleCard({
    super.key,
    required this.tenMon,
    required this.soTinChi,
    required this.tietBatDau,
    required this.soTiet,
    required this.maPhong,
    required this.tenGiangVien,
    this.maNhom,
    required this.accentColor,
    required this.canCheckIn,
    required this.hasCheckedIn,
    this.isCheckingIn = false,
    this.isBeforeGameInit = false,
    this.isExpired = false,
    this.timeRemaining,
    this.onCheckIn,
  });

  int get tietKetThuc => tietBatDau + soTiet - 1;

  DuoBadgeVariant get _badgeVariant {
    if (accentColor == AppColors.green) return DuoBadgeVariant.success;
    if (accentColor == AppColors.orange) return DuoBadgeVariant.warning;
    if (accentColor == AppColors.purple) return DuoBadgeVariant.purple;
    if (accentColor == AppColors.red) return DuoBadgeVariant.danger;
    return DuoBadgeVariant.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      child: DuoCard(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppStyles.space3),
            DuoInfoRow(icon: Iconsax.clock, text: 'Tiết $tietBatDau - $tietKetThuc'),
            SizedBox(height: AppStyles.space2),
            DuoInfoRow(icon: Iconsax.location, text: maPhong),
            SizedBox(height: AppStyles.space2),
            DuoInfoRow(icon: Iconsax.teacher, text: tenGiangVien),
            if (maNhom != null && maNhom!.isNotEmpty) ...[
              SizedBox(height: AppStyles.space2),
              DuoInfoRow(icon: Iconsax.people, text: 'Nhóm $maNhom'),
            ],
            SizedBox(height: AppStyles.space3),
            _buildCheckInSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: AppStyles.roundedFull,
          ),
        ),
        SizedBox(width: AppStyles.space3),
        Expanded(
          child: Text(
            tenMon,
            style: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontBold,
              color: accentColor,
            ),
          ),
        ),
        DuoBadge(
          text: '$soTinChi TC',
          variant: _badgeVariant,
          size: DuoBadgeSize.sm,
        ),
      ],
    );
  }

  Widget _buildCheckInSection() {
    final coins = soTiet * GameService.coinsPerLesson;
    final xp = soTiet * GameService.xpPerLesson;
    final diamonds = soTiet * GameService.diamondsPerLesson;

    // Style theo trạng thái giống CTDT
    Color bgColor;
    Color borderColor;
    double borderWidth;
    Color labelColor;
    Color textColor;

    if (hasCheckedIn) {
      bgColor = AppColors.greenSoft;
      borderColor = AppColors.green.withValues(alpha: 0.3);
      borderWidth = 1;
      labelColor = AppColors.green;
      textColor = AppColors.green;
    } else if (canCheckIn) {
      bgColor = AppColors.yellowSoft;
      borderColor = AppColors.yellow;
      borderWidth = 2;
      labelColor = AppColors.yellowDark;
      textColor = AppColors.textPrimary;
    } else {
      bgColor = AppColors.background;
      borderColor = AppColors.border;
      borderWidth = 1;
      labelColor = AppColors.textTertiary;
      textColor = AppColors.textTertiary;
    }

    return Container(
      padding: EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.roundedLg,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCheckedIn ? 'Đã nhận thưởng' : 'Phần thưởng',
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    fontWeight: AppStyles.fontSemibold,
                    color: labelColor,
                  ),
                ),
                SizedBox(height: AppStyles.space1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      DuoCurrencyRow.coin(
                        value: coins,
                        size: DuoCurrencySize.xs,
                        valueStyle: TextStyle(
                          fontSize: AppStyles.textXs,
                          fontWeight: AppStyles.fontBold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(width: AppStyles.space2),
                      DuoCurrencyRow.diamond(
                        value: diamonds,
                        size: DuoCurrencySize.xs,
                        valueStyle: TextStyle(
                          fontSize: AppStyles.textXs,
                          fontWeight: AppStyles.fontBold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(width: AppStyles.space2),
                      DuoCurrencyRow.xp(
                        value: xp,
                        size: DuoCurrencySize.xs,
                        valueStyle: TextStyle(
                          fontSize: AppStyles.textXs,
                          fontWeight: AppStyles.fontBold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppStyles.space2),
          DuoLessonCheckIn(
            canCheckIn: canCheckIn,
            hasCheckedIn: hasCheckedIn,
            isLoading: isCheckingIn,
            isBeforeGameInit: isBeforeGameInit,
            isExpired: isExpired,
            timeRemaining: timeRemaining,
            soTiet: soTiet,
            onCheckIn: onCheckIn,
          ),
        ],
      ),
    );
  }

}
