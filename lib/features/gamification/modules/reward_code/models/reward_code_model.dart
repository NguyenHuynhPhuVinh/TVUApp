/// Model cho mã thưởng
/// Mã có thể có ngày hết hạn hoặc không
class RewardCode {
  final String code;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final RewardCodeReward reward;
  final int maxClaims; // 0 = unlimited
  final int currentClaims;
  final bool isActive;

  const RewardCode({
    required this.code,
    required this.title,
    required this.description,
    required this.createdAt,
    this.expiresAt,
    required this.reward,
    this.maxClaims = 0,
    this.currentClaims = 0,
    this.isActive = true,
  });

  /// Kiểm tra mã đã hết hạn chưa
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Kiểm tra mã còn hiệu lực không
  bool get isValid {
    if (!isActive) return false;
    if (isExpired) return false;
    if (maxClaims > 0 && currentClaims >= maxClaims) return false;
    return true;
  }

  factory RewardCode.fromJson(Map<String, dynamic> json) {
    return RewardCode(
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      expiresAt: json['expires_at'] != null 
          ? DateTime.tryParse(json['expires_at'].toString()) 
          : null,
      reward: json['reward'] != null 
          ? RewardCodeReward.fromJson(json['reward']) 
          : const RewardCodeReward(),
      maxClaims: _parseInt(json['max_claims']),
      currentClaims: _parseInt(json['current_claims']),
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'title': title,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'reward': reward.toJson(),
    'max_claims': maxClaims,
    'current_claims': currentClaims,
    'is_active': isActive,
  };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// Phần thưởng của mã
class RewardCodeReward {
  final int coins;
  final int diamonds;
  final int xp;

  const RewardCodeReward({
    this.coins = 0,
    this.diamonds = 0,
    this.xp = 0,
  });

  bool get isEmpty => coins == 0 && diamonds == 0 && xp == 0;

  factory RewardCodeReward.fromJson(Map<String, dynamic> json) {
    return RewardCodeReward(
      coins: _parseInt(json['coins']),
      diamonds: _parseInt(json['diamonds']),
      xp: _parseInt(json['xp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'diamonds': diamonds,
    'xp': xp,
  };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// Lịch sử nhận mã của user
class ClaimedRewardCode {
  final String code;
  final DateTime claimedAt;
  final RewardCodeReward reward;

  const ClaimedRewardCode({
    required this.code,
    required this.claimedAt,
    required this.reward,
  });

  factory ClaimedRewardCode.fromJson(Map<String, dynamic> json) {
    return ClaimedRewardCode(
      code: json['code']?.toString() ?? '',
      claimedAt: DateTime.tryParse(json['claimed_at']?.toString() ?? '') ?? DateTime.now(),
      reward: json['reward'] != null 
          ? RewardCodeReward.fromJson(json['reward']) 
          : const RewardCodeReward(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'claimed_at': claimedAt.toIso8601String(),
    'reward': reward.toJson(),
  };
}
