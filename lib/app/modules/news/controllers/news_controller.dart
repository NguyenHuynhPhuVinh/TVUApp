import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class NewsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final newsList = <Map<String, dynamic>>[].obs;
  final selectedFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  Future<void> loadNews({String filter = ''}) async {
    selectedFilter.value = filter;
    isLoading.value = true;
    try {
      final response = await _apiService.getNews(type: filter);
      if (response != null && response['data'] != null) {
        final list = response['data']['ds_bai_dang'] as List?;
        if (list != null) {
          newsList.value = list.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải tin tức');
    } finally {
      isLoading.value = false;
    }
  }
}
