/// Model lưu trữ thông tin game của người chơi
class PlayerStats {
  final int coins;
  final int diamonds;
  final int level;
  final int currentXp;
  final int totalLessonsAttended; // Tổng số tiết đã học
  final int totalLessonsMissed; // Tổng số tiết nghỉ
  final bool isInitialized; // Đã setup lần đầu chưa

  const PlayerStats({
    this.coins = 0,
    this.diamonds = 0,
    this.level = 1,
    this.currentXp = 0,
    this.totalLessonsAttended = 0,
    this.totalLessonsMissed = 0,
    this.isInitialized = false,
  });

  /// XP cần để lên level tiếp theo
  int get xpToNextLevel => level * 100;

  /// Progress XP hiện tại (0.0 - 1.0)
  double get xpProgress => currentXp / xpToNextLevel;

  /// Tỷ lệ chuyên cần (%)
  double get attendanceRate {
    final total = totalLessonsAttended + totalLessonsMissed;
    if (total == 0) return 100.0;
    return (totalLessonsAttended / total) * 100;
  }

  PlayerStats copyWith({
    int? coins,
    int? diamonds,
    int? level,
    int? currentXp,
    int? totalLessonsAttended,
    int? totalLessonsMissed,
    bool? isInitialized,
  }) {
    return PlayerStats(
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalLessonsAttended: totalLessonsAttended ?? this.totalLessonsAttended,
      totalLessonsMissed: totalLessonsMissed ?? this.totalLessonsMissed,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'diamonds': diamonds,
    'level': level,
    'currentXp': currentXp,
    'totalLessonsAttended': totalLessonsAttended,
    'totalLessonsMissed': totalLessonsMissed,
    'isInitialized': isInitialized,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    coins: json['coins'] ?? 0,
    diamonds: json['diamonds'] ?? 0,
    level: json['level'] ?? 1,
    currentXp: json['currentXp'] ?? 0,
    totalLessonsAttended: json['totalLessonsAttended'] ?? 0,
    totalLessonsMissed: json['totalLessonsMissed'] ?? 0,
    isInitialized: json['isInitialized'] ?? false,
  );
}
