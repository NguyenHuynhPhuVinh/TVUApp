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
    // Coins animation - hiện card rồi đếm số
    await Future.delayed(const Duration(milliseconds: 500));
    showCoins.value = true;
    
    // Đợi card animation xong rồi mới đếm
    await Future.delayed(const Duration(milliseconds: 400));
    _countUp(animatedCoins, earnedCoins, duration: 1500);

    // Diamonds animation
    await Future.delayed(const Duration(milliseconds: 600));
    showDiamonds.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    _countUp(animatedDiamonds, earnedDiamonds, duration: 1000);

    // XP Progress animation - widget tự handle, chỉ cần show
    await Future.delayed(const Duration(milliseconds: 600));
    showLevel.value = true;
    // Button sẽ được show khi XP animation complete (từ widget callback)
  }

  /// Đếm số từ 0 lên endValue
  Future<void> _countUp(RxInt target, int endValue, {int duration = 1500}) async {
    if (endValue == 0) {
      target.value = 0;
      return;
    }

    const int fps = 60;
    final int totalFrames = (duration / 1000 * fps).round();
    final int frameDelay = duration ~/ totalFrames;
    
    for (int frame = 1; frame <= totalFrames; frame++) {
      await Future.delayed(Duration(milliseconds: frameDelay));
      // Easing out effect - chậm dần về cuối
      final progress = frame / totalFrames;
      final easedProgress = 1 - (1 - progress) * (1 - progress);
      target.value = (endValue * easedProgress).round();
    }
    target.value = endValue;
  }

  void continueToMain() {
    Get.offAllNamed(Routes.main);
  }
}
