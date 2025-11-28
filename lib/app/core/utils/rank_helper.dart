import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Enum cho các tier rank
enum RankTier {
  wood,
  stone,
  bronze,
  silver,
  gold,
  platinum,
  amethyst,
  onyx,
}

/// Helper class để quản lý rank system
/// 8 tier × 7 cấp = 56 rank tổng cộng
class RankHelper {
  RankHelper._();

  /// Số cấp trong mỗi tier
  static const int levelsPerTier = 7;

  /// Tổng số rank
  static const int totalRanks = 56;

  /// Lấy asset path cho rank
  static String getAssetPath(RankTier tier, int level) {
    assert(level >= 1 && level <= 7, 'Level must be between 1 and 7');
    return 'assets/game/rank/${tier.name}/rank-$level.png';
  }

  /// Lấy asset path từ rank index (0-55)
  static String getAssetPathFromIndex(int rankIndex) {
    final tier = getTierFromIndex(rankIndex);
    final level = getLevelFromIndex(rankIndex);
    return getAssetPath(tier, level);
  }

  /// Lấy tier từ rank index
  static RankTier getTierFromIndex(int rankIndex) {
    final tierIndex = (rankIndex ~/ levelsPerTier).clamp(0, RankTier.values.length - 1);
    return RankTier.values[tierIndex];
  }

  /// Lấy level từ rank index (1-7)
  static int getLevelFromIndex(int rankIndex) {
    return (rankIndex % levelsPerTier) + 1;
  }

  /// Chuyển tier + level thành rank index
  static int toRankIndex(RankTier tier, int level) {
    return tier.index * levelsPerTier + (level - 1);
  }

  /// Tên hiển thị của tier
  static String getTierName(RankTier tier) {
    switch (tier) {
      case RankTier.wood:
        return 'Gỗ';
      case RankTier.stone:
        return 'Đá';
      case RankTier.bronze:
        return 'Đồng';
      case RankTier.silver:
        return 'Bạc';
      case RankTier.gold:
        return 'Vàng';
      case RankTier.platinum:
        return 'Bạch Kim';
      case RankTier.amethyst:
        return 'Thạch Anh';
      case RankTier.onyx:
        return 'Hắc Ngọc';
    }
  }

  /// Tên đầy đủ của rank (VD: "Đồng III")
  static String getRankName(RankTier tier, int level) {
    return '${getTierName(tier)} ${_toRoman(level)}';
  }

  /// Tên đầy đủ từ rank index
  static String getRankNameFromIndex(int rankIndex) {
    final tier = getTierFromIndex(rankIndex);
    final level = getLevelFromIndex(rankIndex);
    return getRankName(tier, level);
  }

  /// Màu chính của tier
  static Color getTierColor(RankTier tier) {
    switch (tier) {
      case RankTier.wood:
        return const Color(0xFF8B5A2B);
      case RankTier.stone:
        return const Color(0xFF808080);
      case RankTier.bronze:
        return const Color(0xFFCD7F32);
      case RankTier.silver:
        return const Color(0xFFC0C0C0);
      case RankTier.gold:
        return AppColors.yellow;
      case RankTier.platinum:
        return const Color(0xFFE5E4E2);
      case RankTier.amethyst:
        return AppColors.purple;
      case RankTier.onyx:
        return const Color(0xFF353839);
    }
  }

  /// Màu đậm của tier (cho shadow, border)
  static Color getTierDarkColor(RankTier tier) {
    switch (tier) {
      case RankTier.wood:
        return const Color(0xFF5D3A1A);
      case RankTier.stone:
        return const Color(0xFF505050);
      case RankTier.bronze:
        return const Color(0xFF8B4513);
      case RankTier.silver:
        return const Color(0xFF909090);
      case RankTier.gold:
        return AppColors.yellowDark;
      case RankTier.platinum:
        return const Color(0xFFB8B8B8);
      case RankTier.amethyst:
        return AppColors.purpleDark;
      case RankTier.onyx:
        return const Color(0xFF1A1A1A);
    }
  }

  /// Chuyển số thành số La Mã (1-7)
  static String _toRoman(int number) {
    const romans = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];
    if (number >= 1 && number <= 7) {
      return romans[number - 1];
    }
    return number.toString();
  }

  /// Tính XP cần để lên rank tiếp theo
  static int getXpForNextRank(int currentRankIndex) {
    // Base XP tăng dần theo tier
    final tier = getTierFromIndex(currentRankIndex);
    final level = getLevelFromIndex(currentRankIndex);
    
    final baseXp = (tier.index + 1) * 100;
    final levelMultiplier = level * 1.2;
    
    return (baseXp * levelMultiplier).round();
  }

  /// Kiểm tra có phải rank cao nhất không
  static bool isMaxRank(int rankIndex) {
    return rankIndex >= totalRanks - 1;
  }
}
