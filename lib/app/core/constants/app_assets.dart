/// Centralized asset paths for game icons and images.
/// Use these constants instead of hardcoded strings.
///
/// Example:
/// ```dart
/// Image.asset(AppAssets.coin, width: 24, height: 24)
/// ```
class AppAssets {
  AppAssets._();

  // ============================================
  // CURRENCY - Main game currencies
  // ============================================

  /// Golden coin - primary currency
  static const String coin = 'assets/game/currency/coin_golden_coin_1st_256px.png';
  static const String coinOutline = 'assets/game/currency/coin_golden_coin_1st_outline_256px.png';

  /// Blue diamond - premium currency
  static const String diamond = 'assets/game/currency/diamond_blue_diamond_1st_256px.png';
  static const String diamondOutline = 'assets/game/currency/diamond_blue_diamond_1st_outline_256px.png';

  /// Green cash - TVUCash (virtual balance)
  static const String tvuCash = 'assets/game/currency/cash_green_cash_1st_256px.png';
  static const String tvuCashOutline = 'assets/game/currency/cash_green_cash_1st_outline_256px.png';

  // ============================================
  // MAIN - Stars, XP, etc.
  // ============================================

  /// Golden star - XP indicator
  static const String xpStar = 'assets/game/main/golden_star_1st_256px.png';
  static const String xpStarOutline = 'assets/game/main/golden_star_1st_outline_256px.png';

  /// Fire - streak indicator
  static const String fire = 'assets/game/main/fire_1st_outline_256px.png';

  // ============================================
  // UI - Checkmarks, buttons, etc.
  // ============================================

  /// Checkmark - success/completed indicator
  static const String checkmark = 'assets/game/ui/checkmark_1st_256px.png';
  static const String checkmarkOutline = 'assets/game/ui/checkmark_1st_outline_256px.png';

  /// Lock icons
  static const String lock = 'assets/game/item/lock_1st_256px.png';
  static const String lockOutline = 'assets/game/item/lock_1st_outline_256px.png';
  static const String unlock = 'assets/game/item/unlock_1st_256px.png';
  static const String unlockOutline = 'assets/game/item/unlock_1st_outline_256px.png';

  // ============================================
  // ITEMS - Gifts, rewards, etc.
  // ============================================

  /// Purple gift - reward preview
  static const String giftPurple = 'assets/game/item/purple_gift_1st_256px.png';
  static const String giftPurpleOutline = 'assets/game/item/purple_gift_1st_outline_256px.png';

  /// Red gift
  static const String giftRed = 'assets/game/item/red_gift_1st_256px.png';
  static const String giftRedOutline = 'assets/game/item/red_gift_1st_outline_256px.png';

  /// Green gift
  static const String giftGreen = 'assets/game/item/green_gift_1st_256px.png';
  static const String giftGreenOutline = 'assets/game/item/green_gift_1st_outline_256px.png';

  /// Chest - treasure/rewards
  static const String chest = 'assets/game/item/chest_1st_256px.png';
  static const String chestOutline = 'assets/game/item/chest_1st_outline_256px.png';

  /// Crown - achievement/rank
  static const String crown = 'assets/game/item/crown_1st_256px.png';
  static const String crownOutline = 'assets/game/item/crown_1st_outline_256px.png';

  /// Medal icons
  static const String medalGold = 'assets/game/item/golden_medal_1st_256px.png';
  static const String medalSilver = 'assets/game/item/silver_medal_1st_256px.png';
  static const String medalBronze = 'assets/game/item/bronze_medal_1st_256px.png';

  // ============================================
  // RANK - Rank badges base path
  // ============================================

  static const String _rankBasePath = 'assets/game/rank';

  /// Get rank badge path by rank name
  /// Example: getRankBadge('gold') => 'assets/game/rank/gold/...'
  static String getRankBadge(String rankName) {
    return '$_rankBasePath/${rankName.toLowerCase()}/badge.png';
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get currency icon by type
  static String getCurrencyIcon(CurrencyType type) {
    switch (type) {
      case CurrencyType.coin:
        return coin;
      case CurrencyType.diamond:
        return diamond;
      case CurrencyType.tvuCash:
        return tvuCash;
    }
  }
}

/// Currency types for helper method
enum CurrencyType {
  coin,
  diamond,
  tvuCash,
}
