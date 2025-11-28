/// Tính toán rewards cho game system
/// Tách logic tính toán ra khỏi GameService để dễ test và maintain
class RewardCalculator {
  RewardCalculator._();

  // ============ REWARD CONSTANTS ============
  
  /// Coins per tiết học
  static const int coinsPerLesson = 250000;
  
  /// XP per tiết học
  static const int xpPerLesson = 2500;
  
  /// Diamonds per tiết học
  static const int diamondsPerLesson = 413;
  
  /// Số tiết per tín chỉ (15 LT + 30 TH)
  static const int lessonsPerCredit = 45;

  // ============ LESSON REWARDS ============

  /// Tính reward cho số tiết học
  static Map<String, int> calculateLessonReward(int lessons) {
    return {
      'coins': lessons * coinsPerLesson,
      'xp': lessons * xpPerLesson,
      'diamonds': lessons * diamondsPerLesson,
    };
  }

  // ============ ATTENDANCE BONUS ============

  /// Tính hệ số bonus chuyên cần
  /// >= 90%: +50%, >= 80%: +25%, < 80%: 0%
  static double getAttendanceBonusMultiplier(double attendanceRate) {
    if (attendanceRate >= 90) return 1.5;
    if (attendanceRate >= 80) return 1.25;
    return 1.0;
  }

  /// Tính reward với bonus chuyên cần
  static Map<String, int> calculateAttendanceReward({
    required int attendedLessons,
    required int totalLessons,
  }) {
    final baseReward = calculateLessonReward(attendedLessons);
    final attendanceRate = totalLessons > 0 
        ? (attendedLessons / totalLessons) * 100 
        : 100.0;
    final multiplier = getAttendanceBonusMultiplier(attendanceRate);

    return {
      'coins': (baseReward['coins']! * multiplier).round(),
      'xp': (baseReward['xp']! * multiplier).round(),
      'diamonds': (baseReward['diamonds']! * multiplier).round(),
    };
  }

  // ============ SUBJECT REWARDS (CTDT) ============

  /// Tính reward cho môn học đạt dựa trên số tín chỉ
  /// 1 TC = 45 tiết × rewards
  static Map<String, int> calculateSubjectReward(int soTinChi) {
    final totalLessons = soTinChi * lessonsPerCredit;
    return calculateLessonReward(totalLessons);
  }

  // ============ RANK REWARDS ============

  /// Tính reward cho rank dựa trên tier và level (GPA-based)
  /// 
  /// 8 tiers: Wood → Stone → Bronze → Silver → Gold → Platinum → Amethyst → Onyx
  /// Mỗi tier có 7 levels (I → VII)
  /// 
  /// Base reward (Wood I): 10M coins + 50K XP + 41,300 diamonds
  /// Tier multiplier: 3^tierIndex (1, 3, 9, 27, 81, 243, 729, 2187)
  /// Level bonus: +100% mỗi level
  static Map<String, int> calculateRankReward(int rankIndex) {
    final tierIndex = rankIndex ~/ 7;
    final level = (rankIndex % 7) + 1;
    
    // Exponential tier multiplier: 3^tierIndex
    int tierMultiplier = 1;
    for (int i = 0; i < tierIndex; i++) {
      tierMultiplier *= 3;
    }
    
    final baseCoins = 10000000 * tierMultiplier; // 10M base
    final baseXp = 50000 * tierMultiplier; // 50K base XP
    final baseDiamonds = 41300 * tierMultiplier; // 41.3K base
    
    // Level bonus: +100% mỗi level (1x, 2x, 3x, 4x, 5x, 6x, 7x)
    final levelMultiplier = level.toDouble();
    
    return {
      'coins': (baseCoins * levelMultiplier).round(),
      'xp': (baseXp * levelMultiplier).round(),
      'diamonds': (baseDiamonds * levelMultiplier).round(),
    };
  }

  // ============ LEVEL CALCULATION ============

  /// Tính level từ tổng XP
  /// Mỗi level cần level * 100 XP
  static Map<String, int> calculateLevelFromXp(int totalXp) {
    int level = 1;
    int remainingXp = totalXp;
    
    while (remainingXp >= level * 100) {
      remainingXp -= level * 100;
      level++;
    }
    
    return {
      'level': level,
      'currentXp': remainingXp,
      'xpToNextLevel': level * 100,
    };
  }

  /// Tính XP cần để lên level tiếp theo
  static int xpToNextLevel(int currentLevel) {
    return currentLevel * 100;
  }

  /// Tính level mới sau khi thêm XP
  static Map<String, dynamic> addXpAndCalculateLevel({
    required int currentXp,
    required int currentLevel,
    required int addedXp,
  }) {
    int newXp = currentXp + addedXp;
    int newLevel = currentLevel;
    bool leveledUp = false;
    
    while (newXp >= newLevel * 100) {
      newXp -= newLevel * 100;
      newLevel++;
      leveledUp = true;
    }
    
    return {
      'newXp': newXp,
      'newLevel': newLevel,
      'leveledUp': leveledUp,
    };
  }

  // ============ TUITION BONUS ============

  /// Tính tiền ảo từ học phí đã đóng (1:1)
  static int calculateVirtualBalance(int tuitionPaid) {
    return tuitionPaid;
  }

  // ============ SHOP RATES ============

  /// Tỷ giá đổi diamond sang coin
  static const int coinsPerDiamond = 10000;

  /// Tính số coin nhận được khi đổi diamond
  static int calculateCoinsFromDiamonds(int diamonds) {
    return diamonds * coinsPerDiamond;
  }
}

