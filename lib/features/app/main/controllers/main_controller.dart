import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;
  
  HomeController? _homeController;
  
  HomeController? get homeController {
    _homeController ??= Get.isRegistered<HomeController>() 
        ? Get.find<HomeController>() 
        : null;
    return _homeController;
  }

  // Lấy badge từ HomeController - access .value để trigger Obx
  bool get hasScheduleBadge {
    return homeController?.hasPendingCheckIn.value ?? false;
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}

