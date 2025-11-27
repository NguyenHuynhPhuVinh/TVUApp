import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';

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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Obx(() => GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Theme.of(context).primaryColor,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              color: Colors.grey[600],
              tabs: const [
                GButton(icon: Iconsax.home, text: 'Trang chủ'),
                GButton(icon: Iconsax.calendar, text: 'Lịch học'),
                GButton(icon: Iconsax.chart, text: 'Điểm'),
                GButton(icon: Iconsax.user, text: 'Cá nhân'),
              ],
              selectedIndex: controller.currentIndex.value,
              onTabChange: controller.changePage,
            )),
          ),
        ),
      ),
    );
  }
}
