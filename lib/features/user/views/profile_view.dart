import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/extensions/animation_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/components/widgets.dart';
import '../../../features/gamification/shared/widgets/game_widgets.dart';

import '../../../routes/app_routes.dart';
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
            _buildGameStats(),
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
    return Obx(() {
      final info = controller.studentInfo.value;
      return DuoProfileHeader(
        name: info?.tenDayDu ?? 'N/A',
        subtitle: 'MSSV: ${info?.mssv ?? 'N/A'}',
        email: info?.email,
      );
    }).animateFadeSlide(slideBegin: -0.1);
  }

  Widget _buildPersonalInfo() {
    return Obx(() {
      final info = controller.studentInfo.value;
      return DuoInfoSection(
        title: 'Thông tin cá nhân',
        titleIcon: Iconsax.user,
        items: [
          DuoInfoItem(
            icon: Iconsax.calendar,
            label: 'Ngày sinh',
            value: info?.ngaySinh.isNotEmpty == true ? info!.ngaySinh : 'N/A',
            iconColor: AppColors.orange,
          ),
          DuoInfoItem(
            icon: Iconsax.user_octagon,
            label: 'Giới tính',
            value: info?.gioiTinh.isNotEmpty == true ? info!.gioiTinh : 'N/A',
            iconColor: AppColors.purple,
          ),
          DuoInfoItem(
            icon: Iconsax.call,
            label: 'Điện thoại',
            value: info?.soDienThoai.isNotEmpty == true ? info!.soDienThoai : 'N/A',
            iconColor: AppColors.green,
          ),
          DuoInfoItem(
            icon: Iconsax.location,
            label: 'Nơi sinh',
            value: info?.noiSinh.isNotEmpty == true ? info!.noiSinh : 'N/A',
            iconColor: AppColors.primary,
          ),
        ],
      );
    }).animateFadeSlide(delay: 100);
  }

  Widget _buildAcademicInfo() {
    return Obx(() {
      final info = controller.studentInfo.value;
      return DuoInfoSection(
        title: 'Thông tin học tập',
        titleIcon: Iconsax.book,
        items: [
          DuoInfoItem(
            icon: Iconsax.people,
            label: 'Lớp',
            value: info?.lop.isNotEmpty == true ? info!.lop : 'N/A',
            iconColor: AppColors.primary,
          ),
          DuoInfoItem(
            icon: Iconsax.teacher,
            label: 'Ngành',
            value: info?.nganh.isNotEmpty == true ? info!.nganh : 'N/A',
            iconColor: AppColors.green,
          ),
          DuoInfoItem(
            icon: Iconsax.building,
            label: 'Khoa',
            value: info?.khoa.isNotEmpty == true ? info!.khoa : 'N/A',
            iconColor: AppColors.orange,
          ),
          DuoInfoItem(
            icon: Iconsax.calendar_1,
            label: 'Niên khóa',
            value: info?.nienKhoa.isNotEmpty == true ? info!.nienKhoa : 'N/A',
            iconColor: AppColors.purple,
          ),
          DuoInfoItem(
            icon: Iconsax.status,
            label: 'Trạng thái',
            value: info?.hienDienSv.isNotEmpty == true ? info!.hienDienSv : 'N/A',
            iconColor: AppColors.green,
          ),
        ],
      );
    }).animateFadeSlide(delay: 200);
  }

  Widget _buildGameStats() {
    return Obx(() {
      final stats = controller.gameStats;
      return DuoCard(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.videogame_asset_rounded,
                    color: AppColors.purple, size: AppStyles.iconMd),
                SizedBox(width: AppStyles.space2),
                Text(
                  'Thành tích',
                  style: TextStyle(
                    fontSize: AppStyles.textLg,
                    fontWeight: AppStyles.fontBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppStyles.space4),

            // Level & XP Progress - dùng widget
            DuoLevelProgressCard(
              level: stats.level,
              currentXp: stats.currentXp,
              xpForNextLevel: stats.level * 100,
            ),

            SizedBox(height: AppStyles.space4),

            // Coins & Diamonds - dùng widget
            Row(
              children: [
                Expanded(child: DuoRewardTile.coinCard(value: stats.coins)),
                SizedBox(width: AppStyles.space3),
                Expanded(child: DuoRewardTile.diamondCard(value: stats.diamonds)),
              ],
            ),

            SizedBox(height: AppStyles.space4),

            // Attendance stats - dùng widget
            Row(
              children: [
                Expanded(
                  child: DuoMiniStat(
                    icon: Iconsax.tick_circle,
                    label: 'Đã học',
                    value: '${stats.totalLessonsAttended} tiết',
                    color: AppColors.green,
                  ),
                ),
                Expanded(
                  child: DuoMiniStat(
                    icon: Iconsax.close_circle,
                    label: 'Nghỉ',
                    value: '${stats.totalLessonsMissed} tiết',
                    color: AppColors.red,
                  ),
                ),
                Expanded(
                  child: DuoMiniStat(
                    icon: Iconsax.chart,
                    label: 'Chuyên cần',
                    value: '${stats.attendanceRate.toStringAsFixed(1)}%',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).animateFadeSlide(delay: 50);
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        DuoMenuItem(
          icon: Iconsax.medal_star,
          title: 'Thành tựu',
          subtitle: 'Xem tất cả thành tựu và phần thưởng',
          onTap: () => Get.toNamed(Routes.achievements),
        ).animateFadeSlide(delay: 300),
        SizedBox(height: AppStyles.space2),
        DuoMenuItem(
          icon: Iconsax.wallet,
          title: 'Ví của tôi',
          subtitle: 'Xem số dư và lịch sử giao dịch',
          onTap: () => Get.toNamed(Routes.wallet),
        ).animateFadeSlide(delay: 350),
        SizedBox(height: AppStyles.space2),
        DuoMenuItem(
          icon: Iconsax.message_question,
          title: 'Báo cáo lỗi',
          subtitle: 'Gửi phản hồi và báo cáo sự cố',
          onTap: () => Get.toNamed(Routes.bugReport),
        ).animateFadeSlide(delay: 400),
        SizedBox(height: AppStyles.space2),
        DuoMenuItem(
          icon: Iconsax.logout,
          title: 'Đăng xuất',
          subtitle: 'Thoát khỏi tài khoản hiện tại',
          onTap: controller.logout,
          isDestructive: true,
        ).animateFadeSlide(delay: 450),
      ],
    );
  }
}



