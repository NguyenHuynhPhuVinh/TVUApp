/// Loại thành tựu - phân theo nguồn dữ liệu sinh viên
enum AchievementCategory {
  /// Thành tựu học tập (điểm số, môn học, GPA)
  academic,
  /// Thành tựu chuyên cần (điểm danh, check-in)
  attendance,
  /// Thành tựu tài chính (học phí)
  financial,
  /// Thành tựu tiến trình game (level, coins, diamonds)
  progress,
  /// Thành tựu đặc biệt (sự kiện, milestone)
  special,
}

/// Tier phần thưởng thành tựu - bám sát hệ thống rank
enum AchievementTier {
  wood,      // Cơ bản
  stone,     // Thường
  bronze,    // Đồng
  silver,    // Bạc
  gold,      // Vàng
  platinum,  // Bạch kim
  amethyst,  // Thạch anh
  onyx,      // Hắc ngọc (cao nhất)
}

/// Model cho một thành tựu
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementTier tier;
  final int targetValue;      // Giá trị cần đạt
  final int currentValue;     // Giá trị hiện tại
  final bool isUnlocked;      // Đã mở khóa chưa
  final bool isRewardClaimed; // Đã nhận thưởng chưa
  final DateTime? unlockedAt; // Thời điểm mở khóa
  final int? seriesIndex;     // Index trong chuỗi (cho thành tựu mở rộng)

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.tier,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.isRewardClaimed = false,
    this.unlockedAt,
    this.seriesIndex,
  });

  /// Tiến độ hoàn thành (0.0 - 1.0)
  double get progress => targetValue > 0 
      ? (currentValue / targetValue).clamp(0.0, 1.0) 
      : 0.0;

  /// Phần trăm hoàn thành
  int get progressPercent => (progress * 100).round();

  /// Kiểm tra đã hoàn thành chưa
  bool get isCompleted => currentValue >= targetValue;

  /// Có thể nhận thưởng không
  bool get canClaimReward => isUnlocked && !isRewardClaimed;

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    AchievementCategory? category,
    AchievementTier? tier,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    bool? isRewardClaimed,
    DateTime? unlockedAt,
    int? seriesIndex,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      seriesIndex: seriesIndex ?? this.seriesIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'category': category.name,
    'tier': tier.name,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'isUnlocked': isUnlocked,
    'isRewardClaimed': isRewardClaimed,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'seriesIndex': seriesIndex,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? '',
    category: AchievementCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => AchievementCategory.special,
    ),
    tier: AchievementTier.values.firstWhere(
      (e) => e.name == json['tier'],
      orElse: () => AchievementTier.wood,
    ),
    targetValue: json['targetValue'] ?? 0,
    currentValue: json['currentValue'] ?? 0,
    isUnlocked: json['isUnlocked'] ?? false,
    isRewardClaimed: json['isRewardClaimed'] ?? false,
    unlockedAt: json['unlockedAt'] != null 
        ? DateTime.tryParse(json['unlockedAt']) 
        : null,
    seriesIndex: json['seriesIndex'],
  );
}
