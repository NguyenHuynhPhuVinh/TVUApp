import 'package:get/get.dart';
import '../controllers/grades_controller.dart';

class GradesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GradesController>(() => GradesController());
  }
}
