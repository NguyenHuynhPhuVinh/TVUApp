import 'package:get/get.dart';
import '../../../../features/gamification/config/shop_config.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/shop/shop_service.dart';

class ShopController extends GetxController {
  final ShopService _shopService = Get.find<ShopService>();
  final AuthService _authService = Get.find<AuthService>();

  // Getters - delegate to ShopService
  int get virtualBalance => _shopService.virtualBalance;
  int get diamonds => _shopService.diamonds;
  int get coins => _shopService.coins;
  RxBool get isLoading => _shopService.isLoading;
  String get mssv => _authService.username.value;

  // Packages từ config
  List<DiamondPackage> get diamondPackages => _shopService.diamondPackages;
  List<CoinPackage> get coinPackages => _shopService.coinPackages;

  // Validation
  bool canBuyDiamond(DiamondPackage package) =>
      _shopService.canBuyDiamond(package);
  bool canBuyCoin(CoinPackage package) => _shopService.canBuyCoin(package);

  /// Mua Diamond bằng DuoCash
  Future<Map<String, dynamic>?> buyDiamonds(DiamondPackage package) async {
    return _shopService.buyDiamonds(mssv: mssv, package: package);
  }

  /// Mua Coin bằng Diamond
  Future<Map<String, dynamic>?> buyCoins(CoinPackage package) async {
    return _shopService.buyCoins(mssv: mssv, package: package);
  }
}


