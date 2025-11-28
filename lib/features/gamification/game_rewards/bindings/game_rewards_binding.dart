import 'package:get/get.dart';
import '../controllers/game_rewards_controller.dart';

class GameRewardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameRewardsController>(() => GameRewardsController());
  }
}

