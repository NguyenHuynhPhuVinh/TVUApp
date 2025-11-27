import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/sync_controller.dart';

class SyncLoadingView extends GetView<SyncController> {
  const SyncLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo hoặc icon
              Icon(
                Icons.cloud_sync_rounded,
                size: 80.sp,
                color: Colors.white,
              ),
              SizedBox(height: 32.h),
              
              // Tiêu đề
              Text(
                'Đang đồng bộ dữ liệu',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              
              // Trạng thái hiện tại
              Obx(() => Text(
                controller.currentStatus.value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              )),
              SizedBox(height: 32.h),
              
              // Progress bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                child: Obx(() => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: controller.progress.value,
                        minHeight: 8.h,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${(controller.progress.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )),
              ),
              SizedBox(height: 48.h),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
