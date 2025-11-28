import 'package:get/get.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../routes/app_routes.dart';

class TuitionBonusController extends GetxController {
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final tuitionPaid = 0.obs;
  final virtualBalance = 0.obs;
  final displayedBalance = 0.obs; // Số hiển thị animation
  final isAnimating = false.obs;
  final isClaiming = false.obs;
  final isClaimed = false.obs;

  String get mssv => _authService.username.value;

  @override
  void onInit() {
    super.onInit();
    _loadTuitionData();
  }

  void _loadTuitionData() {
    final tuitionData = _localStorage.getTuition();
    if (tuitionData != null && tuitionData['data'] != null) {
      final list = tuitionData['data']['ds_hoc_phi_hoc_ky'] as List? ?? [];
      
      int totalPaid = 0;
      for (var item in list) {
        totalPaid += NumberFormatter.parseInt(item['da_thu']);
      }
      
      tuitionPaid.value = totalPaid;
      // 1 VND = 1 tiền ảo (1:1)
      virtualBalance.value = _gameService.calculateVirtualBalanceFromTuition(totalPaid);
    }
  }

  /// Bắt đầu animation đếm số
  Future<void> startCountAnimation() async {
    if (virtualBalance.value <= 0) return;
    
    isAnimating.value = true;
    displayedBalance.value = 0;
    
    final target = virtualBalance.value;
    final duration = const Duration(milliseconds: 2000);
    final steps = 60; // 60 frames
    final stepDuration = duration.inMilliseconds ~/ steps;
    final increment = target / steps;
    
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      displayedBalance.value = (increment * i).round();
      if (displayedBalance.value > target) {
        displayedBalance.value = target;
      }
    }
    
    displayedBalance.value = target;
    isAnimating.value = false;
  }

  /// Nhận tiền ảo và chuyển sang main
  Future<void> claimAndContinue() async {
    if (isClaiming.value || isClaimed.value) return;
    
    isClaiming.value = true;
    
    try {
      final result = await _gameService.claimTuitionBonus(
        mssv: mssv,
        tuitionPaid: tuitionPaid.value,
      );
      
      if (result != null) {
        isClaimed.value = true;
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.main);
      } else {
        // Nếu đã claim rồi hoặc lỗi, vẫn chuyển sang main
        Get.offAllNamed(Routes.main);
      }
    } catch (e) {
      Get.offAllNamed(Routes.main);
    } finally {
      isClaiming.value = false;
    }
  }

  /// Bỏ qua và chuyển sang main
  void skip() {
    Get.offAllNamed(Routes.main);
  }

  String formatCurrency(int amount) => '${NumberFormatter.currency(amount)}đ';
  String formatBalance(int amount) => NumberFormatter.withCommas(amount);
}
