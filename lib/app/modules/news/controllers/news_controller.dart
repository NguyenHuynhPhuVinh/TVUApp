import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class NewsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final notificationList = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getNotifications();
      if (response != null && response['data'] != null) {
        final data = response['data'];
        final list = data['ds_thong_bao'] as List? ?? [];
        notificationList.value = list.map((e) => Map<String, dynamic>.from(e)).toList();
        unreadCount.value = data['notification'] ?? 0;
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
