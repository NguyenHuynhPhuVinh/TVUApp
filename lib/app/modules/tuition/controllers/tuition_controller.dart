import 'package:get/get.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/local_storage_service.dart';

class TuitionController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final tuitionList = <Map<String, dynamic>>[].obs;
  final totalTuition = 0.0.obs;
  final totalPaid = 0.0.obs;
  final totalDebt = 0.0.obs;
  final claimingId = ''.obs; // ID học kỳ đang claim

  String get mssv => _authService.username.value;

  @override
  void onInit() {
    super.onInit();
    loadTuition();
  }

  void loadTuition() {
    final tuitionData = _localStorage.getTuition();
    if (tuitionData != null && tuitionData['data'] != null) {
      final data = tuitionData['data'];
      final list = data['ds_hoc_phi_hoc_ky'] as List? ?? [];
      tuitionList.value = list.map((e) => Map<String, dynamic>.from(e)).toList();

      double tuition = 0;
      double paid = 0;
      double debt = 0;
      for (var item in tuitionList) {
        tuition += NumberFormatter.parseDouble(item['phai_thu']);
        paid += NumberFormatter.parseDouble(item['da_thu']);
        debt += NumberFormatter.parseDouble(item['con_no']);
      }
      totalTuition.value = tuition;
      totalPaid.value = paid;
      totalDebt.value = debt;
    }
  }

  /// Kiểm tra học kỳ đã claim chưa
  bool isSemesterClaimed(String semesterId) {
    return _gameService.stats.value.isSemesterClaimed(semesterId);
  }

  /// Kiểm tra có thể claim học kỳ này không (đã đóng tiền và chưa claim)
  bool canClaimSemester(Map<String, dynamic> item) {
    final daThu = NumberFormatter.parseInt(item['da_thu']);
    final semesterId = item['ten_hoc_ky'] ?? '';
    return daThu > 0 && !isSemesterClaimed(semesterId);
  }

  /// Claim bonus cho 1 học kỳ
  Future<Map<String, dynamic>?> claimSemesterBonus(Map<String, dynamic> item) async {
    final semesterId = item['ten_hoc_ky'] ?? '';
    final daThu = NumberFormatter.parseInt(item['da_thu']);
    
    if (semesterId.isEmpty || daThu <= 0) return null;
    if (claimingId.value.isNotEmpty) return null; // Đang claim học kỳ khác
    
    claimingId.value = semesterId;
    try {
      final result = await _gameService.claimTuitionBonusBySemester(
        mssv: mssv,
        semesterId: semesterId,
        tuitionPaid: daThu,
      );
      return result;
    } finally {
      claimingId.value = '';
    }
  }

  String formatCurrency(num amount) {
    return '${NumberFormatter.currency(amount)}đ';
  }
}
