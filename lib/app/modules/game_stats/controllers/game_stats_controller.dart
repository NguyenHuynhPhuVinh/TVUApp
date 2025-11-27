import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

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

  // Animation states
  final showStats = false.obs;
  final showCoins = false.obs;
  final showDiamonds = false.obs;
  final showLevel = false.obs;
  final showButton = false.obs;
  
  // Animated values
  final animatedCoins = 0.obs;
  final animatedDiamonds = 0.obs;
  final animatedXp = 0.obs;
  final animatedLevel = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _startAnimations();
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

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    showStats.value = true;
    
    await Future.delayed(const Duration(milliseconds: 500));
    showCoins.value = true;
    _animateValue(animatedCoins, earnedCoins, duration: 1500);
    
    await Future.delayed(const Duration(milliseconds: 300));
    showDiamonds.value = true;
    _animateValue(animatedDiamonds, earnedDiamonds, duration: 800);
    
    await Future.delayed(const Duration(milliseconds: 300));
    showLevel.value = true;
    _animateValue(animatedLevel, level, duration: 1000);
    _animateValue(animatedXp, earnedXp, duration: 1200);
    
    await Future.delayed(const Duration(milliseconds: 800));
    showButton.value = true;
  }

  void _animateValue(RxInt target, int endValue, {int duration = 1000}) async {
    if (endValue == 0) {
      target.value = 0;
      return;
    }
    
    final steps = 30;
    final stepDuration = duration ~/ steps;
    final increment = endValue / steps;
    
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      target.value = (increment * i).round().clamp(0, endValue);
    }
    target.value = endValue;
  }

  void continueToMain() {
    Get.offAllNamed(Routes.main);
  }
}
