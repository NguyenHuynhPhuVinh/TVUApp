/// Model lưu trữ giao dịch ví
class WalletTransaction {
  final String id;
  final TransactionType type;
  final int amount;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
    id: json['id'] ?? '',
    type: TransactionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => TransactionType.other,
    ),
    amount: json['amount'] ?? 0,
    description: json['description'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    metadata: json['metadata'],
  );
}

enum TransactionType {
  tuitionBonus,    // Nhận tiền từ học phí
  buyDiamond,      // Mua diamond bằng tiền ảo
  buyCoin,         // Mua coin bằng diamond
  reward,          // Nhận thưởng
  subjectReward,   // Nhận thưởng môn học đạt (CTDT)
  other,           // Khác
}

extension TransactionTypeExt on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.tuitionBonus:
        return 'Thưởng học phí';
      case TransactionType.buyDiamond:
        return 'Mua Diamond';
      case TransactionType.buyCoin:
        return 'Mua Coin';
      case TransactionType.reward:
        return 'Nhận thưởng';
      case TransactionType.subjectReward:
        return 'Thưởng môn học';
      case TransactionType.other:
        return 'Khác';
    }
  }

  bool get isIncome {
    switch (this) {
      case TransactionType.tuitionBonus:
      case TransactionType.reward:
      case TransactionType.subjectReward:
        return true;
      case TransactionType.buyDiamond:
      case TransactionType.buyCoin:
      case TransactionType.other:
        return false;
    }
  }
}

