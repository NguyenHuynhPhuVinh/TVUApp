/// Model cho thư trong hòm thư
/// Mỗi thư có thể kèm quà (coins, diamonds, xp)
class MailItem {
  final String id;
  final String title;
  final String content;
  final DateTime sentAt;
  final DateTime? expiresAt;
  final MailReward? reward;
  final MailType type;
  final bool isRead;
  final bool isClaimed;

  const MailItem({
    required this.id,
    required this.title,
    required this.content,
    required this.sentAt,
    this.expiresAt,
    this.reward,
    this.type = MailType.system,
    this.isRead = false,
    this.isClaimed = false,
  });

  /// Kiểm tra thư đã hết hạn chưa
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Kiểm tra thư có quà không
  bool get hasReward => reward != null && !reward!.isEmpty;

  /// Kiểm tra có thể nhận quà không
  bool get canClaimReward => hasReward && !isClaimed && !isExpired;

  /// Copy với trạng thái mới
  MailItem copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? sentAt,
    DateTime? expiresAt,
    MailReward? reward,
    MailType? type,
    bool? isRead,
    bool? isClaimed,
  }) {
    return MailItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      expiresAt: expiresAt ?? this.expiresAt,
      reward: reward ?? this.reward,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  factory MailItem.fromJson(Map<String, dynamic> json) {
    return MailItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      sentAt: DateTime.tryParse(json['sent_at']?.toString() ?? '') ?? DateTime.now(),
      expiresAt: json['expires_at'] != null 
          ? DateTime.tryParse(json['expires_at'].toString()) 
          : null,
      reward: json['reward'] != null 
          ? MailReward.fromJson(json['reward']) 
          : null,
      type: MailType.fromString(json['type']?.toString() ?? 'system'),
      isRead: json['is_read'] == true,
      isClaimed: json['is_claimed'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'sent_at': sentAt.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'reward': reward?.toJson(),
    'type': type.name,
    'is_read': isRead,
    'is_claimed': isClaimed,
  };
}

/// Phần thưởng kèm theo thư
class MailReward {
  final int coins;
  final int diamonds;
  final int xp;

  const MailReward({
    this.coins = 0,
    this.diamonds = 0,
    this.xp = 0,
  });

  bool get isEmpty => coins == 0 && diamonds == 0 && xp == 0;

  factory MailReward.fromJson(Map<String, dynamic> json) {
    return MailReward(
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

/// Loại thư
enum MailType {
  system,     // Thông báo hệ thống
  reward,     // Quà thưởng
  event,      // Sự kiện
  welcome,    // Chào mừng
  update;     // Cập nhật

  static MailType fromString(String value) {
    return MailType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MailType.system,
    );
  }

  String get displayName {
    switch (this) {
      case MailType.system:
        return 'Hệ thống';
      case MailType.reward:
        return 'Quà thưởng';
      case MailType.event:
        return 'Sự kiện';
      case MailType.welcome:
        return 'Chào mừng';
      case MailType.update:
        return 'Cập nhật';
    }
  }
}
