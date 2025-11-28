import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/extensions/animation_extensions.dart';
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
    // Listen cả studentName/studentId và gameService.stats
    return Obx(() {
      final stats = controller.gameStats;
      return DuoWelcomeCard(
        name: controller.studentName.value,
        studentId: controller.studentId.value,
        level: stats.level,
        coins: stats.coins,
        diamonds: stats.diamonds,
      );
    }).animateFadeSlide();
  }
}

/// Section chức năng nhanh
class _QuickActionsSection extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();
  
  static const _actions = [
    {'icon': Iconsax.calendar, 'label': 'Thời khóa biểu', 'route': '/schedule', 'color': AppColors.primary, 'badgeKey': 'schedule'},
    {'icon': Iconsax.chart, 'label': 'Điểm học tập', 'route': '/grades', 'color': AppColors.green, 'badgeKey': 'grades'},
    {'icon': Iconsax.wallet, 'label': 'Học phí', 'route': '/tuition', 'color': AppColors.orange, 'badgeKey': 'tuition'},
    {'icon': Iconsax.book_1, 'label': 'CTĐT', 'route': '/curriculum', 'color': AppColors.purple, 'badgeKey': 'curriculum'},
    {'icon': Iconsax.shop, 'label': 'Cửa hàng', 'route': '/shop', 'color': AppColors.yellow, 'badgeKey': null},
    {'icon': Iconsax.user, 'label': 'Hồ sơ', 'route': '/profile', 'color': AppColors.purple, 'badgeKey': null},
  ];

  bool _getBadgeState(String? badgeKey) {
    if (badgeKey == 'schedule') {
      return controller.hasPendingCheckIn.value;
    } else if (badgeKey == 'tuition') {
      return controller.hasUnclaimedTuitionBonus.value;
    } else if (badgeKey == 'curriculum') {
      return controller.hasUnclaimedCurriculumReward.value;
    } else if (badgeKey == 'grades') {
      return controller.hasUnclaimedRankReward.value;
    }
    return false;
  }

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
            final badgeKey = action['badgeKey'] as String?;
            
            // Wrap từng item có badge trong Obx riêng
            if (badgeKey != null) {
              return Obx(() => DuoQuickAction(
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                color: action['color'] as Color,
                showBadge: _getBadgeState(badgeKey),
                onTap: () => Get.toNamed(action['route'] as String),
              )).animateScaleFade(delay: (index * 50).toDouble(), scaleBegin: 0.8);
            }
            
            return DuoQuickAction(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              onTap: () => Get.toNamed(action['route'] as String),
            ).animateScaleFade(delay: (index * 50).toDouble(), scaleBegin: 0.8);
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
            ).animateScaleFade(scaleBegin: 0.95);
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.todaySchedule.length,
            separatorBuilder: (context, index) => SizedBox(height: AppStyles.space3),
            itemBuilder: (context, index) {
              final item = controller.todaySchedule[index];
              return DuoTodayScheduleCard(
                tenMon: item['ten_mon'] ?? 'N/A',
                tietBatDau: item['tiet_bat_dau'] ?? 0,
                soTiet: item['so_tiet'] ?? 0,
                maPhong: item['ma_phong'] ?? 'N/A',
                tenGiangVien: item['ten_giang_vien'] ?? 'N/A',
                accentColor: _colors[index % _colors.length],
              ).animateFadeSlideRight(delay: (index * 100).toDouble(), slideBegin: 0.1);
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
