import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/widgets/widgets.dart';
import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../schedule/views/schedule_view.dart';
import '../../grades/views/grades_view.dart';
import '../../profile/views/profile_view.dart';

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
      bottomNavigationBar: Obx(() => DuoNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            items: const [
              DuoNavItem(
                icon: Iconsax.home_2,
                activeIcon: Iconsax.home_15,
                label: 'Trang chủ',
              ),
              DuoNavItem(
                icon: Iconsax.calendar_1,
                activeIcon: Iconsax.calendar,
                label: 'Lịch học',
              ),
              DuoNavItem(
                icon: Iconsax.chart_2,
                activeIcon: Iconsax.chart_1,
                label: 'Điểm',
              ),
              DuoNavItem(
                icon: Iconsax.user,
                activeIcon: Iconsax.user,
                label: 'Cá nhân',
              ),
            ],
          )),
    );
  }
}
