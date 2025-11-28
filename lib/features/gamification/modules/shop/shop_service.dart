import 'package:get/get.dart';
import '../../core/shop_config.dart';
import '../../shared/models/wallet_transaction.dart';
import '../../core/game_service.dart';
import '../../core/game_security_guard.dart';

/// Service quản lý Shop - tách logic mua bán ra khỏi GameService
/// Tuân thủ Single Responsibility Principle
class ShopService extends GetxService {
  late final GameService _gameService;
  late final GameSecurityGuard _guard;

  final isLoading = false.obs;

  // Lock flags để ngăn race condition
  bool _isBuyingDiamonds = false;
  bool _isBuyingCoins = false;

  Future<ShopService> init() async {
    _gameService = Get.find<GameService>();
    _guard = Get.find<GameSecurityGuard>();
    return this;
  }

  // ============ GETTERS ============

  int get virtualBalance => _gameService.stats.value.virtualBalance;
  int get diamonds => _gameService.stats.value.diamonds;
  int get coins => _gameService.stats.value.coins;

  List<DiamondPackage> get diamondPackages => ShopConfig.diamondPackages;
  List<CoinPackage> get coinPackages => ShopConfig.coinPackages;

  // ============ VALIDATION ============

  bool canBuyDiamond(DiamondPackage package) => virtualBalance >= package.cost;
  bool canBuyCoin(CoinPackage package) => diamonds >= package.diamonds;

  // ============ BUY DIAMONDS ============

  /// Mua Diamond bằng DuoCash (virtualBalance)
  Future<Map<String, dynamic>?> buyDiamonds({
    required String mssv,
    required DiamondPackage package,
  }) async {
    if (!canBuyDiamond(package)) {
      return null;
    }

    return _guard.secureExecuteWithLock(
      actionName: 'buyDiamonds',
      isLocked: () => _isBuyingDiamonds,
      setLock: (v) => _isBuyingDiamonds = v,
      action: () async {
        isLoading.value = true;
        try {
          final result = await _gameService.buyDiamonds(
            mssv: mssv,
            cost: package.cost,
            diamondAmount: package.total,
          );
          return result;
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  // ============ BUY COINS ============

  /// Mua Coin bằng Diamond
  Future<Map<String, dynamic>?> buyCoins({
    required String mssv,
    required CoinPackage package,
  }) async {
    if (!canBuyCoin(package)) {
      return null;
    }

    return _guard.secureExecuteWithLock(
      actionName: 'buyCoins',
      isLocked: () => _isBuyingCoins,
      setLock: (v) => _isBuyingCoins = v,
      action: () async {
        isLoading.value = true;
        try {
          final result = await _gameService.buyCoins(
            mssv: mssv,
            diamondAmount: package.diamonds,
          );
          return result;
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  // ============ TRANSACTION HISTORY ============

  List<WalletTransaction> get shopTransactions {
    return _gameService.transactions
        .where((t) =>
            t.type == TransactionType.buyDiamond ||
            t.type == TransactionType.buyCoin)
        .toList();
  }
}

