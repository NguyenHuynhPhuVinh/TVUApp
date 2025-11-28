import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../core/utils/number_formatter.dart';

class CoinShopController extends GetxController {
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;

  String get mssv => _authService.username.value;
  int get diamonds => _gameService.stats.value.diamonds;
  int get coins => _gameService.stats.value.coins;

  /// Các gói coin có sẵn
  /// Tỷ giá: 1 diamond = 10,000 coins
  final packages = [
    CoinPackage(diamonds: 10, coins: 100000, bonus: 0),
    CoinPackage(diamonds: 50, coins: 500000, bonus: 50000),
    CoinPackage(diamonds: 100, coins: 1000000, bonus: 150000),
    CoinPackage(diamonds: 500, coins: 5000000, bonus: 1000000),
    CoinPackage(diamonds: 1000, coins: 10000000, bonus: 3000000),
  ];

  /// Kiểm tra có đủ diamond mua gói không
  bool canBuy(CoinPackage package) {
    return diamonds >= package.diamonds;
  }

  /// Mua coin
  Future<Map<String, dynamic>?> buyCoins(CoinPackage package) async {
    if (!canBuy(package)) return null;
    
    isLoading.value = true;
    try {
      // Tính tổng coin (bao gồm bonus)
      final totalCoins = package.coins + package.bonus;
      // Tính số diamond cần (dựa trên tổng coin)
      final diamondsNeeded = package.diamonds;
      
      final result = await _gameService.buyCoins(
        mssv: mssv,
        diamondAmount: diamondsNeeded,
      );
      
      // Nếu có bonus, cần add thêm coins
      if (result != null && package.bonus > 0) {
        await _gameService.addCoins(package.bonus, mssv);
      }
      
      return result != null ? {
        ...result,
        'totalCoins': totalCoins,
        'bonus': package.bonus,
      } : null;
    } finally {
      isLoading.value = false;
    }
  }

  String formatCompact(int amount) => NumberFormatter.compact(amount);
}

class CoinPackage {
  final int diamonds;
  final int coins;
  final int bonus;

  const CoinPackage({
    required this.diamonds,
    required this.coins,
    required this.bonus,
  });

  int get total => coins + bonus;
  double get bonusPercent => bonus > 0 ? (bonus / coins) * 100 : 0;
}
