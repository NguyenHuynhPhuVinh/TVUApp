import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/widgets.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../infrastructure/data_sync_manager.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../infrastructure/storage/storage_service.dart';
import '../../../../infrastructure/update/update_service.dart';
import '../../../../infrastructure/security/security_service.dart';
import '../../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final GameService _gameService = Get.find<GameService>();
  final StorageService _storage = Get.find<StorageService>();
  final UpdateService _updateService = Get.find<UpdateService>();
  final SecurityService _securityService = Get.find<SecurityService>();
  final DataSyncManager _syncManager = Get.find<DataSyncManager>();

  // Progress cho UI
  final syncProgress = 0.0.obs;
  final syncStatus = ''.obs;
  final isFirstTimeSync = false.obs;
  final appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
    _checkUpdateAndLoad();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = 'v${packageInfo.version}';
    } catch (e) {
      appVersion.value = '';
    }
  }

  /// Kiểm tra cập nhật trước, sau đó load app
  Future<void> _checkUpdateAndLoad() async {
    try {
      // 1. Kiểm tra security trước
      final securityResult = await _securityService.performSecurityCheck();
      if (!securityResult.isSecure) {
        // Thiết bị không an toàn -> hiện dialog và block
        await DuoSecurityDialog.show(securityResult.issues);
        return;
      }

      // 2. Kiểm tra update từ GitHub
      final hasUpdate = await _updateService.checkForUpdate();
      
      if (hasUpdate) {
        // Hiển thị dialog cập nhật (bắt buộc)
        await DuoUpdateDialog.show(
          currentVersion: _updateService.currentVersion.value,
          latestVersion: _updateService.latestVersion.value,
          releaseNotes: _updateService.releaseNotes.value,
          isDownloading: _updateService.isDownloading,
          downloadProgress: _updateService.downloadProgress,
          onUpdate: () => _handleUpdate(),
        );
      } else {
        _checkAuthAndLoad();
      }
    } catch (e) {
      print('Check update error: $e');
      _checkAuthAndLoad();
    }
  }

  /// Xử lý tải và cài đặt update
  Future<void> _handleUpdate() async {
    final success = await _updateService.downloadAndInstall();
    if (!success) {
      // Lỗi tải -> hiện snackbar, vẫn giữ dialog (bắt buộc cập nhật)
      Get.snackbar(
        'Lỗi',
        'Không thể tải bản cập nhật. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redSoft,
        colorText: AppColors.red,
      );
    }
  }

  Future<void> _checkAuthAndLoad() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!_authService.isLoggedIn.value) {
        Get.offAllNamed(Routes.login);
        return;
      }

      final mssv = _authService.username.value;
      if (mssv.isEmpty) {
        Get.offAllNamed(Routes.login);
        return;
      }

      // Check xem đây có phải lần đầu (chưa có data local) hay không
      final hasLocalData = _storage.getGrades() != null || 
                           _storage.getSemesters() != null;
      
      // Nếu vừa login xong (từ argument) hoặc chưa có data local -> sync hết
      final justLoggedIn = Get.arguments?['justLoggedIn'] == true;
      
      if (justLoggedIn || !hasLocalData) {
        isFirstTimeSync.value = true;
        await _performFullSync();
      } else {
        // Đã có data -> load nhanh TKB hiện tại, sync nền
        await _performQuickLoad();
      }
    } catch (e) {
      print('Splash error: $e');
      _navigateBasedOnGameState();
    }
  }

  /// Full sync sử dụng DataSyncManager
  Future<void> _performFullSync() async {
    await _syncManager.performFullSync(
      onProgress: (progress, status) {
        syncProgress.value = progress;
        syncStatus.value = status;
      },
    );

    await Future.delayed(const Duration(milliseconds: 300));
    _navigateBasedOnGameState();
  }

  /// Quick load + background sync sử dụng DataSyncManager
  Future<void> _performQuickLoad() async {
    final currentScheduleData = await _syncManager.performQuickLoad();

    // Navigate ngay, sync nền sau
    _navigateBasedOnGameState();

    // Background sync
    _syncManager.performBackgroundSync(currentScheduleData);
  }

  /// Navigate dựa trên game state
  void _navigateBasedOnGameState() {
    if (!_authService.isLoggedIn.value) {
      Get.offAllNamed(Routes.login);
      return;
    }

    if (!_gameService.isInitialized) {
      Get.offAllNamed(Routes.gameSetup);
    } else {
      Get.offAllNamed(Routes.main);
    }
  }
}



