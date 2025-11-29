import 'package:get/get.dart';
import '../controllers/reward_code_controller.dart';
import '../services/reward_code_service.dart';

class RewardCodeBinding extends Bindings {
  @override
  void dependencies() {
    // Service đã được đăng ký global trong main.dart
    if (!Get.isRegistered<RewardCodeService>()) {
      Get.put(RewardCodeService(), permanent: true);
    }
    Get.lazyPut<RewardCodeController>(() => RewardCodeController());
  }
}
