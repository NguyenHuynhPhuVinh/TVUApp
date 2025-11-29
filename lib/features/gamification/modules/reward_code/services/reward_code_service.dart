import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/storage/storage_service.dart';
import '../../../../../features/gamification/core/game_service.dart';
import '../../../../../features/auth/data/auth_service.dart';
import '../models/reward_code_model.dart';

/// Service quản lý mã thưởng
/// 
/// Firebase Structure:
/// - reward_codes/{code} - Thông tin mã thưởng
/// - reward_codes_claimed/{mssv}/codes/{code} - Mã đã nhận của user
class RewardCodeService extends GetxService {
  static const String _storageKey = 'reward_code_data';
  static const String _claimedKey = 'claimed_codes';
  
  final StorageService _storage = Get.find<StorageService>();
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String get _mssv => _authService.username.value;
  
  final claimedCodes = <ClaimedRewardCode>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadClaimedCodes();
  }

  /// Load danh sách mã đã nhận từ storage
  void loadClaimedCodes() {
    final data = _storage.getData(StorageKey.notifications);
    if (data != null && data[_storageKey] != null) {
      final codeData = data[_storageKey] as Map<String, dynamic>? ?? {};
      final claimedList = codeData[_claimedKey] as List? ?? [];
      claimedCodes.value = claimedList
          .map((e) => ClaimedRewardCode.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  /// Lưu danh sách mã đã nhận vào storage
  Future<void> _saveClaimedCodes() async {
    final data = _storage.getData(StorageKey.notifications) ?? {};
    data[_storageKey] = {
      _claimedKey: claimedCodes.map((c) => c.toJson()).toList(),
    };
    await _storage.saveData(StorageKey.notifications, data);
  }

  /// Kiểm tra mã đã được nhận chưa (local)
  bool isCodeClaimed(String code) {
    return claimedCodes.any((c) => c.code.toUpperCase() == code.toUpperCase());
  }


  /// Nhập mã thưởng và nhận quà
  /// Returns: (success, message, reward?)
  Future<(bool, String, RewardCodeReward?)> redeemCode(String code) async {
    if (_mssv.isEmpty) {
      return (false, 'Vui lòng đăng nhập để nhập mã', null);
    }

    final normalizedCode = code.trim().toUpperCase();
    
    if (normalizedCode.isEmpty) {
      return (false, 'Vui lòng nhập mã thưởng', null);
    }

    // Kiểm tra đã nhận chưa (local)
    if (isCodeClaimed(normalizedCode)) {
      return (false, 'Bạn đã nhận mã này rồi', null);
    }

    isLoading.value = true;
    
    try {
      // 1. Kiểm tra mã trên Firebase
      final codeDoc = await _firestore
          .collection('reward_codes')
          .doc(normalizedCode)
          .get();

      if (!codeDoc.exists) {
        return (false, 'Mã không tồn tại', null);
      }

      final codeData = codeDoc.data()!;
      final rewardCode = _parseRewardCode(normalizedCode, codeData);

      // 2. Kiểm tra mã còn hiệu lực không
      if (!rewardCode.isActive) {
        return (false, 'Mã đã bị vô hiệu hóa', null);
      }

      if (rewardCode.isExpired) {
        return (false, 'Mã đã hết hạn', null);
      }

      if (rewardCode.maxClaims > 0 && rewardCode.currentClaims >= rewardCode.maxClaims) {
        return (false, 'Mã đã hết lượt sử dụng', null);
      }

      // 3. Kiểm tra user đã nhận chưa (Firebase)
      final claimedDoc = await _firestore
          .collection('reward_codes_claimed')
          .doc(_mssv)
          .collection('codes')
          .doc(normalizedCode)
          .get();

      if (claimedDoc.exists) {
        // Sync lại local
        if (!isCodeClaimed(normalizedCode)) {
          claimedCodes.add(ClaimedRewardCode(
            code: normalizedCode,
            claimedAt: DateTime.now(),
            reward: rewardCode.reward,
          ));
          await _saveClaimedCodes();
        }
        return (false, 'Bạn đã nhận mã này rồi', null);
      }

      // 4. Thực hiện nhận mã (transaction)
      await _firestore.runTransaction((transaction) async {
        // Đánh dấu user đã nhận
        final claimedRef = _firestore
            .collection('reward_codes_claimed')
            .doc(_mssv)
            .collection('codes')
            .doc(normalizedCode);
        
        transaction.set(claimedRef, {
          'claimed_at': FieldValue.serverTimestamp(),
          'reward': rewardCode.reward.toJson(),
        });

        // Tăng số lượt đã nhận
        final codeRef = _firestore.collection('reward_codes').doc(normalizedCode);
        transaction.update(codeRef, {
          'current_claims': FieldValue.increment(1),
        });
      });

      // 5. Cộng phần thưởng vào game
      final reward = rewardCode.reward;
      await _gameService.addCoins(reward.coins, _mssv);
      await _gameService.addDiamonds(reward.diamonds, _mssv);
      await _gameService.addXp(reward.xp, _mssv);

      // 6. Lưu local
      claimedCodes.add(ClaimedRewardCode(
        code: normalizedCode,
        claimedAt: DateTime.now(),
        reward: reward,
      ));
      await _saveClaimedCodes();

      debugPrint('[RewardCode] Successfully redeemed code: $normalizedCode');
      return (true, 'Nhận mã thành công!', reward);

    } catch (e) {
      debugPrint('[RewardCode] Error redeeming code: $e');
      return (false, 'Có lỗi xảy ra, vui lòng thử lại', null);
    } finally {
      isLoading.value = false;
    }
  }

  /// Parse reward code từ Firebase document
  RewardCode _parseRewardCode(String code, Map<String, dynamic> data) {
    // Parse created_at
    DateTime createdAt;
    if (data['created_at'] is Timestamp) {
      createdAt = (data['created_at'] as Timestamp).toDate();
    } else if (data['created_at'] is String) {
      createdAt = DateTime.tryParse(data['created_at']) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    // Parse expires_at
    DateTime? expiresAt;
    if (data['expires_at'] != null) {
      if (data['expires_at'] is Timestamp) {
        expiresAt = (data['expires_at'] as Timestamp).toDate();
      } else if (data['expires_at'] is String) {
        expiresAt = DateTime.tryParse(data['expires_at']);
      }
    }

    // Parse reward
    RewardCodeReward reward = const RewardCodeReward();
    if (data['reward'] != null) {
      final r = data['reward'] as Map<String, dynamic>;
      reward = RewardCodeReward(
        coins: (r['coins'] as num?)?.toInt() ?? 0,
        diamonds: (r['diamonds'] as num?)?.toInt() ?? 0,
        xp: (r['xp'] as num?)?.toInt() ?? 0,
      );
    }

    return RewardCode(
      code: code,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      createdAt: createdAt,
      expiresAt: expiresAt,
      reward: reward,
      maxClaims: (data['max_claims'] as num?)?.toInt() ?? 0,
      currentClaims: (data['current_claims'] as num?)?.toInt() ?? 0,
      isActive: data['is_active'] != false,
    );
  }

  /// Lấy lịch sử mã đã nhận
  List<ClaimedRewardCode> getClaimedHistory() {
    return claimedCodes.toList()
      ..sort((a, b) => b.claimedAt.compareTo(a.claimedAt));
  }
}
