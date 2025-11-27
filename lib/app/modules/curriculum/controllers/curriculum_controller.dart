import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class CurriculumController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final curriculumList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCurriculum();
  }

  Future<void> loadCurriculum() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getCurriculum();
      if (response != null && response['data'] != null) {
        final list = response['data']['ds_ctdt'] as List?;
        if (list != null) {
          curriculumList.value = list.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải chương trình đào tạo');
    } finally {
      isLoading.value = false;
    }
  }
}
