import 'package:flutter/material.dart';
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
      appBar: DuoAppBar(
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeSection(controller: controller),
            SizedBox(height: AppStyles.space6),
            _QuickActionsSection(),
            SizedBox(height: AppStyles.space6),
            _TodayScheduleSection(controller: controller),
            SizedBox(height: AppStyles.space4),
          ],
        ),
      ),
    );
  }
}

/// Section chào mừng
class _WelcomeSection extends StatelessWidget {
  final HomeController controller;

  const _WelcomeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DuoWelcomeCard(
          name: controller.studentName.value,
          studentId: controller.studentId.value,
          level: controller.level,
          coins: controller.coins,
          diamonds: controller.diamonds,
        )).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Section chức năng nhanh
class _QuickActionsSection extends StatelessWidget {
  static const _actions = [
    {'icon': Iconsax.calendar, 'label': 'Thời khóa biểu', 'route': '/schedule', 'color': AppColors.primary},
    {'icon': Iconsax.chart, 'label': 'Điểm học tập', 'route': '/grades', 'color': AppColors.green},
    {'icon': Iconsax.wallet, 'label': 'Học phí', 'route': '/tuition', 'color': AppColors.orange},
    {'icon': Iconsax.book_1, 'label': 'CTĐT', 'route': '/curriculum', 'color': AppColors.purple},
    {'icon': Iconsax.document_text, 'label': 'Thông báo', 'route': '/news', 'color': AppColors.red},
    {'icon': Iconsax.user, 'label': 'Hồ sơ', 'route': '/profile', 'color': AppColors.primary},
  ];

  @override
  Widget build(BuildContext context) {
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
          itemCount: _actions.length,
          itemBuilder: (context, index) {
            final action = _actions[index];
            return DuoQuickAction(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              onTap: () => Get.toNamed(action['route'] as String),
            ).animate()
                .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
          },
        ),
      ],
    );
  }
}

/// Section lịch học hôm nay
class _TodayScheduleSection extends StatelessWidget {
  final HomeController controller;

  const _TodayScheduleSection({required this.controller});

  static const _colors = [
    AppColors.primary,
    AppColors.green,
    AppColors.orange,
    AppColors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: AppStyles.space4),
        Obx(() {
          if (controller.todaySchedule.isEmpty) {
            return DuoEmptyState(
              icon: Iconsax.calendar_tick,
              title: 'Không có lịch học hôm nay',
              subtitle: 'Hãy tận hưởng ngày nghỉ!',
              iconColor: AppColors.green,
              iconBackgroundColor: AppColors.greenSoft,
            ).animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.todaySchedule.length,
            separatorBuilder: (_, __) => SizedBox(height: AppStyles.space3),
            itemBuilder: (context, index) {
              final item = controller.todaySchedule[index];
              return DuoTodayScheduleCard(
                tenMon: item['ten_mon'] ?? 'N/A',
                tietBatDau: item['tiet_bat_dau'] ?? 0,
                soTiet: item['so_tiet'] ?? 0,
                maPhong: item['ma_phong'] ?? 'N/A',
                tenGiangVien: item['ten_giang_vien'] ?? 'N/A',
                accentColor: _colors[index % _colors.length],
              ).animate()
                  .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                  .slideX(begin: 0.1, end: 0);
            },
          );
        }),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
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
            padding: EdgeInsets.symmetric(
              horizontal: AppStyles.space3,
              vertical: AppStyles.space1,
            ),
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
    );
  }
}
