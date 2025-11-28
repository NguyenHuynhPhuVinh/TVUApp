import 'package:get/get.dart';
import '../controllers/coin_shop_controller.dart';

class CoinShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinShopController>(() => CoinShopController());
  }
}
