import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DuoAppBar(title: 'Thông tin cá nhân', showLogo: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: AppStyles.space4),
            _buildPersonalInfo(),
            SizedBox(height: AppStyles.space4),
            _buildAcademicInfo(),
            SizedBox(height: AppStyles.space4),
            _buildMenuSection(),
            SizedBox(height: AppStyles.space4),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() => DuoProfileHeader(
          name: controller.studentInfo['ten_day_du'] ?? 'N/A',
          subtitle: 'MSSV: ${controller.studentInfo['ma_sv'] ?? 'N/A'}',
          email: controller.studentInfo['email'],
        )).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildPersonalInfo() {
    return Obx(() => DuoInfoSection(
          title: 'Thông tin cá nhân',
          titleIcon: Iconsax.user,
          items: [
            DuoInfoItem(
              icon: Iconsax.calendar,
              label: 'Ngày sinh',
              value: controller.studentInfo['ngay_sinh'] ?? 'N/A',
              iconColor: AppColors.orange,
            ),
            DuoInfoItem(
              icon: Iconsax.user_octagon,
              label: 'Giới tính',
              value: controller.studentInfo['gioi_tinh'] ?? 'N/A',
              iconColor: AppColors.purple,
            ),
            DuoInfoItem(
              icon: Iconsax.call,
              label: 'Điện thoại',
              value: controller.studentInfo['dien_thoai'] ?? 'N/A',
              iconColor: AppColors.green,
            ),
            DuoInfoItem(
              icon: Iconsax.location,
              label: 'Nơi sinh',
              value: controller.studentInfo['noi_sinh'] ?? 'N/A',
              iconColor: AppColors.primary,
            ),
          ],
        )).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAcademicInfo() {
    return Obx(() => DuoInfoSection(
          title: 'Thông tin học tập',
          titleIcon: Iconsax.book,
          items: [
            DuoInfoItem(
              icon: Iconsax.people,
              label: 'Lớp',
              value: controller.studentInfo['lop'] ?? 'N/A',
              iconColor: AppColors.primary,
            ),
            DuoInfoItem(
              icon: Iconsax.teacher,
              label: 'Ngành',
              value: controller.studentInfo['nganh'] ?? 'N/A',
              iconColor: AppColors.green,
            ),
            DuoInfoItem(
              icon: Iconsax.building,
              label: 'Khoa',
              value: controller.studentInfo['khoa'] ?? 'N/A',
              iconColor: AppColors.orange,
            ),
            DuoInfoItem(
              icon: Iconsax.calendar_1,
              label: 'Niên khóa',
              value: controller.studentInfo['nien_khoa'] ?? 'N/A',
              iconColor: AppColors.purple,
            ),
            DuoInfoItem(
              icon: Iconsax.status,
              label: 'Trạng thái',
              value: controller.studentInfo['hien_dien_sv'] ?? 'N/A',
              iconColor: AppColors.green,
            ),
          ],
        )).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMenuSection() {
    return DuoMenuItem(
      icon: Iconsax.logout,
      title: 'Đăng xuất',
      subtitle: 'Thoát khỏi tài khoản hiện tại',
      onTap: controller.logout,
      isDestructive: true,
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
