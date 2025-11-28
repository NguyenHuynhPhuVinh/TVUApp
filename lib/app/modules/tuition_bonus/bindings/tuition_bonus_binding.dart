import 'package:get/get.dart';
import '../controllers/tuition_bonus_controller.dart';

class TuitionBonusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TuitionBonusController>(() => TuitionBonusController());
  }
}
