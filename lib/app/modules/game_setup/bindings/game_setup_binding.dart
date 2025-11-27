import 'package:get/get.dart';
import '../controllers/game_setup_controller.dart';

class GameSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameSetupController>(() => GameSetupController());
  }
}
