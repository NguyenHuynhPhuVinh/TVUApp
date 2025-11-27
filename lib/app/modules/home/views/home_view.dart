import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TVUApp'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () => Get.toNamed('/news'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 24.h),
              _buildQuickActions(),
              SizedBox(height: 24.h),
              _buildTodaySchedule(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildWelcomeCard() {
    return Obx(() => Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Get.theme.primaryColor, Get.theme.primaryColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.white,
                child: Icon(Iconsax.user, size: 28.sp, color: Get.theme.primaryColor),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.studentName.value.isEmpty 
                          ? 'Xin chào!' 
                          : controller.studentName.value,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.studentId.value.isEmpty 
                          ? 'Đang tải...' 
                          : 'MSSV: ${controller.studentId.value}',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.book, size: 16.sp, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  controller.className.value.isEmpty 
                      ? 'Đang tải...' 
                      : controller.className.value,
                  style: TextStyle(fontSize: 13.sp, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Iconsax.calendar, 'label': 'Thời khóa biểu', 'route': '/schedule'},
      {'icon': Iconsax.chart, 'label': 'Điểm học tập', 'route': '/grades'},
      {'icon': Iconsax.wallet, 'label': 'Học phí', 'route': '/tuition'},
      {'icon': Iconsax.book_1, 'label': 'CTĐT', 'route': '/curriculum'},
      {'icon': Iconsax.document_text, 'label': 'Thông báo', 'route': '/news'},
      {'icon': Iconsax.user, 'label': 'Hồ sơ', 'route': '/profile'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chức năng', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionItem(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: () => Get.toNamed(action['route'] as String),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32.sp, color: Get.theme.primaryColor),
            SizedBox(height: 8.h),
            Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lịch học hôm nay', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => Get.toNamed('/schedule'), child: const Text('Xem tất cả')),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.todaySchedule.isEmpty) {
            return Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
              child: Center(
                child: Column(
                  children: [
                    Icon(Iconsax.calendar_tick, size: 48.sp, color: Colors.grey),
                    SizedBox(height: 12.h),
                    Text('Không có lịch học hôm nay', style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.todaySchedule.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) => _buildScheduleItem(controller.todaySchedule[index]),
          );
        }),
      ],
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> item) {
    final tietBatDau = item['tiet_bat_dau'] ?? 0;
    final soTiet = item['so_tiet'] ?? 0;
    final tietKetThuc = tietBatDau + soTiet - 1;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(width: 4.w, height: 70.h, decoration: BoxDecoration(color: Get.theme.primaryColor, borderRadius: BorderRadius.circular(2.r))),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['ten_mon'] ?? 'N/A', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Iconsax.clock, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text('Tiết $tietBatDau - $tietKetThuc', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Iconsax.location, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Expanded(child: Text(item['ma_phong'] ?? 'N/A', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Iconsax.teacher, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Expanded(child: Text(item['ten_giang_vien'] ?? 'N/A', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
