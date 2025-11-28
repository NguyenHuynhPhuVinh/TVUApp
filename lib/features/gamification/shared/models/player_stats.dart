/// Model lưu trữ thông tin game của người chơi
class PlayerStats {
  final int coins;
  final int diamonds;
  final int level;
  final int currentXp;
  final int totalLessonsAttended; // Tổng số tiết đã học
  final int totalLessonsMissed; // Tổng số tiết nghỉ
  final bool isInitialized; // Đã setup lần đầu chưa
  final DateTime? initializedAt; // Thời điểm khởi tạo game
  final int virtualBalance; // Tiền ảo (từ học phí đã đóng)
  final int totalTuitionPaid; // Tổng học phí đã đóng (VND)
  final bool tuitionBonusClaimed; // Đã nhận bonus từ học phí chưa (full claim từ setup)
  final List<String> claimedTuitionSemesters; // Danh sách học kỳ đã claim
  final List<String> claimedSubjects; // Danh sách môn học đã claim reward (mã môn)
  final List<int> claimedRankRewards; // Danh sách rank đã claim reward (rankIndex)

  const PlayerStats({
    this.coins = 0,
    this.diamonds = 0,
    this.level = 1,
    this.currentXp = 0,
    this.totalLessonsAttended = 0,
    this.totalLessonsMissed = 0,
    this.isInitialized = false,
    this.initializedAt,
    this.virtualBalance = 0,
    this.totalTuitionPaid = 0,
    this.tuitionBonusClaimed = false,
    this.claimedTuitionSemesters = const [],
    this.claimedSubjects = const [],
    this.claimedRankRewards = const [],
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

  /// Kiểm tra học kỳ đã claim chưa
  bool isSemesterClaimed(String semesterId) {
    return tuitionBonusClaimed || claimedTuitionSemesters.contains(semesterId);
  }

  /// Kiểm tra môn học đã claim reward chưa
  bool isSubjectClaimed(String maMon) {
    return claimedSubjects.contains(maMon);
  }

  /// Kiểm tra rank đã claim reward chưa
  bool isRankClaimed(int rankIndex) {
    return claimedRankRewards.contains(rankIndex);
  }

  PlayerStats copyWith({
    int? coins,
    int? diamonds,
    int? level,
    int? currentXp,
    int? totalLessonsAttended,
    int? totalLessonsMissed,
    bool? isInitialized,
    DateTime? initializedAt,
    int? virtualBalance,
    int? totalTuitionPaid,
    bool? tuitionBonusClaimed,
    List<String>? claimedTuitionSemesters,
    List<String>? claimedSubjects,
    List<int>? claimedRankRewards,
  }) {
    return PlayerStats(
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalLessonsAttended: totalLessonsAttended ?? this.totalLessonsAttended,
      totalLessonsMissed: totalLessonsMissed ?? this.totalLessonsMissed,
      isInitialized: isInitialized ?? this.isInitialized,
      initializedAt: initializedAt ?? this.initializedAt,
      virtualBalance: virtualBalance ?? this.virtualBalance,
      totalTuitionPaid: totalTuitionPaid ?? this.totalTuitionPaid,
      tuitionBonusClaimed: tuitionBonusClaimed ?? this.tuitionBonusClaimed,
      claimedTuitionSemesters: claimedTuitionSemesters ?? this.claimedTuitionSemesters,
      claimedSubjects: claimedSubjects ?? this.claimedSubjects,
      claimedRankRewards: claimedRankRewards ?? this.claimedRankRewards,
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
    'initializedAt': initializedAt?.toIso8601String(),
    'virtualBalance': virtualBalance,
    'totalTuitionPaid': totalTuitionPaid,
    'tuitionBonusClaimed': tuitionBonusClaimed,
    'claimedTuitionSemesters': claimedTuitionSemesters,
    'claimedSubjects': claimedSubjects,
    'claimedRankRewards': claimedRankRewards,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    coins: json['coins'] ?? 0,
    diamonds: json['diamonds'] ?? 0,
    level: json['level'] ?? 1,
    currentXp: json['currentXp'] ?? 0,
    totalLessonsAttended: json['totalLessonsAttended'] ?? 0,
    totalLessonsMissed: json['totalLessonsMissed'] ?? 0,
    isInitialized: json['isInitialized'] ?? false,
    initializedAt: json['initializedAt'] != null 
        ? DateTime.tryParse(json['initializedAt']) 
        : null,
    virtualBalance: json['virtualBalance'] ?? 0,
    totalTuitionPaid: json['totalTuitionPaid'] ?? 0,
    tuitionBonusClaimed: json['tuitionBonusClaimed'] ?? false,
    claimedTuitionSemesters: (json['claimedTuitionSemesters'] as List?)
        ?.map((e) => e.toString()).toList() ?? [],
    claimedSubjects: (json['claimedSubjects'] as List?)
        ?.map((e) => e.toString()).toList() ?? [],
    claimedRankRewards: (json['claimedRankRewards'] as List?)
        ?.map((e) => e as int).toList() ?? [],
  );
}

