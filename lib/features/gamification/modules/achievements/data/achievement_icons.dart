import '../models/achievement_model.dart';
import '../../../../../core/constants/app_assets.dart';

/// Helper class để lấy icon asset cho thành tựu
/// Thay thế emoji bằng game assets
class AchievementIcons {
  AchievementIcons._();

  /// Lấy asset path cho category
  static String getCategoryAsset(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.academic:
        return AppAssets.medalGold;
      case AchievementCategory.attendance:
        return AppAssets.checkmark;
      case AchievementCategory.financial:
        return AppAssets.tvuCash;
      case AchievementCategory.progress:
        return AppAssets.xpStar;
      case AchievementCategory.special:
        return AppAssets.giftPurple;
    }
  }

  /// Lấy asset path cho achievement cụ thể dựa trên ID
  static String getAchievementAsset(Achievement achievement) {
    final id = achievement.id;

    // Academic achievements
    if (id.startsWith('subject_passed')) return AppAssets.medalGold;
    if (id.startsWith('credits_earned')) return AppAssets.crown;
    if (id.startsWith('gpa_milestone')) return AppAssets.xpStar;
    if (id.startsWith('grade_a')) return AppAssets.medalGold;
    if (id.startsWith('perfect_score')) return AppAssets.crown;

    // Attendance achievements
    if (id.startsWith('lessons_attended')) return AppAssets.checkmark;
    if (id.startsWith('attendance_rate')) return AppAssets.checkmark;
    if (id.startsWith('checkin_streak')) return AppAssets.fire;

    // Financial achievements
    if (id.startsWith('tuition_paid')) return AppAssets.tvuCash;
    if (id.startsWith('semesters_paid')) return AppAssets.tvuCash;

    // Progress achievements
    if (id.startsWith('level_reached')) return AppAssets.xpStar;
    if (id.startsWith('coins_earned')) return AppAssets.coin;
    if (id.startsWith('diamonds_earned')) return AppAssets.diamond;
    if (id.startsWith('rank_')) return AppAssets.crown;

    // Special achievements
    if (id == 'first_login') return AppAssets.giftGreen;
    if (id == 'game_initialized') return AppAssets.giftPurple;
    if (id == 'first_checkin') return AppAssets.checkmark;
    if (id == 'first_subject_reward') return AppAssets.giftRed;
    if (id == 'first_rank_reward') return AppAssets.crown;
    if (id == 'all_semester_paid') return AppAssets.tvuCash;
    if (id == 'perfect_attendance_semester') return AppAssets.checkmark;
    if (id == 'graduate') return AppAssets.crown;

    // Default: dựa vào category
    return getCategoryAsset(achievement.category);
  }

  /// Lấy asset path cho tier
  static String getTierAsset(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.wood:
      case AchievementTier.stone:
        return AppAssets.medalBronze;
      case AchievementTier.bronze:
        return AppAssets.medalBronze;
      case AchievementTier.silver:
        return AppAssets.medalSilver;
      case AchievementTier.gold:
      case AchievementTier.platinum:
      case AchievementTier.amethyst:
      case AchievementTier.onyx:
        return AppAssets.medalGold;
    }
  }
}
