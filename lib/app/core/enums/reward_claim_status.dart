/// Trạng thái nhận thưởng chuẩn hóa cho toàn app
/// Thay thế: SubjectRewardStatus, TuitionBonusState, và các enum tương tự
enum RewardClaimStatus {
  /// Chưa đủ điều kiện nhận thưởng (VD: chưa đạt môn, chưa đóng tiền)
  locked,
  
  /// Có thể nhận thưởng
  canClaim,
  
  /// Đang xử lý nhận thưởng
  claiming,
  
  /// Đã nhận thưởng
  claimed,
  
  /// Đang chờ (VD: countdown timer)
  waiting,
  
  /// Lỗi khi nhận thưởng
  error,
}

/// Extension methods cho RewardClaimStatus
extension RewardClaimStatusX on RewardClaimStatus {
  /// Kiểm tra có thể thực hiện action không
  bool get canPerformAction => this == RewardClaimStatus.canClaim;
  
  /// Kiểm tra đang loading
  bool get isLoading => this == RewardClaimStatus.claiming;
  
  /// Kiểm tra đã hoàn thành
  bool get isCompleted => this == RewardClaimStatus.claimed;
  
  /// Kiểm tra bị khóa
  bool get isLocked => this == RewardClaimStatus.locked;
  
  /// Kiểm tra có lỗi
  bool get hasError => this == RewardClaimStatus.error;
  
  /// Kiểm tra đang chờ
  bool get isWaiting => this == RewardClaimStatus.waiting;
}
