import 'package:get/get.dart';
import '../controllers/diamond_shop_controller.dart';

class DiamondShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiamondShopController>(() => DiamondShopController());
  }
}
