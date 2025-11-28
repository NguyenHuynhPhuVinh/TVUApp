import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../infrastructure/security/security_service.dart';

/// Guard class chứa các wrapper bảo mật cho game actions
/// Giảm code lặp lại trong GameService
class GameSecurityGuard extends GetxService {
  late final SecurityService _security;

  final isSecure = true.obs;
  final securityIssues = <String>[].obs;
  final isLoading = false.obs;

  Future<GameSecurityGuard> init() async {
    _security = Get.find<SecurityService>();
    await checkSecurity();
    return this;
  }

  /// Kiểm tra security khi khởi động
  Future<void> checkSecurity() async {
    final result = await _security.performSecurityCheck();
    isSecure.value = result.isSecure;
    securityIssues.value = result.issues;

    if (!result.isSecure) {
      debugPrint('⚠️ Security issues detected: ${result.issues}');
    }
  }

  // ============ SECURITY WRAPPERS ============

  /// Wrapper thực thi action với security check
  /// Giảm code lặp lại trong các hàm cần bảo mật
  Future<T?> secureExecute<T>({
    required Future<T> Function() action,
    required String actionName,
    T? fallbackValue,
  }) async {
    if (!isSecure.value) {
      await checkSecurity();
      if (!isSecure.value) {
        debugPrint('⚠️ $actionName blocked: Security issues detected');
        return fallbackValue;
      }
    }
    return await action();
  }

  /// Wrapper cho action trả về bool
  Future<bool> secureExecuteBool({
    required Future<bool> Function() action,
    required String actionName,
  }) async {
    return await secureExecute(
          action: action,
          actionName: actionName,
          fallbackValue: false,
        ) ??
        false;
  }

  /// Wrapper thực thi action với security check + loading state
  /// Dùng cho các hàm claim/buy cần hiển thị loading
  Future<T?> secureExecuteWithLoading<T>({
    required Future<T?> Function() action,
    required String actionName,
  }) async {
    isLoading.value = true;
    try {
      if (!isSecure.value) {
        await checkSecurity();
        if (!isSecure.value) {
          debugPrint('⚠️ $actionName blocked: Security issues detected');
          return null;
        }
      }
      return await action();
    } finally {
      isLoading.value = false;
    }
  }

  /// Wrapper thực thi action với security check + loading + lock
  /// Dùng cho các hàm buy cần ngăn double click
  Future<T?> secureExecuteWithLock<T>({
    required Future<T?> Function() action,
    required String actionName,
    required bool Function() isLocked,
    required void Function(bool) setLock,
  }) async {
    if (isLocked()) {
      debugPrint('⚠️ $actionName blocked: Already processing');
      return null;
    }
    setLock(true);
    isLoading.value = true;
    try {
      if (!isSecure.value) {
        await checkSecurity();
        if (!isSecure.value) {
          debugPrint('⚠️ $actionName blocked: Security issues detected');
          return null;
        }
      }
      return await action();
    } finally {
      setLock(false);
      isLoading.value = false;
    }
  }

  // ============ VALIDATION HELPERS ============

  /// Validate amount > 0
  bool validatePositiveAmount(int amount, String actionName) {
    if (amount <= 0) {
      debugPrint('⚠️ $actionName blocked: Invalid amount $amount');
      return false;
    }
    return true;
  }

  /// Validate lessons (1-12)
  bool validateLessons(int lessons, String actionName) {
    if (lessons <= 0 || lessons > 12) {
      debugPrint('⚠️ $actionName blocked: Invalid lessons $lessons');
      return false;
    }
    return true;
  }

  /// Validate credits (1-20)
  bool validateCredits(int credits, String actionName) {
    if (credits <= 0 || credits > 20) {
      debugPrint('⚠️ $actionName blocked: Invalid credits $credits');
      return false;
    }
    return true;
  }
}

