import 'achievement_model.dart';

/// Phần thưởng cho thành tựu - bám sát tôn chỉ phần thưởng tier
class AchievementReward {
  final int coins;
  final int diamonds;
  final int xp;

  const AchievementReward({
    required this.coins,
    required this.diamonds,
    required this.xp,
  });

  /// Tính phần thưởng dựa trên tier
  /// Công thức: Base × TierMultiplier
  /// TierMultiplier: 3^tierIndex (giống rank system)
  factory AchievementReward.fromTier(AchievementTier tier, {int seriesIndex = 0}) {
    // Base rewards (Wood tier)
    const baseCoins = 500000;      // 500K coins
    const baseDiamonds = 2000;     // 2K diamonds
    const baseXp = 5000;           // 5K XP

    // Tier multiplier: 3^tierIndex
    int tierMultiplier = 1;
    for (int i = 0; i < tier.index; i++) {
      tierMultiplier *= 3;
    }

    // Series bonus: +50% mỗi cấp trong chuỗi
    final seriesMultiplier = 1.0 + (seriesIndex * 0.5);

    return AchievementReward(
      coins: (baseCoins * tierMultiplier * seriesMultiplier).round(),
      diamonds: (baseDiamonds * tierMultiplier * seriesMultiplier).round(),
      xp: (baseXp * tierMultiplier * seriesMultiplier).round(),
    );
  }

  /// Tính phần thưởng cho thành tựu cụ thể
  factory AchievementReward.forAchievement(Achievement achievement) {
    return AchievementReward.fromTier(
      achievement.tier,
      seriesIndex: achievement.seriesIndex ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'diamonds': diamonds,
    'xp': xp,
  };

  factory AchievementReward.fromJson(Map<String, dynamic> json) => AchievementReward(
    coins: json['coins'] ?? 0,
    diamonds: json['diamonds'] ?? 0,
    xp: json['xp'] ?? 0,
  );

  @override
  String toString() => 'AchievementReward(coins: $coins, diamonds: $diamonds, xp: $xp)';
}

/// Helper để lấy thông tin tier
class AchievementTierHelper {
  AchievementTierHelper._();

  /// Tên hiển thị của tier
  static String getTierName(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.wood:
        return 'Gỗ';
      case AchievementTier.stone:
        return 'Đá';
      case AchievementTier.bronze:
        return 'Đồng';
      case AchievementTier.silver:
        return 'Bạc';
      case AchievementTier.gold:
        return 'Vàng';
      case AchievementTier.platinum:
        return 'Bạch Kim';
      case AchievementTier.amethyst:
        return 'Thạch Anh';
      case AchievementTier.onyx:
        return 'Hắc Ngọc';
    }
  }

  /// Màu của tier
  static int getTierColorValue(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.wood:
        return 0xFF8B5A2B;
      case AchievementTier.stone:
        return 0xFF808080;
      case AchievementTier.bronze:
        return 0xFFCD7F32;
      case AchievementTier.silver:
        return 0xFFC0C0C0;
      case AchievementTier.gold:
        return 0xFFFFD700;
      case AchievementTier.platinum:
        return 0xFFE5E4E2;
      case AchievementTier.amethyst:
        return 0xFF9966CC;
      case AchievementTier.onyx:
        return 0xFF353839;
    }
  }

}
