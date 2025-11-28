import 'package:get/get.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../infrastructure/storage/storage_service.dart';
import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final notificationList = <NotificationItem>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    final notificationsData = _storage.getNotifications();
    if (notificationsData != null && notificationsData['data'] != null) {
      final data = notificationsData['data'];
      final list = data['ds_thong_bao'] as List? ?? [];
      notificationList.value =
          list.map((e) => NotificationItem.fromJson(e)).toList();
      unreadCount.value = data['notification'] ?? 0;
    }
  }

  String formatDate(String? dateStr) =>
      DateFormatter.formatIsoToVietnamese(dateStr);
}
