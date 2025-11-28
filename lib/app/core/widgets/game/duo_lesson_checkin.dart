import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_button.dart';

/// Widget hiển thị nút điểm danh buổi học
class DuoLessonCheckIn extends StatefulWidget {
  final bool canCheckIn;
  final bool hasCheckedIn;
  final Duration? timeRemaining;
  final int soTiet;
  final VoidCallback? onCheckIn;

  const DuoLessonCheckIn({
    super.key,
    required this.canCheckIn,
    required this.hasCheckedIn,
    this.timeRemaining,
    required this.soTiet,
    this.onCheckIn,
  });

  @override
  State<DuoLessonCheckIn> createState() => _DuoLessonCheckInState();
}

class _DuoLessonCheckInState extends State<DuoLessonCheckIn> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeRemaining;
    _startTimer();
  }

  @override
  void didUpdateWidget(DuoLessonCheckIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeRemaining != oldWidget.timeRemaining) {
      _remaining = widget.timeRemaining;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remaining != null && _remaining!.inSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remaining != null && _remaining!.inSeconds > 0) {
          setState(() {
            _remaining = _remaining! - const Duration(seconds: 1);
          });
        } else {
          timer.cancel();
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    // Đã điểm danh
    if (widget.hasCheckedIn) {
      return _buildCheckedInState();
    }

    // Có thể điểm danh
    final canCheck = widget.canCheckIn || (_remaining == null || _remaining!.inSeconds <= 0);
    if (canCheck) {
      return _buildCanCheckInState();
    }

    // Chưa đến giờ
    return _buildWaitingState();
  }

  Widget _buildCheckedInState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space2),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: AppStyles.roundedLg,
        border: Border.all(color: AppColors.green, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18.w),
          SizedBox(width: AppStyles.space2),
          Text(
            'Đã điểm danh',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontBold,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanCheckInState() {
    return DuoButton(
      text: 'Điểm danh',
      icon: Iconsax.tick_circle,
      variant: DuoButtonVariant.success,
      size: DuoButtonSize.sm,
      fullWidth: false,
      onPressed: widget.onCheckIn,
    );
  }

  Widget _buildWaitingState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space2),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: AppStyles.roundedLg,
        border: Border.all(color: AppColors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.timer_1, color: AppColors.orange, size: 16.w),
          SizedBox(width: AppStyles.space2),
          Text(
            _formatDuration(_remaining ?? Duration.zero),
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontBold,
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
