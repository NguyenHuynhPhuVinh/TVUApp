import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  // Duolingo-style colors (blue theme)
  static const Color _primaryBlue = Color(0xFF1CB0F6);
  static const Color _darkBlue = Color(0xFF1899D6);
  static const Color _backgroundColor = Color(0xFF1CB0F6);

  @override
  Widget build(BuildContext context) {
    // Access controller to ensure it's initialized
    final _ = controller;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon container với style Duolingo
                  Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFFE5E5E5),
                          width: 4.h,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.school_rounded,
                        size: 80.sp,
                        color: _primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Title
                  Text(
                    'TVU Sinh Viên',
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Subtitle
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: _darkBlue,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Cổng thông tin Sinh viên',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  // Loading indicator - hiển thị progress nếu đang sync
                  Obx(() => controller.isFirstTimeSync.value
                      ? _buildSyncProgress()
                      : _buildLoadingDots()),
                ],
              ),
            ),
            const Spacer(flex: 2),
            // Footer
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _darkBlue,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'v1.0',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tạo bởi TomiSakae',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = ((value + delay) % 1.0);
            final scale = 0.5 + (animValue < 0.5 ? animValue : 1 - animValue);
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildSyncProgress() {
    return Column(
      children: [
        // Progress bar
        Container(
          width: 200.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: _darkBlue,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Obx(() => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: controller.syncProgress.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              )),
        ),
        SizedBox(height: 16.h),
        // Status text
        Obx(() => Text(
              controller.syncStatus.value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )),
      ],
    );
  }
}
