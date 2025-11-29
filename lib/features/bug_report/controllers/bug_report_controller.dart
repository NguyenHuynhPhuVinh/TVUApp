import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/storage/storage_service.dart';
import '../models/bug_report_model.dart';
import '../services/bug_report_service.dart';

class BugReportController extends GetxController {
  final _bugReportService = Get.find<BugReportService>();
  final _storageService = Get.find<StorageService>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final selectedCategory = Rxn<BugCategory>();
  final isSubmitting = false.obs;
  final myReports = <BugReportModel>[].obs;
  final isLoadingReports = false.obs;

  // Validation errors
  final titleError = Rxn<String>();
  final descriptionError = Rxn<String>();
  final categoryError = Rxn<String>();

  String? get deviceInfo => _bugReportService.deviceInfo;
  String? get appVersion => _bugReportService.appVersion;

  @override
  void onInit() {
    super.onInit();
    loadMyReports();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void selectCategory(BugCategory category) {
    selectedCategory.value = category;
    categoryError.value = null;
  }

  bool _validate() {
    bool isValid = true;

    if (titleController.text.trim().isEmpty) {
      titleError.value = 'Vui lòng nhập tiêu đề';
      isValid = false;
    } else if (titleController.text.trim().length < 5) {
      titleError.value = 'Tiêu đề quá ngắn (tối thiểu 5 ký tự)';
      isValid = false;
    } else {
      titleError.value = null;
    }

    if (descriptionController.text.trim().isEmpty) {
      descriptionError.value = 'Vui lòng mô tả chi tiết lỗi';
      isValid = false;
    } else if (descriptionController.text.trim().length < 20) {
      descriptionError.value = 'Mô tả quá ngắn (tối thiểu 20 ký tự)';
      isValid = false;
    } else {
      descriptionError.value = null;
    }

    if (selectedCategory.value == null) {
      categoryError.value = 'Vui lòng chọn loại lỗi';
      isValid = false;
    } else {
      categoryError.value = null;
    }

    return isValid;
  }

  Future<void> submitReport() async {
    if (!_validate()) return;

    isSubmitting.value = true;

    try {
      final mssv = _getMssv();
      
      final report = BugReportModel(
        mssv: mssv,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory.value!.name,
      );

      final success = await _bugReportService.submitReport(report);

      if (success) {
        _clearForm();
        await loadMyReports();
        Get.snackbar(
          'Thành công',
          'Cảm ơn bạn đã báo cáo lỗi! Chúng tôi sẽ xem xét sớm nhất.',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể gửi báo cáo. Vui lòng thử lại sau.',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    selectedCategory.value = null;
    titleError.value = null;
    descriptionError.value = null;
    categoryError.value = null;
  }

  Future<void> loadMyReports() async {
    isLoadingReports.value = true;
    try {
      final mssv = _getMssv();
      if (mssv.isNotEmpty) {
        myReports.value = await _bugReportService.getMyReports(mssv);
      }
    } finally {
      isLoadingReports.value = false;
    }
  }

  String _getMssv() {
    final info = _storageService.getStudentInfo();
    if (info != null && info['data'] != null) {
      // Thử cả 2 key: ma_sv và mssv
      final data = info['data'] as Map<String, dynamic>;
      return data['ma_sv']?.toString() ?? 
             data['mssv']?.toString() ?? '';
    }
    return '';
  }
}
