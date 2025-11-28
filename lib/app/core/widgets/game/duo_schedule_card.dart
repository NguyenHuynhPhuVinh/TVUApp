import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';
import '../feedback/duo_badge.dart';
import '../display/duo_info_row.dart';
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
    return Row(
      children: [
        Expanded(child: _buildRewardPreview()),
        SizedBox(width: AppStyles.space2),
        DuoLessonCheckIn(
          canCheckIn: canCheckIn,
          hasCheckedIn: hasCheckedIn,
          isLoading: isCheckingIn,
          isBeforeGameInit: isBeforeGameInit,
          timeRemaining: timeRemaining,
          soTiet: soTiet,
          onCheckIn: onCheckIn,
        ),
      ],
    );
  }

  Widget _buildRewardPreview() {
    final coins = soTiet * 250000;
    final xp = soTiet * 1250;
    final diamonds = soTiet * 413;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space2,
        vertical: AppStyles.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        borderRadius: AppStyles.roundedLg,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/game/item/gift_red_gift_1st_64px.png',
              width: 14.w,
              height: 14.w,
              errorBuilder: (_, __, ___) =>
                  Icon(Iconsax.gift, color: AppColors.yellow, size: 12.w),
            ),
            SizedBox(width: AppStyles.space1),
            _buildRewardItem(
              'assets/game/currency/coin_golden_coin_1st_64px.png',
              coins,
            ),
            SizedBox(width: AppStyles.space1),
            _buildRewardItem(
              'assets/game/currency/diamond_blue_diamond_1st_64px.png',
              diamonds,
            ),
            SizedBox(width: AppStyles.space1),
            _buildRewardItem(
              'assets/game/main/star_golden_star_1st_64px.png',
              xp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(String assetPath, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetPath,
          width: 12.w,
          height: 12.w,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        SizedBox(width: 2.w),
        Text(
          '+${_formatNumber(value)}',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: AppStyles.fontBold,
            color: AppColors.yellowDark,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
