import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/reward_code_model.dart';
import '../services/reward_code_service.dart';
import '../widgets/duo_reward_code_success_dialog.dart';

class RewardCodeController extends GetxController {
  final RewardCodeService _service = Get.find<RewardCodeService>();
  
  final codeController = TextEditingController();
  final codeFocusNode = FocusNode();
  
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Getters
  List<ClaimedRewardCode> get claimedHistory => _service.getClaimedHistory();
  bool get hasHistory => claimedHistory.isNotEmpty;

  @override
  void onClose() {
    codeController.dispose();
    codeFocusNode.dispose();
    super.onClose();
  }

  /// Nhập mã thưởng
  Future<void> redeemCode() async {
    final code = codeController.text.trim();
    
    if (code.isEmpty) {
      errorMessage.value = 'Vui lòng nhập mã thưởng';
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final (success, message, reward) = await _service.redeemCode(code);

      if (success && reward != null) {
        // Clear input
        codeController.clear();
        codeFocusNode.unfocus();
        
        // Hiện dialog thành công
        await DuoRewardCodeSuccessDialog.show(reward: reward);
      } else {
        errorMessage.value = message;
      }
    } catch (e) {
      errorMessage.value = 'Có lỗi xảy ra, vui lòng thử lại';
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear error khi user nhập
  void onCodeChanged(String value) {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  /// Format mã (uppercase)
  void formatCode() {
    final text = codeController.text;
    final formatted = text.toUpperCase();
    if (text != formatted) {
      codeController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}
