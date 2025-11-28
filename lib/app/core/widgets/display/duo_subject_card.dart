import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';
import '../feedback/duo_badge.dart';
import '../game/duo_currency_row.dart';
import '../../../data/services/game_service.dart';

/// Trạng thái nhận thưởng môn học
enum SubjectRewardStatus {
  notCompleted,  // Chưa đạt môn
  canClaim,      // Có thể nhận thưởng
  claimed,       // Đã nhận thưởng
  claiming,      // Đang xử lý
}

/// Card hiển thị môn học trong CTĐT
class DuoSubjectCard extends StatelessWidget {
  final String tenMon;
  final String maMon;
  final String soTinChi;
  final bool isCompleted;
  final bool isRequired;
  final String? lyThuyet;
  final String? thucHanh;
  final SubjectRewardStatus rewardStatus;
  final VoidCallback? onClaimReward;

  const DuoSubjectCard({
    super.key,
    required this.tenMon,
    required this.maMon,
    required this.soTinChi,
    required this.isCompleted,
    required this.isRequired,
    this.lyThuyet,
    this.thucHanh,
    this.rewardStatus = SubjectRewardStatus.notCompleted,
    this.onClaimReward,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppStyles.space3),
          _buildTags(),
          if (isCompleted) ...[
            SizedBox(height: AppStyles.space3),
            _buildRewardSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardSection() {
    final credits = int.tryParse(soTinChi) ?? 0;
    final reward = GameService.calculateSubjectReward(credits);
    
    // Màu nền và border theo trạng thái
    Color bgColor;
    Color borderColor;
    double borderWidth;
    
    switch (rewardStatus) {
      case SubjectRewardStatus.claimed:
        bgColor = AppColors.greenSoft;
        borderColor = AppColors.green.withValues(alpha: 0.3);
        borderWidth = 1;
        break;
      case SubjectRewardStatus.canClaim:
        bgColor = AppColors.yellowSoft;
        borderColor = AppColors.yellow;
        borderWidth = 2;
        break;
      case SubjectRewardStatus.claiming:
        bgColor = AppColors.primarySoft;
        borderColor = AppColors.primary;
        borderWidth = 1.5;
        break;
      default:
        bgColor = AppColors.background;
        borderColor = AppColors.border;
        borderWidth = 1;
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
                  rewardStatus == SubjectRewardStatus.claimed 
                      ? 'Đã nhận thưởng' 
                      : 'Phần thưởng',
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: rewardStatus == SubjectRewardStatus.claimed
                        ? AppColors.green
                        : rewardStatus == SubjectRewardStatus.canClaim
                            ? AppColors.yellowDark
                            : AppColors.textTertiary,
                    fontWeight: AppStyles.fontSemibold,
                  ),
                ),
                SizedBox(height: AppStyles.space1),
                Row(
                  children: [
                    DuoCurrencyRow.coin(
                      value: reward['coins']!,
                      size: DuoCurrencySize.xs,
                    ),
                    SizedBox(width: AppStyles.space2),
                    DuoCurrencyRow.diamond(
                      value: reward['diamonds']!,
                      size: DuoCurrencySize.xs,
                    ),
                    SizedBox(width: AppStyles.space2),
                    DuoCurrencyRow.xp(
                      value: reward['xp']!,
                      size: DuoCurrencySize.xs,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppStyles.space2),
          _buildRewardButton(),
        ],
      ),
    );
  }

  Widget _buildRewardButton() {
    switch (rewardStatus) {
      case SubjectRewardStatus.notCompleted:
        return const SizedBox.shrink();
      
      case SubjectRewardStatus.claimed:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyles.space3,
            vertical: AppStyles.space2,
          ),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: AppStyles.roundedFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.tick_circle, size: 14.sp, color: Colors.white),
              SizedBox(width: AppStyles.space1),
              Text(
                'Đã nhận',
                style: TextStyle(
                  fontSize: AppStyles.textXs,
                  fontWeight: AppStyles.fontBold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      
      case SubjectRewardStatus.claiming:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyles.space3,
            vertical: AppStyles.space2,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: AppStyles.roundedFull,
          ),
          child: SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        );
      
      case SubjectRewardStatus.canClaim:
        return GestureDetector(
          onTap: onClaimReward,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyles.space3,
              vertical: AppStyles.space2,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.yellow, AppColors.yellowLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppStyles.roundedFull,
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.giftPurple,
                  width: 16.w,
                  height: 16.w,
                  errorBuilder: (_, __, ___) => Icon(
                    Iconsax.gift,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppStyles.space1),
                Text(
                  'Nhận',
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    fontWeight: AppStyles.fontBold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.green : AppColors.textTertiary,
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
              ),
              SizedBox(height: AppStyles.space1),
              Text(
                maMon,
                style: TextStyle(
                  fontSize: AppStyles.textSm,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
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
        color: isCompleted ? AppColors.greenSoft : AppColors.backgroundDark,
        borderRadius: AppStyles.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            Icon(Iconsax.tick_circle, size: 14.sp, color: AppColors.green),
          if (isCompleted) SizedBox(width: AppStyles.space1),
          Text(
            isCompleted ? 'Đạt' : 'Chưa học',
            style: TextStyle(
              fontSize: AppStyles.textXs,
              fontWeight: AppStyles.fontSemibold,
              color: isCompleted ? AppColors.green : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: AppStyles.space2,
      runSpacing: AppStyles.space2,
      children: [
        DuoBadge.tag(text: '$soTinChi TC', color: AppColors.primary),
        if (isRequired)
          DuoBadge.tag(text: 'Bắt buộc', color: AppColors.orange)
        else
          DuoBadge.tag(text: 'Tự chọn', color: AppColors.purple),
        if (lyThuyet != null && lyThuyet != '0' && lyThuyet!.isNotEmpty)
          DuoBadge.tag(text: 'LT: $lyThuyet', color: AppColors.green),
        if (thucHanh != null && thucHanh != '0' && thucHanh!.isNotEmpty)
          DuoBadge.tag(text: 'TH: $thucHanh', color: AppColors.primary),
      ],
    );
  }
}


