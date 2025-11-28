/// Enum trạng thái nhận thưởng - dùng cho tất cả UI liên quan đến rewards
enum RewardClaimStatus {
  /// Bị khóa (chưa đủ điều kiện để hiển thị)
  locked,
  
  /// Chưa thể nhận (chưa đủ điều kiện)
  disabled,
  
  /// Có thể nhận
  canClaim,
  
  /// Đang xử lý nhận thưởng
  claiming,
  
  /// Đã nhận thành công
  claimed,
  
  /// Lỗi khi nhận
  error,
  
  /// Đang chờ (countdown)
  waiting,
}

extension RewardClaimStatusX on RewardClaimStatus {
  bool get isLoading => this == RewardClaimStatus.claiming;
  bool get isCompleted => this == RewardClaimStatus.claimed;
  bool get canInteract => this == RewardClaimStatus.canClaim;
  bool get canPerformAction => this == RewardClaimStatus.canClaim;
  bool get isDisabled => this == RewardClaimStatus.disabled;
  bool get isLocked => this == RewardClaimStatus.locked;
  bool get isError => this == RewardClaimStatus.error;
  bool get isWaiting => this == RewardClaimStatus.waiting;
}
