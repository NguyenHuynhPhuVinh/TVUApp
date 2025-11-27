import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class GameRewardsController extends GetxController {
  // Data từ tính toán
  late final int earnedCoins;
  late final int earnedDiamonds;
  late final int earnedXp;
  late final int level;

  // Animation states
  final showCoins = false.obs;
  final showDiamonds = false.obs;
  final showLevel = false.obs;
  final showButton = false.obs;

  // Animated values
  final animatedCoins = 0.obs;
  final animatedDiamonds = 0.obs;
  final animatedXp = 0.obs;
  final animatedLevel = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _startAnimations();
  }

  void _loadData() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      earnedCoins = args['earnedCoins'] ?? 0;
      earnedDiamonds = args['earnedDiamonds'] ?? 0;
      earnedXp = args['earnedXp'] ?? 0;
      level = args['level'] ?? 1;
    } else {
      earnedCoins = 0;
      earnedDiamonds = 0;
      earnedXp = 0;
      level = 1;
    }
  }

  Future<void> _startAnimations() async {
    // Coins animation
    await Future.delayed(const Duration(milliseconds: 500));
    showCoins.value = true;
    _animateValue(animatedCoins, earnedCoins, duration: 2000);

    // Diamonds animation
    await Future.delayed(const Duration(milliseconds: 800));
    showDiamonds.value = true;
    _animateValue(animatedDiamonds, earnedDiamonds, duration: 1500);

    // Level animation
    await Future.delayed(const Duration(milliseconds: 800));
    showLevel.value = true;
    _animateLevelUp();
    _animateValue(animatedXp, earnedXp, duration: 2000);

    // Button
    await Future.delayed(const Duration(milliseconds: 1500));
    showButton.value = true;
  }

  void _animateValue(RxInt target, int endValue, {int duration = 1500}) async {
    if (endValue == 0) {
      target.value = 0;
      return;
    }

    final steps = 50;
    final stepDuration = duration ~/ steps;
    final increment = endValue / steps;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      target.value = (increment * i).round().clamp(0, endValue);
    }
    target.value = endValue;
  }

  void _animateLevelUp() async {
    // Animate level từ 1 lên level đạt được
    for (int i = 1; i <= level; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      animatedLevel.value = i;
    }
  }

  void continueToMain() {
    Get.offAllNamed(Routes.main);
  }
}
