import 'package:get/get.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../core/utils/number_formatter.dart';

class WalletController extends GetxController {
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final isLoading = false.obs;
  final canClaimTuitionBonus = false.obs;
  final tuitionPaid = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkTuitionBonus();
  }

  // Getters
  int get virtualBalance => _gameService.stats.value.virtualBalance;
  int get coins => _gameService.stats.value.coins;
  int get diamonds => _gameService.stats.value.diamonds;
  bool get tuitionBonusClaimed => _gameService.stats.value.tuitionBonusClaimed;
  List<WalletTransaction> get transactions => _gameService.transactions;

  String get mssv => _authService.username.value;
  String get fullName => _localStorage.getStudentName() ?? mssv;

  /// Kiểm tra có thể nhận bonus học phí không
  void _checkTuitionBonus() {
    if (tuitionBonusClaimed) {
      canClaimTuitionBonus.value = false;
      return;
    }

    final tuitionData = _localStorage.getTuition();
    if (tuitionData != null && tuitionData['data'] != null) {
      final data = tuitionData['data'];
      final list = data['ds_hoc_phi_hoc_ky'] as List? ?? [];
      
      int totalPaid = 0;
      for (var item in list) {
        totalPaid += NumberFormatter.parseInt(item['da_thu']);
      }
      
      tuitionPaid.value = totalPaid;
      canClaimTuitionBonus.value = totalPaid > 0;
    }
  }

  /// Nhận bonus từ học phí
  Future<Map<String, dynamic>?> claimTuitionBonus() async {
    if (!canClaimTuitionBonus.value || tuitionPaid.value <= 0) return null;
    
    isLoading.value = true;
    try {
      final result = await _gameService.claimTuitionBonus(
        mssv: mssv,
        tuitionPaid: tuitionPaid.value,
      );
      
      if (result != null) {
        canClaimTuitionBonus.value = false;
      }
      
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  /// Format tiền ảo
  String formatBalance(int amount) => NumberFormatter.compact(amount);
  
  /// Format tiền VND
  String formatCurrency(int amount) => '${NumberFormatter.currency(amount)}đ';
}
