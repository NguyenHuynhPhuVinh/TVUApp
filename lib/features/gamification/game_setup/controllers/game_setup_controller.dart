import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../infrastructure/storage/storage_service.dart';
import '../../../../features/app/routes/app_routes.dart';

class GameSetupController extends GetxController {
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();

  final missedSessionsController = TextEditingController();
  final isCalculating = false.obs;
  final totalLessons = 0.obs;
  final totalSemesters = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAlreadyInitialized();
    _calculateTotalLessons();
  }

  /// SECURITY: Kiểm tra nếu đã init rồi thì redirect về main
  void _checkAlreadyInitialized() {
    if (_gameService.isInitialized) {
      // Đã init rồi, không cho vào trang setup nữa
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.main);
      });
    }
  }

  @override
  void onClose() {
    missedSessionsController.dispose();
    super.onClose();
  }

  void _calculateTotalLessons() {
    totalLessons.value = _gameService.calculateTotalLessons();
    
    // Đếm số học kỳ
    final semestersData = _storage.getSemesters();
    if (semestersData != null && semestersData['data'] != null) {
      final semesterList = semestersData['data']['ds_hoc_ky'] as List? ?? [];
      totalSemesters.value = semesterList.length;
    }
  }

  /// Số buổi tối đa có thể nghỉ (tổng tiết / 4)
  int get maxMissedSessions => totalLessons.value ~/ 4;

  Future<void> startCalculation() async {
    // SECURITY: Lock để ngăn double click
    if (isCalculating.value) return;
    
    final missedText = missedSessionsController.text.trim();
    final missedSessions = int.tryParse(missedText) ?? 0;

    if (missedSessions < 0) {
      Get.snackbar(
        'Lỗi',
        'Số buổi nghỉ không hợp lệ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (missedSessions > maxMissedSessions) {
      Get.snackbar(
        'Lỗi',
        'Số buổi nghỉ không thể lớn hơn $maxMissedSessions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    isCalculating.value = true;

    try {
      final mssv = _authService.username.value;
      final result = await _gameService.initializeGame(
        mssv: mssv,
        missedSessions: missedSessions,
      );

      // Kiểm tra security fail
      if (result == null) {
        Get.snackbar(
          'Lỗi bảo mật',
          'Không thể khởi tạo game. Vui lòng kiểm tra thiết bị của bạn.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      // Chuyển sang trang hiển thị kết quả với animation
      Get.offNamed(Routes.gameStats, arguments: result);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tính toán: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isCalculating.value = false;
    }
  }
}



