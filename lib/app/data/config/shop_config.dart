// Cấu hình Shop - tách data ra khỏi Controller
// Có thể chuyển sang Remote Config (Firebase) sau này

/// Package Diamond - mua bằng DuoCash
class DiamondPackage {
  final String id;
  final int diamonds;
  final int bonus;
  final int cost; // DuoCash
  final bool isBestValue;
  final bool isFirstBuy;

  const DiamondPackage({
    required this.id,
    required this.diamonds,
    this.bonus = 0,
    required this.cost,
    this.isBestValue = false,
    this.isFirstBuy = false,
  });

  int get total => diamonds + bonus;
  double get bonusPercent => bonus > 0 ? (bonus / diamonds) * 100 : 0;
}

/// Package Coin - mua bằng Diamond
class CoinPackage {
  final String id;
  final int coins;
  final int bonus;
  final int diamonds; // cost in diamonds

  const CoinPackage({
    required this.id,
    required this.coins,
    this.bonus = 0,
    required this.diamonds,
  });

  int get total => coins + bonus;
  double get bonusPercent => bonus > 0 ? (bonus / coins) * 100 : 0;
}

/// Config tĩnh cho Shop
/// TODO: Chuyển sang Firebase Remote Config để thay đổi giá/khuyến mãi không cần update app
class ShopConfig {
  ShopConfig._();

  /// Tỷ lệ quy đổi: 1 Diamond = 10,000 Coins
  static const int coinsPerDiamond = 10000;

  /// Danh sách gói Diamond
  static const List<DiamondPackage> diamondPackages = [
    DiamondPackage(
      id: 'diamond_100',
      diamonds: 100,
      cost: 10000,
      isFirstBuy: true,
    ),
    DiamondPackage(
      id: 'diamond_500',
      diamonds: 500,
      bonus: 50,
      cost: 45000,
    ),
    DiamondPackage(
      id: 'diamond_1000',
      diamonds: 1000,
      bonus: 150,
      cost: 85000,
    ),
    DiamondPackage(
      id: 'diamond_2500',
      diamonds: 2500,
      bonus: 500,
      cost: 200000,
      isBestValue: true,
    ),
    DiamondPackage(
      id: 'diamond_5000',
      diamonds: 5000,
      bonus: 1200,
      cost: 380000,
    ),
    DiamondPackage(
      id: 'diamond_10000',
      diamonds: 10000,
      bonus: 3000,
      cost: 700000,
    ),
  ];

  /// Danh sách gói Coin
  static const List<CoinPackage> coinPackages = [
    CoinPackage(
      id: 'coin_500k',
      coins: 500000,
      diamonds: 50,
    ),
    CoinPackage(
      id: 'coin_1500k',
      coins: 1500000,
      bonus: 100000,
      diamonds: 150,
    ),
    CoinPackage(
      id: 'coin_3000k',
      coins: 3000000,
      bonus: 300000,
      diamonds: 300,
    ),
    CoinPackage(
      id: 'coin_5000k',
      coins: 5000000,
      bonus: 750000,
      diamonds: 500,
    ),
    CoinPackage(
      id: 'coin_10000k',
      coins: 10000000,
      bonus: 2000000,
      diamonds: 1000,
    ),
  ];
}
