import 'package:get/get.dart';
import '../controllers/bug_report_controller.dart';

class BugReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BugReportController>(() => BugReportController());
  }
}
