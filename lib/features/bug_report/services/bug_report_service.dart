import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import '../models/bug_report_model.dart';

/// Service xử lý gửi báo cáo lỗi lên Firebase
class BugReportService extends GetxService {
  late final FirebaseFirestore _firestore;
  
  String? _deviceInfo;
  String? _appVersion;

  Future<BugReportService> init() async {
    _firestore = FirebaseFirestore.instance;
    await _loadDeviceInfo();
    return this;
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        _deviceInfo = '${android.brand} ${android.model} (Android ${android.version.release})';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        _deviceInfo = '${ios.name} ${ios.model} (iOS ${ios.systemVersion})';
      }
    } catch (e) {
      debugPrint('Error loading device info: $e');
    }
  }

  String? get deviceInfo => _deviceInfo;
  String? get appVersion => _appVersion;

  /// Gửi báo cáo lỗi lên Firebase
  Future<bool> submitReport(BugReportModel report) async {
    try {
      debugPrint('BugReport: Submitting report for MSSV: ${report.mssv}');
      
      final reportWithInfo = BugReportModel(
        mssv: report.mssv,
        title: report.title,
        description: report.description,
        category: report.category,
        deviceInfo: _deviceInfo,
        appVersion: _appVersion,
      );

      final docRef = await _firestore.collection('bug_reports').add(reportWithInfo.toJson());
      debugPrint('BugReport: Submitted successfully with ID: ${docRef.id}');
      return true;
    } catch (e) {
      debugPrint('BugReport: Error submitting: $e');
      return false;
    }
  }

  /// Lấy danh sách báo cáo của sinh viên
  Future<List<BugReportModel>> getMyReports(String mssv) async {
    debugPrint('BugReport: Loading reports for MSSV: "$mssv"');
    
    if (mssv.isEmpty) {
      debugPrint('BugReport: MSSV is empty, returning empty list');
      return [];
    }
    
    try {
      final snapshot = await _firestore
          .collection('bug_reports')
          .where('mssv', isEqualTo: mssv)
          .get();

      debugPrint('BugReport: Found ${snapshot.docs.length} reports');

      final reports = snapshot.docs
          .map((doc) => BugReportModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Sort locally
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reports.take(20).toList();
    } catch (e) {
      debugPrint('BugReport: Error getting reports: $e');
      return [];
    }
  }
}
