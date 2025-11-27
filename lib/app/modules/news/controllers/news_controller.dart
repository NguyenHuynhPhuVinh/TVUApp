import 'package:get/get.dart';
import '../../../data/services/local_storage_service.dart';

class NewsController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final notificationList = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    final notificationsData = _localStorage.getNotifications();
    if (notificationsData != null && notificationsData['data'] != null) {
      final data = notificationsData['data'];
      final list = data['ds_thong_bao'] as List? ?? [];
      notificationList.value = list.map((e) => Map<String, dynamic>.from(e)).toList();
      unreadCount.value = data['notification'] ?? 0;
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
