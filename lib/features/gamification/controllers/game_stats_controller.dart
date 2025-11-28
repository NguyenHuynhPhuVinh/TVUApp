import 'package:get/get.dart';
import '../../../../features/app/routes/app_routes.dart';

class GameStatsController extends GetxController {
  // Data từ tính toán
  late final int totalLessons;
  late final int attendedLessons;
  late final int missedLessons;
  late final int earnedCoins;
  late final int earnedDiamonds;
  late final int earnedXp;
  late final int level;
  late final double attendanceRate;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      totalLessons = args['totalLessons'] ?? 0;
      attendedLessons = args['attendedLessons'] ?? 0;
      missedLessons = args['missedLessons'] ?? 0;
      earnedCoins = args['earnedCoins'] ?? 0;
      earnedDiamonds = args['earnedDiamonds'] ?? 0;
      earnedXp = args['earnedXp'] ?? 0;
      level = args['level'] ?? 1;
      attendanceRate = args['attendanceRate'] ?? 100.0;
    } else {
      totalLessons = 0;
      attendedLessons = 0;
      missedLessons = 0;
      earnedCoins = 0;
      earnedDiamonds = 0;
      earnedXp = 0;
      level = 1;
      attendanceRate = 100.0;
    }
  }

  void continueToRewards() {
    // Chuyển sang trang rewards với data
    Get.toNamed(Routes.gameRewards, arguments: {
      'earnedCoins': earnedCoins,
      'earnedDiamonds': earnedDiamonds,
      'earnedXp': earnedXp,
      'level': level,
    });
  }
}



