import 'package:get/get.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../features/academic/models/tuition_semester.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../infrastructure/storage/storage_service.dart';

class TuitionController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final tuitionList = <TuitionSemester>[].obs;
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
    final tuitionData = _storage.getTuition();
    if (tuitionData != null && tuitionData['data'] != null) {
      final data = tuitionData['data'];
      final list = data['ds_hoc_phi_hoc_ky'] as List? ?? [];
      tuitionList.value = list
          .map((e) => TuitionSemester.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      double tuition = 0;
      double paid = 0;
      double debt = 0;
      for (var item in tuitionList) {
        tuition += item.phaiThu;
        paid += item.daThu;
        debt += item.conNo;
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
  bool canClaimSemester(TuitionSemester item) {
    return item.paidAmount > 0 && !isSemesterClaimed(item.tenHocKy);
  }

  /// Claim bonus cho 1 học kỳ
  Future<Map<String, dynamic>?> claimSemesterBonus(TuitionSemester item) async {
    if (item.tenHocKy.isEmpty || item.paidAmount <= 0) return null;
    if (claimingId.value.isNotEmpty) return null; // Đang claim học kỳ khác
    
    claimingId.value = item.tenHocKy;
    try {
      final result = await _gameService.claimTuitionBonusBySemester(
        mssv: mssv,
        semesterId: item.tenHocKy,
        tuitionPaid: item.paidAmount,
      );
      return result;
    } finally {
      claimingId.value = '';
    }
  }

  String formatCurrency(num amount) => amount.toVND;
}



