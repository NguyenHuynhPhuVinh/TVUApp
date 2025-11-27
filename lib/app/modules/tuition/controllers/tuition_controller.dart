import 'package:get/get.dart';
import '../../../data/services/local_storage_service.dart';

class TuitionController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final tuitionList = <Map<String, dynamic>>[].obs;
  final totalTuition = 0.0.obs;
  final totalPaid = 0.0.obs;
  final totalDebt = 0.0.obs;

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
        tuition += _parseDouble(item['phai_thu']);
        paid += _parseDouble(item['da_thu']);
        debt += _parseDouble(item['con_no']);
      }
      totalTuition.value = tuition;
      totalPaid.value = paid;
      totalDebt.value = debt;
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String formatCurrency(num amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}đ';
  }
}
