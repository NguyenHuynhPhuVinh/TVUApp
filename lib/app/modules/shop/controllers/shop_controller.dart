import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';

/// Package Diamond
class DiamondPackage {
  final int diamonds;
  final int bonus;
  final int cost;
  final bool isBestValue;
  final bool isFirstBuy;

  const DiamondPackage({
    required this.diamonds,
    this.bonus = 0,
    required this.cost,
    this.isBestValue = false,
    this.isFirstBuy = false,
  });

  int get total => diamonds + bonus;
  double get bonusPercent => bonus > 0 ? (bonus / diamonds) * 100 : 0;
}

/// Package Coin
class CoinPackage {
  final int coins;
  final int bonus;
  final int diamonds; // cost in diamonds

  const CoinPackage({
    required this.coins,
    this.bonus = 0,
    required this.diamonds,
  });

  int get total => coins + bonus;
}

class ShopController extends GetxController with GetSingleTickerProviderStateMixin {
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;

  // Getters
  int get virtualBalance => _gameService.stats.value.virtualBalance;
  int get diamonds => _gameService.stats.value.diamonds;
  int get coins => _gameService.stats.value.coins;
  String get mssv => _authService.username.value;

  // Diamond packages
  final diamondPackages = const [
    DiamondPackage(diamonds: 100, cost: 10000, isFirstBuy: true),
    DiamondPackage(diamonds: 500, bonus: 50, cost: 45000),
    DiamondPackage(diamonds: 1000, bonus: 150, cost: 85000),
    DiamondPackage(diamonds: 2500, bonus: 500, cost: 200000, isBestValue: true),
    DiamondPackage(diamonds: 5000, bonus: 1200, cost: 380000),
    DiamondPackage(diamonds: 10000, bonus: 3000, cost: 700000),
  ];

  // Coin packages (1 diamond = 10,000 coins theo GameService)
  // Hiển thị số coins nhận được (đã tính sẵn)
  final coinPackages = const [
    CoinPackage(coins: 500000, diamonds: 50),
    CoinPackage(coins: 1500000, bonus: 100000, diamonds: 150),
    CoinPackage(coins: 3000000, bonus: 300000, diamonds: 300),
    CoinPackage(coins: 5000000, bonus: 750000, diamonds: 500),
    CoinPackage(coins: 10000000, bonus: 2000000, diamonds: 1000),
  ];

  bool canBuyDiamond(DiamondPackage package) => virtualBalance >= package.cost;
  bool canBuyCoin(CoinPackage package) => diamonds >= package.diamonds;

  /// Mua Diamond bằng DuoCash
  Future<Map<String, dynamic>?> buyDiamonds(DiamondPackage package) async {
    if (!canBuyDiamond(package)) return null;

    isLoading.value = true;
    try {
      return await _gameService.buyDiamonds(
        mssv: mssv,
        cost: package.cost,
        diamondAmount: package.total,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Mua Coin bằng Diamond
  /// Note: GameService tự tính coinAmount = diamondAmount * 10000
  Future<Map<String, dynamic>?> buyCoins(CoinPackage package) async {
    if (!canBuyCoin(package)) return null;

    isLoading.value = true;
    try {
      return await _gameService.buyCoins(
        mssv: mssv,
        diamondAmount: package.diamonds,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
