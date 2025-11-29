import 'package:get/get.dart';
import '../controllers/achievements_controller.dart';
import '../services/achievement_service.dart';

class AchievementsBinding extends Bindings {
  @override
  void dependencies() {
    // Đảm bảo AchievementService đã được khởi tạo
    if (!Get.isRegistered<AchievementService>()) {
      Get.lazyPut<AchievementService>(() => AchievementService());
    }
    
    Get.lazyPut<AchievementsController>(() => AchievementsController());
  }
}
