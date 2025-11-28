import 'package:get/get.dart';
import '../../../core/utils/number_formatter.dart';
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
        tuition += NumberFormatter.parseDouble(item['phai_thu']);
        paid += NumberFormatter.parseDouble(item['da_thu']);
        debt += NumberFormatter.parseDouble(item['con_no']);
      }
      totalTuition.value = tuition;
      totalPaid.value = paid;
      totalDebt.value = debt;
    }
  }

  String formatCurrency(num amount) {
    return '${NumberFormatter.currency(amount)}đ';
  }
}
