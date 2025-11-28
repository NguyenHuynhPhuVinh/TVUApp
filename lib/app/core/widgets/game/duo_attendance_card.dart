import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../feedback/duo_progress.dart';

/// Duolingo-style Attendance Card - hiển thị tỷ lệ chuyên cần
class DuoAttendanceCard extends StatelessWidget {
  final double attendanceRate; // 0-100
  final int totalLessons;
  final int attendedLessons;
  final int missedLessons;
  final bool animated;
  final bool showDetails;

  const DuoAttendanceCard({
    super.key,
    required this.attendanceRate,
    required this.totalLessons,
    required this.attendedLessons,
    required this.missedLessons,
    this.animated = true,
    this.showDetails = true,
  });

  Color get _rateColor {
    if (attendanceRate >= 80) return AppColors.green;
    if (attendanceRate >= 50) return AppColors.orange;
    return AppColors.red;
  }

  Color get _rateDarkColor {
    if (attendanceRate >= 80) return AppColors.greenDark;
    if (attendanceRate >= 50) return AppColors.orangeDark;
    return AppColors.redDark;
  }

  String get _rateEmoji {
    if (attendanceRate >= 90) return '🌟';
    if (attendanceRate >= 80) return '😊';
    if (attendanceRate >= 70) return '🙂';
    if (attendanceRate >= 50) return '😐';
    return '😢';
  }

  String get _rateMessage {
    if (attendanceRate >= 90) return 'Xuất sắc!';
    if (attendanceRate >= 80) return 'Tốt lắm!';
    if (attendanceRate >= 70) return 'Khá tốt';
    if (attendanceRate >= 50) return 'Cần cố gắng';
    return 'Cần cải thiện';
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: EdgeInsets.all(AppStyles.space5),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.rounded2xl,
        border: Border.all(color: AppColors.border, width: AppStyles.border2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_rounded, color: AppColors.primary, size: 22.w),
              SizedBox(width: AppStyles.space2),
              Text(
                'Thống kê chuyên cần',
                style: TextStyle(
                  fontSize: AppStyles.textLg,
                  fontWeight: AppStyles.fontBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space4),

          // Circular progress with rate
          _buildCircularRate(),

          SizedBox(height: AppStyles.space4),

          // Progress bar
          DuoProgressBar(
            progress: attendanceRate / 100,
            height: 14.h,
            progressColor: _rateColor,
            shadowColor: _rateDarkColor,
          ),

          if (showDetails) ...[
            SizedBox(height: AppStyles.space4),
            // Stats row
            _buildStatsRow(),
          ],
        ],
      ),
    );

    if (animated) {
      card = card.animate().fadeIn(duration: 400.ms).slideY(
            begin: 0.2,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOut,
          );
    }

    return card;
  }

  Widget _buildCircularRate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Emoji
        Text(
          _rateEmoji,
          style: TextStyle(fontSize: 40.sp),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              duration: 1000.ms,
            ),
        SizedBox(width: AppStyles.space4),
        // Rate percentage
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${attendanceRate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: AppStyles.fontBold,
                color: _rateColor,
              ),
            ),
            Text(
              _rateMessage,
              style: TextStyle(
                fontSize: AppStyles.textBase,
                fontWeight: AppStyles.fontMedium,
                color: _rateColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space3,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.roundedXl,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.calendar_today_rounded,
              color: AppColors.primary,
              label: 'Tổng tiết',
              value: '$totalLessons',
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_rounded,
              color: AppColors.green,
              label: 'Đã học',
              value: '$attendedLessons',
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.cancel_rounded,
              color: AppColors.red,
              label: 'Nghỉ',
              value: '$missedLessons',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18.w),
        SizedBox(height: AppStyles.space1),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textLg,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppStyles.textXs,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Duolingo-style Streak Card - hiển thị chuỗi ngày học liên tiếp
class DuoStreakCard extends StatelessWidget {
  final int streakDays;
  final bool isActive;
  final VoidCallback? onTap;

  const DuoStreakCard({
    super.key,
    required this.streakDays,
    this.isActive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppStyles.space4),
        decoration: BoxDecoration(
          gradient: isActive
              ? AppColors.orangeGradient
              : const LinearGradient(
                  colors: [AppColors.backgroundDark, AppColors.border],
                ),
          borderRadius: AppStyles.rounded2xl,
          boxShadow: [
            BoxShadow(
              color: isActive ? AppColors.orangeDark : AppColors.border,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Fire icon
            Image.asset(
              'assets/game/main/fire_1st_outline_256px.png',
              width: 40.w,
              height: 40.w,
              errorBuilder: (_, __, ___) => Icon(
                Icons.local_fire_department_rounded,
                size: 40.w,
                color: isActive ? Colors.white : AppColors.textTertiary,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                  duration: 800.ms,
                ),
            SizedBox(width: AppStyles.space3),
            // Streak info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streakDays ngày',
                    style: TextStyle(
                      fontSize: AppStyles.textXl,
                      fontWeight: AppStyles.fontBold,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    isActive ? 'Chuỗi học tập' : 'Chuỗi đã mất',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: isActive ? Colors.white : AppColors.textTertiary,
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }
}

