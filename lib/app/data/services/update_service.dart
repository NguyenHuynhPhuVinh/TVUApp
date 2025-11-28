import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateService extends GetxService {
  static const String _githubOwner = 'NguyenHuynhPhuVinh'; 
  static const String _githubRepo = 'TVUApp';
  static const String _releasesUrl =
      'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

  final Dio _dio = Dio();

  // Observable states
  final isChecking = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final hasUpdate = false.obs;
  final latestVersion = ''.obs;
  final releaseNotes = ''.obs;
  final downloadUrl = ''.obs;
  final currentVersion = ''.obs;

  Future<UpdateService> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion.value = packageInfo.version;
    } catch (e) {
      currentVersion.value = '1.0.0';
    }
    return this;
  }

  /// Kiểm tra phiên bản mới từ GitHub
  Future<bool> checkForUpdate() async {
    if (kIsWeb) return false; // Không hỗ trợ web

    try {
      isChecking.value = true;
      hasUpdate.value = false;

      final response = await _dio.get(
        _releasesUrl,
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tagName = (data['tag_name'] as String?)?.replaceAll('v', '') ?? '';
        final body = data['body'] as String? ?? '';
        final assets = data['assets'] as List? ?? [];

        latestVersion.value = tagName;
        releaseNotes.value = body;

        // Tìm file APK phù hợp
        String? apkUrl;
        for (var asset in assets) {
          final name = asset['name'] as String? ?? '';
          if (name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
        downloadUrl.value = apkUrl ?? '';

        // So sánh version
        if (_isNewerVersion(tagName, currentVersion.value)) {
          hasUpdate.value = true;
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Check update error: $e');
      return false;
    } finally {
      isChecking.value = false;
    }
  }

  /// So sánh 2 version string (VD: "1.0.2" > "1.0.1")
  /// Hỗ trợ cả format "1.0" và "1.0.0"
  bool _isNewerVersion(String latest, String current) {
    try {
      // Chuẩn hóa version string
      final latestClean = latest.replaceAll(RegExp(r'[^0-9.]'), '');
      final currentClean = current.replaceAll(RegExp(r'[^0-9.]'), '');

      final latestParts = latestClean.split('.').map((s) => int.tryParse(s) ?? 0).toList();
      final currentParts = currentClean.split('.').map((s) => int.tryParse(s) ?? 0).toList();

      // Đảm bảo cả 2 có cùng độ dài (3 số)
      while (latestParts.length < 3) {
        latestParts.add(0);
      }
      while (currentParts.length < 3) {
        currentParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      debugPrint('Version compare error: $e');
      return false;
    }
  }

  /// Tải và cài đặt APK (Android only)
  Future<bool> downloadAndInstall() async {
    if (!Platform.isAndroid || downloadUrl.value.isEmpty) {
      debugPrint('Cannot install: not Android or no download URL');
      return false;
    }

    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;

      // Lấy thư mục tải xuống
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        debugPrint('Cannot get external storage directory');
        return false;
      }

      final filePath = '${dir.path}/tvu_app_${latestVersion.value}.apk';
      final file = File(filePath);

      // Xóa file cũ nếu có
      if (await file.exists()) {
        await file.delete();
      }

      debugPrint('Downloading APK to: $filePath');
      debugPrint('Download URL: ${downloadUrl.value}');

      // Tải file
      await _dio.download(
        downloadUrl.value,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress.value = received / total;
          }
        },
      );

      debugPrint('Download complete, opening APK...');

      // Mở file APK để cài đặt với MIME type
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );
      
      debugPrint('OpenFilex result: ${result.type} - ${result.message}');
      
      // Trả về true nếu mở thành công (kể cả khi user chưa cài)
      return result.type == ResultType.done || result.type == ResultType.error;
    } catch (e) {
      debugPrint('Download/Install error: $e');
      return false;
    } finally {
      isDownloading.value = false;
    }
  }

  /// Bỏ qua phiên bản này
  void skipThisVersion() {
    hasUpdate.value = false;
  }
}
