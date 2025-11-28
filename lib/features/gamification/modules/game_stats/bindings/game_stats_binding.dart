import 'package:get/get.dart';
import '../controllers/game_stats_controller.dart';

class GameStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameStatsController>(() => GameStatsController());
  }
}

