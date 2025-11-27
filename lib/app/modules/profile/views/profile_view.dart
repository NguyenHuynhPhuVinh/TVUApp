import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.loadProfile,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildProfileHeader(),
              SizedBox(height: 24.h),
              _buildInfoSection(),
              SizedBox(height: 24.h),
              _buildMenuSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() => Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Get.theme.primaryColor, Get.theme.primaryColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48.r,
            backgroundColor: Colors.white,
            child: Icon(Iconsax.user, size: 48.sp, color: Get.theme.primaryColor),
          ),
          SizedBox(height: 16.h),
          Text(
            controller.studentInfo['ten_day_du'] ?? 'N/A',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'MSSV: ${controller.studentInfo['ma_sv'] ?? 'N/A'}',
            style: TextStyle(fontSize: 16.sp, color: Colors.white70),
          ),
          SizedBox(height: 4.h),
          Text(
            controller.studentInfo['email'] ?? '',
            style: TextStyle(fontSize: 14.sp, color: Colors.white60),
          ),
        ],
      ),
    ));
  }

  Widget _buildInfoSection() {
    return Obx(() => Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin cá nhân',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Iconsax.calendar, 'Ngày sinh', controller.studentInfo['ngay_sinh'] ?? 'N/A'),
          _buildInfoRow(Iconsax.user, 'Giới tính', controller.studentInfo['gioi_tinh'] ?? 'N/A'),
          _buildInfoRow(Iconsax.call, 'Điện thoại', controller.studentInfo['dien_thoai'] ?? 'N/A'),
          _buildInfoRow(Iconsax.location, 'Nơi sinh', controller.studentInfo['noi_sinh'] ?? 'N/A'),
          Divider(height: 24.h),
          Text(
            'Thông tin học tập',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Iconsax.book, 'Lớp', controller.studentInfo['lop'] ?? 'N/A'),
          _buildInfoRow(Iconsax.teacher, 'Ngành', controller.studentInfo['nganh'] ?? 'N/A'),
          _buildInfoRow(Iconsax.building, 'Khoa', controller.studentInfo['khoa'] ?? 'N/A'),
          _buildInfoRow(Iconsax.calendar_1, 'Niên khóa', controller.studentInfo['nien_khoa'] ?? 'N/A'),
          _buildInfoRow(Iconsax.status, 'Trạng thái', controller.studentInfo['hien_dien_sv'] ?? 'N/A'),
        ],
      ),
    ));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Get.theme.primaryColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Iconsax.book_1,
          title: 'Chương trình đào tạo',
          onTap: () => Get.toNamed('/curriculum'),
        ),
        _buildMenuItem(
          icon: Iconsax.notification,
          title: 'Thông báo',
          onTap: () => Get.toNamed('/news'),
        ),
        SizedBox(height: 16.h),
        _buildMenuItem(
          icon: Iconsax.logout,
          title: 'Đăng xuất',
          onTap: controller.logout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Get.theme.primaryColor),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : null)),
        trailing: const Icon(Iconsax.arrow_right_3, size: 18),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        tileColor: Get.theme.cardColor,
      ),
    );
  }
}
