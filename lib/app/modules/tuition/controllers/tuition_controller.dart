import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class TuitionController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final tuitionList = <Map<String, dynamic>>[].obs;
  final totalDebt = 0.0.obs;
  final totalPaid = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTuition();
  }

  Future<void> loadTuition() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getTuition();
      if (response != null && response['data'] != null) {
        final data = response['data'];
        final list = data['ds_hoc_phi_hoc_ky'] as List? ?? [];
        tuitionList.value = list.map((e) => Map<String, dynamic>.from(e)).toList();
        
        double debt = 0;
        double paid = 0;
        for (var item in tuitionList) {
          debt += (item['con_no'] ?? 0).toDouble();
          paid += (item['da_thu'] ?? 0).toDouble();
        }
        totalDebt.value = debt;
        totalPaid.value = paid;
      }
    } catch (e) {
      print('Error loading tuition: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String formatCurrency(num amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )} đ';
  }
}
