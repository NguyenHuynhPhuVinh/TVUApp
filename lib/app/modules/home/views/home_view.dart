import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';

import '../../../core/widgets/widgets.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            SizedBox(height: AppStyles.space6),
            _buildQuickActions(),
            SizedBox(height: AppStyles.space6),
            _buildTodaySchedule(),
            SizedBox(height: AppStyles.space4),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return DuoAppBar(
      title: 'TVU App',
      showLogo: true,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: AppStyles.space3),
          child: DuoIconButton(
            icon: Iconsax.notification,
            variant: DuoIconButtonVariant.white,
            size: DuoIconButtonSize.md,
            onTap: () => Get.toNamed('/news'),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Obx(() => DuoCard(
      padding: EdgeInsets.all(AppStyles.space5),
      backgroundColor: AppColors.primary,
      shadowColor: AppColors.primaryDark,
      shadowOffset: AppStyles.shadowLg,
      hasBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppStyles.avatarLg,
                height: AppStyles.avatarLg,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: AppStyles.border3),
                ),
                child: Icon(Iconsax.user, color: AppColors.primary, size: AppStyles.iconLg),
              ),
              SizedBox(width: AppStyles.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.studentName.value.isEmpty
                          ? 'Xin chào!'
                          : controller.studentName.value,
                      style: TextStyle(
                        fontSize: AppStyles.textLg,
                        fontWeight: AppStyles.fontBold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppStyles.space1),
                    Text(
                      controller.studentId.value.isEmpty
                          ? 'Đang tải...'
                          : 'MSSV: ${controller.studentId.value}',
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: AppColors.withAlpha(Colors.white, 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space4),
          // Game stats bar
          DuoGameStatsBar(
            level: controller.level,
            coins: controller.coins,
            diamonds: controller.diamonds,
          ),
        ],
      ),
    )).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Iconsax.calendar, 'label': 'Thời khóa biểu', 'route': '/schedule', 'color': AppColors.primary},
      {'icon': Iconsax.chart, 'label': 'Điểm học tập', 'route': '/grades', 'color': AppColors.green},
      {'icon': Iconsax.wallet, 'label': 'Học phí', 'route': '/tuition', 'color': AppColors.orange},
      {'icon': Iconsax.book_1, 'label': 'CTĐT', 'route': '/curriculum', 'color': AppColors.purple},
      {'icon': Iconsax.document_text, 'label': 'Thông báo', 'route': '/news', 'color': AppColors.red},
      {'icon': Iconsax.user, 'label': 'Hồ sơ', 'route': '/profile', 'color': AppColors.primary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chức năng',
          style: TextStyle(
            fontSize: AppStyles.textLg,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppStyles.space4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppStyles.space3,
            mainAxisSpacing: AppStyles.space3,
            childAspectRatio: 0.95,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionItem(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              onTap: () => Get.toNamed(action['route'] as String),
            ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
          },
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return DuoPressableCard(
      padding: EdgeInsets.all(AppStyles.space2),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: AppColors.withAlpha(color, 0.1),
              borderRadius: AppStyles.roundedLg,
            ),
            child: Icon(icon, size: AppStyles.iconMd, color: color),
          ),
          SizedBox(height: AppStyles.space1),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: AppStyles.fontSemibold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
            Text(
              'Lịch học hôm nay',
              style: TextStyle(
                fontSize: AppStyles.textLg,
                fontWeight: AppStyles.fontBold,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/schedule'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space1),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppStyles.roundedFull,
                ),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppStyles.space4),
        Obx(() {
          if (controller.todaySchedule.isEmpty) {
            return _buildEmptySchedule();
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.todaySchedule.length,
            separatorBuilder: (context, index) => SizedBox(height: AppStyles.space3),
            itemBuilder: (context, index) => _buildScheduleItem(controller.todaySchedule[index], index),
          );
        }),
      ],
    );
  }

  Widget _buildEmptySchedule() {
    return DuoEmptyState(
      icon: Iconsax.calendar_tick,
      title: 'Không có lịch học hôm nay',
      subtitle: 'Hãy tận hưởng ngày nghỉ!',
      iconColor: AppColors.green,
      iconBackgroundColor: AppColors.greenSoft,
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildScheduleItem(Map<String, dynamic> item, int index) {
    final tietBatDau = item['tiet_bat_dau'] ?? 0;
    final soTiet = item['so_tiet'] ?? 0;
    final tietKetThuc = tietBatDau + soTiet - 1;

    final colors = [AppColors.primary, AppColors.green, AppColors.orange, AppColors.purple];
    final color = colors[index % colors.length];

    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppStyles.roundedFull,
            ),
          ),
          SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['ten_mon'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: AppStyles.textBase,
                    fontWeight: AppStyles.fontSemibold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppStyles.space2),
                DuoInfoRow(icon: Iconsax.clock, text: 'Tiết $tietBatDau - $tietKetThuc'),
                SizedBox(height: AppStyles.space1),
                DuoInfoRow(icon: Iconsax.location, text: item['ma_phong'] ?? 'N/A'),
                SizedBox(height: AppStyles.space1),
                DuoInfoRow(icon: Iconsax.teacher, text: item['ten_giang_vien'] ?? 'N/A'),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppStyles.space3, vertical: AppStyles.space2),
            decoration: BoxDecoration(
              color: AppColors.withAlpha(color, 0.1),
              borderRadius: AppStyles.roundedLg,
            ),
            child: Column(
              children: [
                Text(
                  '$soTiet',
                  style: TextStyle(
                    fontSize: AppStyles.textXl,
                    fontWeight: AppStyles.fontBold,
                    color: color,
                  ),
                ),
                Text(
                  'tiết',
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
  }



}
