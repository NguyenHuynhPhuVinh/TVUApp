import 'package:get/get.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../core/utils/number_formatter.dart';

class WalletController extends GetxController {
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  // Getters
  int get virtualBalance => _gameService.stats.value.virtualBalance;
  int get coins => _gameService.stats.value.coins;
  int get diamonds => _gameService.stats.value.diamonds;
  List<WalletTransaction> get transactions => _gameService.transactions;

  String get mssv => _authService.username.value;
  String get fullName => _localStorage.getStudentName() ?? mssv;

  /// Format tiền ảo
  String formatBalance(int amount) => NumberFormatter.compact(amount);
  
  /// Format tiền VND
  String formatCurrency(int amount) => '${NumberFormatter.currency(amount)}đ';
}
