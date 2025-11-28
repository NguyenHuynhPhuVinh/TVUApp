import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Widget hiển thị animation XP progress bar chạy vèo vèo qua nhiều level
class DuoXpProgress extends StatefulWidget {
  final int totalXp;
  final int finalLevel;
  final VoidCallback? onComplete;

  const DuoXpProgress({
    super.key,
    required this.totalXp,
    required this.finalLevel,
    this.onComplete,
  });

  @override
  State<DuoXpProgress> createState() => _DuoXpProgressState();
}

class _DuoXpProgressState extends State<DuoXpProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentLevel = 1;
  int _displayXp = 0;
  int _xpForCurrentLevel = 100;
  double _progress = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this);
    _startLevelUpAnimation();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  int _xpNeededForLevel(int level) => level * 100;

  Future<void> _startLevelUpAnimation() async {
    if (_isAnimating) return;
    _isAnimating = true;

    int remainingXp = widget.totalXp;
    _currentLevel = 1;

    await Future.delayed(const Duration(milliseconds: 500));

    while (_currentLevel < widget.finalLevel) {
      final xpNeeded = _xpNeededForLevel(_currentLevel);

      // Level cao chạy nhanh hơn
      int durationMs;
      if (_currentLevel >= 500) {
        durationMs = 5;
      } else if (_currentLevel >= 100) {
        durationMs = 20;
      } else if (_currentLevel >= 50) {
        durationMs = 50;
      } else if (_currentLevel >= 20) {
        durationMs = 100;
      } else {
        durationMs = 300 - (_currentLevel * 20);
        if (durationMs < 100) durationMs = 100;
      }

      _progressController.duration = Duration(milliseconds: durationMs);
      _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.linear),
      );

      _progressController.reset();
      _progressController.addListener(_updateProgress);

      await _progressController.forward().orCancel;

      _progressController.removeListener(_updateProgress);

      remainingXp -= xpNeeded;
      setState(() {
        _currentLevel++;
        _xpForCurrentLevel = _xpNeededForLevel(_currentLevel);
        _progress = 0;
        _displayXp = 0;
      });

      if (widget.finalLevel - _currentLevel < 10) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    // Animation cuối cùng
    final finalXpInLevel = remainingXp;
    final finalProgress = finalXpInLevel / _xpNeededForLevel(_currentLevel);

    if (finalProgress > 0) {
      _progressController.duration = const Duration(milliseconds: 500);
      _progressAnimation = Tween<double>(begin: 0, end: finalProgress).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
      );

      _progressController.reset();
      _progressController.addListener(() {
        setState(() {
          _progress = _progressAnimation.value;
          _displayXp = (_progress * _xpNeededForLevel(_currentLevel)).round();
        });
      });

      await _progressController.forward();
    }

    _isAnimating = false;
    widget.onComplete?.call();
  }

  void _updateProgress() {
    setState(() {
      _progress = _progressAnimation.value;
      _displayXp = (_progress * _xpForCurrentLevel).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: AppStyles.rounded2xl,
        boxShadow: AppColors.buttonBoxShadow(AppColors.purpleDark),
      ),
      child: Column(
        children: [
          // Level display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $_currentLevel',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: AppStyles.fontBold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: AppColors.yellow, size: 20.w),
                  SizedBox(width: 4.w),
                  Text(
                    '$_displayXp / $_xpForCurrentLevel XP',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: AppStyles.space3),

          // Progress bar - chạy từ trái qua phải
          Container(
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppStyles.roundedFull,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final progressWidth = constraints.maxWidth * _progress.clamp(0.0, 1.0);
                return Stack(
                  children: [
                    // Progress fill - từ trái qua phải
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: progressWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.yellow, AppColors.orange],
                          ),
                          borderRadius: AppStyles.roundedFull,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.yellow.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
