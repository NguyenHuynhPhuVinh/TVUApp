import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../../features/academic/schedule/controllers/schedule_controller.dart';
import '../../../../features/academic/grades/controllers/grades_controller.dart';
import '../../../../features/user/controllers/profile_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ScheduleController>(() => ScheduleController());
    Get.lazyPut<GradesController>(() => GradesController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

