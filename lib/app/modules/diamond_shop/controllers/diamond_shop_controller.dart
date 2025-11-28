import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../core/utils/number_formatter.dart';

class DiamondShopController extends GetxController {
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final selectedPackage = Rxn<DiamondPackage>();

  String get mssv => _authService.username.value;
  int get virtualBalance => _gameService.stats.value.virtualBalance;
  int get diamonds => _gameService.stats.value.diamonds;

  /// Các gói diamond chuẩn game online
  /// Giá theo VND (1:1 với tiền ảo)
  /// Gói lớn hơn có bonus nhiều hơn
  final packages = [
    // Gói nhỏ - cho người mới
    DiamondPackage(diamonds: 60, cost: 22000, bonus: 0, isFirstBuy: true),
    DiamondPackage(diamonds: 300, cost: 109000, bonus: 30),
    DiamondPackage(diamonds: 980, cost: 329000, bonus: 110),
    // Gói trung bình
    DiamondPackage(diamonds: 1980, cost: 659000, bonus: 260),
    DiamondPackage(diamonds: 3280, cost: 1099000, bonus: 600),
    // Gói lớn - best value
    DiamondPackage(diamonds: 6480, cost: 2199000, bonus: 1600, isBestValue: true),
  ];

  /// Kiểm tra có đủ tiền mua gói không
  bool canBuy(DiamondPackage package) {
    return virtualBalance >= package.cost;
  }

  /// Mua diamond
  Future<Map<String, dynamic>?> buyDiamonds(DiamondPackage package) async {
    if (!canBuy(package)) return null;
    
    isLoading.value = true;
    try {
      final totalDiamonds = package.diamonds + package.bonus;
      final result = await _gameService.buyDiamonds(
        mssv: mssv,
        diamondAmount: totalDiamonds,
        cost: package.cost,
      );
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  String formatBalance(int amount) => NumberFormatter.withCommas(amount);
  String formatCompact(int amount) => NumberFormatter.compact(amount);
}

class DiamondPackage {
  final int diamonds;
  final int cost;
  final int bonus;
  final bool isFirstBuy;
  final bool isBestValue;

  const DiamondPackage({
    required this.diamonds,
    required this.cost,
    required this.bonus,
    this.isFirstBuy = false,
    this.isBestValue = false,
  });

  int get total => diamonds + bonus;
  double get bonusPercent => bonus > 0 ? (bonus / diamonds) * 100 : 0;
  
  /// Giá mỗi diamond (VND)
  double get pricePerDiamond => cost / total;
}
