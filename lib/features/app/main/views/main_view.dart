import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/components/widgets.dart';
import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../../../features/academic/schedule/views/schedule_view.dart';
import '../../../../features/academic/grades/views/grades_view.dart';
import '../../../../features/user/views/profile_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              ScheduleView(),
              GradesView(),
              ProfileView(),
            ],
          )),
      bottomNavigationBar: Obx(() {
            // Access observable để trigger rebuild
            final showScheduleBadge = controller.hasScheduleBadge;
            return DuoNavBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
              items: [
                const DuoNavItem(
                  icon: Iconsax.home_2,
                  activeIcon: Iconsax.home_15,
                  label: 'Trang chủ',
                ),
                DuoNavItem(
                  icon: Iconsax.calendar_1,
                  activeIcon: Iconsax.calendar,
                  label: 'Lịch học',
                  showBadge: showScheduleBadge,
                ),
                const DuoNavItem(
                  icon: Iconsax.chart_2,
                  activeIcon: Iconsax.chart_1,
                  label: 'Điểm',
                ),
                const DuoNavItem(
                  icon: Iconsax.user,
                  activeIcon: Iconsax.user,
                  label: 'Cá nhân',
                ),
              ],
            );
          }),
    );
  }
}



