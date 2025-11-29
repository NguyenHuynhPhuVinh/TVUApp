import 'package:get/get.dart';
import '../controllers/mailbox_controller.dart';
import '../services/mailbox_service.dart';

class MailboxBinding extends Bindings {
  @override
  void dependencies() {
    // Service đã được đăng ký global trong main.dart
    if (!Get.isRegistered<MailboxService>()) {
      Get.put(MailboxService(), permanent: true);
    }
    Get.lazyPut<MailboxController>(() => MailboxController());
  }
}
