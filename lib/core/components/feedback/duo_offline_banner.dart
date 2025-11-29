import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../infrastructure/network/connectivity_service.dart';

/// Banner hiển thị khi offline
class DuoOfflineBanner extends StatelessWidget {
  const DuoOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();
    
    return Obx(() {
      if (connectivity.isConnected.value) {
        return const SizedBox.shrink();
      }
      
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(
                Iconsax.wifi_square,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Không có kết nối mạng - Đang dùng dữ liệu offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Widget wrapper tự động hiển thị offline banner
class OfflineAwareScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const OfflineAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      body: Column(
        children: [
          const DuoOfflineBanner(),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
