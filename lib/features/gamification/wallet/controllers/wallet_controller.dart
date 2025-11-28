import 'package:get/get.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../features/gamification/wallet/wallet_transaction.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../infrastructure/storage/storage_service.dart';

class WalletController extends GetxController {
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();

  // Getters
  int get virtualBalance => _gameService.stats.value.virtualBalance;
  int get coins => _gameService.stats.value.coins;
  int get diamonds => _gameService.stats.value.diamonds;
  List<WalletTransaction> get transactions => _gameService.transactions;

  String get mssv => _authService.username.value;
  String get fullName => _storage.getStudentName() ?? mssv;

  /// Format tiền ảo
  String formatBalance(int amount) => amount.toCompact;

  /// Format tiền VND
  String formatCurrency(int amount) => amount.toVND;
}



