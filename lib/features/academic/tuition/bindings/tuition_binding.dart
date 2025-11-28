import 'package:get/get.dart';
import '../controllers/tuition_controller.dart';

class TuitionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TuitionController>(() => TuitionController());
  }
}

