import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../features/gamification/core/game_service.dart';
import '../../../infrastructure/storage/storage_service.dart';

class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage();
  
  final isLoggedIn = false.obs;
  final accessToken = ''.obs;
  final username = ''.obs;

  Future<AuthService> init() async {
    final token = await _storage.read(key: 'access_token');
    final user = await _storage.read(key: 'username');
    
    if (token != null && token.isNotEmpty) {
      accessToken.value = token;
      isLoggedIn.value = true;
    }
    if (user != null) {
      username.value = user;
    }
    return this;
  }

  Future<void> saveCredentials({
    required String token,
    required String user,
    required String password,
  }) async {
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'username', value: user);
    await _storage.write(key: 'password', value: password);
    
    accessToken.value = token;
    username.value = user;
    isLoggedIn.value = true;
  }

  Future<void> updateToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
    accessToken.value = token;
  }

  Future<Map<String, String?>> getCredentials() async {
    return {
      'username': await _storage.read(key: 'username'),
      'password': await _storage.read(key: 'password'),
    };
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    // Clear local storage data
    final storage = Get.find<StorageService>();
    await storage.clearAll();
    
    // Reset game stats
    final gameService = Get.find<GameService>();
    await gameService.resetGame();
    
    accessToken.value = '';
    username.value = '';
    isLoggedIn.value = false;
  }
}

