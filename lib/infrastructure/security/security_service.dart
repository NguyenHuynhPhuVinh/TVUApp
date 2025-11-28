import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safe_device/safe_device.dart';

/// Security Service - Chống gian lận sử dụng các package bên ngoài
/// 
/// Các lớp bảo vệ:
/// 1. Phát hiện Root/Jailbreak (flutter_jailbreak_detection)
/// 2. Phát hiện Emulator (safe_device)
/// 3. Phát hiện Debug mode
/// 4. Device fingerprint (device_info_plus)
/// 5. Data integrity check (crypto)
class SecurityService extends GetxService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  // Security status
  final isSecure = true.obs;
  final securityIssues = <String>[].obs;
  final deviceFingerprint = ''.obs;
  
  // Cached checks
  bool? _isRooted;
  bool? _isEmulator;
  bool? _isDebugMode;
  String? _deviceId;

  Future<SecurityService> init() async {
    await _generateDeviceFingerprint();
    return this;
  }

  /// Kiểm tra toàn bộ security
  Future<SecurityCheckResult> performSecurityCheck() async {
    securityIssues.clear();
    
    // 1. Check Root/Jailbreak
    final rooted = await isDeviceRooted();
    if (rooted) {
      securityIssues.add('Thiết bị đã root/jailbreak');
    }
    
    // 2. Check Emulator
    final emulator = await isRunningOnEmulator();
    if (emulator) {
      securityIssues.add('Đang chạy trên máy ảo');
    }
    
    // 3. Check Debug mode (chỉ block nếu release bị attach debugger)
    final debug = isDebugMode();
    if (debug && !kDebugMode) {
      securityIssues.add('Phát hiện debug mode bất thường');
    }
    
    // 4. Check real device (safe_device)
    final realDevice = await isRealDevice();
    if (!realDevice) {
      securityIssues.add('Không phải thiết bị thật');
    }
    
    isSecure.value = securityIssues.isEmpty;
    
    return SecurityCheckResult(
      isSecure: securityIssues.isEmpty,
      isRooted: rooted,
      isEmulator: emulator,
      isDebugMode: debug,
      isRealDevice: realDevice,
      issues: List.from(securityIssues),
      deviceFingerprint: deviceFingerprint.value,
    );
  }

  /// Phát hiện Root/Jailbreak (sử dụng safe_device)
  Future<bool> isDeviceRooted() async {
    if (_isRooted != null) return _isRooted!;
    
    try {
      // safe_device có check root/jailbreak
      _isRooted = await SafeDevice.isJailBroken;
      return _isRooted!;
    } catch (e) {
      debugPrint('Root detection error: $e');
      return false;
    }
  }

  /// Phát hiện Developer mode
  Future<bool> isDeveloperMode() async {
    // safe_device không có API này, return false
    return false;
  }

  /// Phát hiện Emulator
  Future<bool> isRunningOnEmulator() async {
    if (_isEmulator != null) return _isEmulator!;
    
    try {
      _isEmulator = await SafeDevice.isRealDevice == false;
      return _isEmulator!;
    } catch (e) {
      debugPrint('Emulator detection error: $e');
      return false;
    }
  }

  /// Kiểm tra thiết bị thật
  Future<bool> isRealDevice() async {
    try {
      return await SafeDevice.isRealDevice;
    } catch (e) {
      return true;
    }
  }

  /// Kiểm tra Debug mode
  bool isDebugMode() {
    if (_isDebugMode != null) return _isDebugMode!;
    
    _isDebugMode = false;
    assert(() {
      _isDebugMode = true;
      return true;
    }());
    return _isDebugMode!;
  }

  /// Tạo device fingerprint unique
  Future<void> _generateDeviceFingerprint() async {
    try {
      String rawFingerprint = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        rawFingerprint = '${androidInfo.id}|${androidInfo.model}|${androidInfo.brand}|${androidInfo.device}|${androidInfo.fingerprint}';
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        rawFingerprint = '${iosInfo.identifierForVendor}|${iosInfo.model}|${iosInfo.name}|${iosInfo.systemVersion}';
        _deviceId = iosInfo.identifierForVendor;
      }
      
      // Hash fingerprint
      final bytes = utf8.encode(rawFingerprint);
      deviceFingerprint.value = sha256.convert(bytes).toString();
    } catch (e) {
      debugPrint('Fingerprint generation error: $e');
      deviceFingerprint.value = 'unknown';
    }
  }

  /// Lấy device ID
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      _deviceId = 'unknown';
    }
    
    return _deviceId!;
  }

  /// Tạo checksum cho data
  String generateChecksum(Map<String, dynamic> data) {
    final jsonStr = jsonEncode(data);
    final bytes = utf8.encode(jsonStr + deviceFingerprint.value);
    return sha256.convert(bytes).toString();
  }

  /// Verify checksum
  bool verifyChecksum(Map<String, dynamic> data, String checksum) {
    return generateChecksum(data) == checksum;
  }

  /// Tạo signed data (data + checksum)
  Map<String, dynamic> signData(Map<String, dynamic> data) {
    final checksum = generateChecksum(data);
    return {
      ...data,
      '_checksum': checksum,
      '_timestamp': DateTime.now().millisecondsSinceEpoch,
      '_deviceId': _deviceId,
    };
  }

  /// Verify signed data
  bool verifySignedData(Map<String, dynamic> signedData) {
    final checksum = signedData['_checksum'] as String?;
    if (checksum == null) return false;
    
    final data = Map<String, dynamic>.from(signedData);
    data.remove('_checksum');
    data.remove('_timestamp');
    data.remove('_deviceId');
    
    return verifyChecksum(data, checksum);
  }
}

/// Kết quả kiểm tra security
class SecurityCheckResult {
  final bool isSecure;
  final bool isRooted;
  final bool isEmulator;
  final bool isDebugMode;
  final bool isRealDevice;
  final List<String> issues;
  final String deviceFingerprint;

  SecurityCheckResult({
    required this.isSecure,
    required this.isRooted,
    required this.isEmulator,
    required this.isDebugMode,
    required this.isRealDevice,
    required this.issues,
    required this.deviceFingerprint,
  });

  @override
  String toString() {
    return 'SecurityCheckResult(isSecure: $isSecure, issues: $issues)';
  }
}
