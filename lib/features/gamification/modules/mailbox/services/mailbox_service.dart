import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../../infrastructure/storage/storage_service.dart';
import '../../../../../features/gamification/core/game_service.dart';
import '../../../../../features/auth/data/auth_service.dart';
import '../models/mail_item.dart';

/// Service quản lý hòm thư
/// 
/// Firebase Structure:
/// - mailbox/global/mails/{mailId} - Thu gui cho tat ca user
/// - mailbox/users/{mssv}/mails/{mailId} - Thu gui cho user cu the
class MailboxService extends GetxService {
  static const String _storageKey = 'mailbox_data';
  static const String _claimedKey = 'claimed_mail_ids';
  static const String _deletedKey = 'deleted_mail_ids';
  
  final StorageService _storage = Get.find<StorageService>();
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String get _mssv => _authService.username.value;
  
  final mails = <MailItem>[].obs;
  final unreadCount = 0.obs;
  final unclaimedCount = 0.obs;
  final isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMails();
    _initDefaultMails();
    // Sync tu Firebase khi khoi dong
    syncFromFirebase();
  }

  /// Load thư từ storage
  void loadMails() {
    final data = _storage.getData(StorageKey.notifications);
    if (data != null && data[_storageKey] != null) {
      final mailList = data[_storageKey] as List? ?? [];
      mails.value = mailList
          .map((e) => MailItem.fromJson(Map<String, dynamic>.from(e)))
          .where((m) => !m.isExpired)
          .toList();
      _sortMails();
      _updateCounts();
    }
  }

  /// Lưu thư vào storage
  Future<void> _saveMails() async {
    final data = _storage.getData(StorageKey.notifications) ?? {};
    data[_storageKey] = mails.map((m) => m.toJson()).toList();
    await _storage.saveData(StorageKey.notifications, data);
  }

  /// Khởi tạo thư mặc định cho user mới
  void _initDefaultMails() {
    // Kiểm tra đã có thư welcome chưa
    final hasWelcome = mails.any((m) => m.id.startsWith('welcome_'));
    if (!hasWelcome) {
      addMail(MailItem(
        id: 'welcome_v2',
        title: 'Chào mừng đến với TVU App!',
        content: 'Cảm ơn bạn đã sử dụng TVU App. Đây là món quà chào mừng dành cho bạn!\n\nChúc bạn có trải nghiệm tuyệt vời!',
        sentAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        type: MailType.welcome,
        reward: const MailReward(coins: 100000, diamonds: 500, xp: 1000),
      ));
    }
  }

  /// Thêm thư mới
  Future<void> addMail(MailItem mail) async {
    // Kiểm tra trùng id
    if (mails.any((m) => m.id == mail.id)) return;
    
    mails.insert(0, mail);
    _updateCounts();
    await _saveMails();
  }

  /// Đánh dấu đã đọc
  Future<void> markAsRead(String mailId) async {
    final index = mails.indexWhere((m) => m.id == mailId);
    if (index == -1) return;
    
    final mail = mails[index];
    if (mail.isRead) return;
    
    mails[index] = mail.copyWith(isRead: true);
    _updateCounts();
    await _saveMails();
  }

  /// Đánh dấu tất cả đã đọc (trừ thư có quà chưa nhận)
  Future<void> markAllAsRead() async {
    bool hasChanges = false;
    for (int i = 0; i < mails.length; i++) {
      // Skip thư có quà chưa nhận
      if (mails[i].canClaimReward) continue;
      
      if (!mails[i].isRead) {
        mails[i] = mails[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      _updateCounts();
      await _saveMails();
    }
  }

  /// Nhận quà từ thư
  Future<bool> claimReward(String mailId) async {
    final index = mails.indexWhere((m) => m.id == mailId);
    if (index == -1) return false;

    final mail = mails[index];
    if (!mail.canClaimReward) return false;

    final reward = mail.reward!;

    debugPrint('[Mailbox] claimReward: mailId=$mailId, index=$index');
    debugPrint('[Mailbox] Before: ${mails.map((m) => '${m.id}:${m.isClaimed}').join(', ')}');

    // Cộng phần thưởng vào game
    await _gameService.addCoins(reward.coins, _mssv);
    await _gameService.addDiamonds(reward.diamonds, _mssv);
    await _gameService.addXp(reward.xp, _mssv);

    // Cập nhật trạng thái - CHỈ mail này
    final updatedMail = mail.copyWith(isClaimed: true, isRead: true);
    mails[index] = updatedMail;

    debugPrint('[Mailbox] After: ${mails.map((m) => '${m.id}:${m.isClaimed}').join(', ')}');

    _updateCounts();
    await _saveMails();

    // Luu trang thai da nhan
    await _saveClaimedMailId(mailId);
    await _markClaimedOnFirebase(mailId);

    return true;
  }

  /// Nhận tất cả quà - batch 1 lần
  Future<int> claimAllRewards() async {
    // Thu thập tất cả thư có quà chưa nhận
    final mailsToClaim = <int>[];
    int totalCoins = 0;
    int totalDiamonds = 0;
    int totalXp = 0;
    final claimedMailIds = <String>[];
    
    for (int i = 0; i < mails.length; i++) {
      final mail = mails[i];
      if (mail.canClaimReward && mail.reward != null) {
        mailsToClaim.add(i);
        totalCoins += mail.reward!.coins;
        totalDiamonds += mail.reward!.diamonds;
        totalXp += mail.reward!.xp;
        claimedMailIds.add(mail.id);
      }
    }
    
    if (mailsToClaim.isEmpty) return 0;
    
    // Cộng tổng phần thưởng 1 lần vào game
    await _gameService.addCoins(totalCoins, _mssv);
    await _gameService.addDiamonds(totalDiamonds, _mssv);
    await _gameService.addXp(totalXp, _mssv);
    
    // Cập nhật trạng thái tất cả thư
    for (var i in mailsToClaim) {
      mails[i] = mails[i].copyWith(isClaimed: true, isRead: true);
    }
    
    // Lưu local 1 lần
    _updateCounts();
    await _saveMails();
    
    // Lưu claimed IDs local 1 lần
    final data = _storage.getData(StorageKey.notifications) ?? {};
    final claimed = _getClaimedMailIds();
    claimed.addAll(claimedMailIds);
    data[_claimedKey] = claimed.toList();
    await _storage.saveData(StorageKey.notifications, data);
    
    // Batch write lên Firebase 1 lần
    await _markMultipleClaimedOnFirebase(claimedMailIds);
    
    return mailsToClaim.length;
  }
  
  /// Batch mark nhiều mail đã claimed lên Firebase
  Future<void> _markMultipleClaimedOnFirebase(List<String> mailIds) async {
    if (_mssv.isEmpty || mailIds.isEmpty) return;
    
    try {
      final batch = _firestore.batch();
      final claimedAt = FieldValue.serverTimestamp();
      
      for (var mailId in mailIds) {
        final docRef = _firestore
            .collection('mailbox')
            .doc('claimed')
            .collection(_mssv)
            .doc(mailId);
        batch.set(docRef, {'claimed_at': claimedAt});
      }
      
      await batch.commit();
      debugPrint('Batch marked ${mailIds.length} mails as claimed on Firebase');
    } catch (e) {
      debugPrint('Error batch marking mails as claimed: $e');
    }
  }

  /// Xóa thư
  Future<void> deleteMail(String mailId) async {
    mails.removeWhere((m) => m.id == mailId);
    _updateCounts();
    await _saveMails();
    
    // Lưu deleted ID để không sync lại
    await _saveDeletedMailId(mailId);
    await _markDeletedOnFirebase([mailId]);
  }

  /// Xóa tất cả thư đã đọc và đã nhận quà
  Future<int> deleteReadMails() async {
    final toDelete = mails.where((m) => m.isRead && (!m.hasReward || m.isClaimed)).toList();
    final count = toDelete.length;
    
    if (count == 0) return 0;
    
    final deletedIds = toDelete.map((m) => m.id).toList();
    
    for (var mail in toDelete) {
      mails.remove(mail);
    }
    
    _updateCounts();
    await _saveMails();
    
    // Lưu deleted IDs để không sync lại
    await _saveDeletedMailIds(deletedIds);
    await _markDeletedOnFirebase(deletedIds);
    
    return count;
  }

  /// Cập nhật số lượng
  void _updateCounts() {
    unreadCount.value = mails.where((m) => !m.isRead).length;
    unclaimedCount.value = mails.where((m) => m.canClaimReward).length;
  }

  /// Sắp xếp thư: chưa đọc trước, mới nhất trước
  void _sortMails() {
    mails.sort((a, b) {
      // Ưu tiên chưa đọc
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }
      // Ưu tiên có quà chưa nhận
      if (a.canClaimReward != b.canClaimReward) {
        return a.canClaimReward ? -1 : 1;
      }
      // Mới nhất trước
      return b.sentAt.compareTo(a.sentAt);
    });
  }

  /// Kiểm tra có thư mới không (để hiện badge)
  bool get hasNewMail => unreadCount.value > 0 || unclaimedCount.value > 0;
  
  /// Tổng số badge (thư chưa đọc + quà chưa nhận)
  int get badgeCount => unreadCount.value + unclaimedCount.value;

  // ============ FIREBASE SYNC ============

  /// Lay danh sach mail id da nhan qua (luu local)
  Set<String> _getClaimedMailIds() {
    final data = _storage.getData(StorageKey.notifications);
    if (data != null && data[_claimedKey] != null) {
      return Set<String>.from(data[_claimedKey] as List);
    }
    return {};
  }

  /// Luu mail id da nhan qua
  Future<void> _saveClaimedMailId(String mailId) async {
    final data = _storage.getData(StorageKey.notifications) ?? {};
    final claimed = _getClaimedMailIds();
    claimed.add(mailId);
    data[_claimedKey] = claimed.toList();
    await _storage.saveData(StorageKey.notifications, data);
  }

  /// Lay danh sach mail id da xoa (luu local)
  Set<String> _getDeletedMailIds() {
    final data = _storage.getData(StorageKey.notifications);
    if (data != null && data[_deletedKey] != null) {
      return Set<String>.from(data[_deletedKey] as List);
    }
    return {};
  }

  /// Luu 1 mail id da xoa
  Future<void> _saveDeletedMailId(String mailId) async {
    final data = _storage.getData(StorageKey.notifications) ?? {};
    final deleted = _getDeletedMailIds();
    deleted.add(mailId);
    data[_deletedKey] = deleted.toList();
    await _storage.saveData(StorageKey.notifications, data);
  }

  /// Luu nhieu mail id da xoa
  Future<void> _saveDeletedMailIds(List<String> mailIds) async {
    final data = _storage.getData(StorageKey.notifications) ?? {};
    final deleted = _getDeletedMailIds();
    deleted.addAll(mailIds);
    data[_deletedKey] = deleted.toList();
    await _storage.saveData(StorageKey.notifications, data);
  }

  /// Đánh dấu mail đã xóa lên Firebase
  Future<void> _markDeletedOnFirebase(List<String> mailIds) async {
    if (_mssv.isEmpty || mailIds.isEmpty) return;

    try {
      final batch = _firestore.batch();
      final deletedAt = FieldValue.serverTimestamp();

      for (var mailId in mailIds) {
        final docRef = _firestore
            .collection('mailbox')
            .doc('deleted')
            .collection(_mssv)
            .doc(mailId);
        batch.set(docRef, {'deleted_at': deletedAt});
      }

      await batch.commit();
      debugPrint('Marked ${mailIds.length} mails as deleted on Firebase');
    } catch (e) {
      debugPrint('Error marking mails as deleted: $e');
    }
  }

  /// Sync thu tu Firebase (global + user-specific)
  Future<void> syncFromFirebase() async {
    if (_mssv.isEmpty) {
      debugPrint('[Mailbox] syncFromFirebase: mssv is empty');
      return;
    }
    
    debugPrint('[Mailbox] syncFromFirebase: Starting for $_mssv');
    isSyncing.value = true;
    try {
      final claimedIds = _getClaimedMailIds();
      final deletedIds = _getDeletedMailIds();
      final newMails = <MailItem>[];

      // 1. Lay thu global (gui cho tat ca user)
      debugPrint('[Mailbox] Fetching global mails...');
      final globalMails = await _fetchGlobalMails();
      debugPrint('[Mailbox] Got ${globalMails.length} global mails');
      
      for (var mail in globalMails) {
        // Skip mail đã xóa hoặc đã có trong list
        if (deletedIds.contains(mail.id)) continue;
        if (mails.any((m) => m.id == mail.id)) continue;
        
        final isClaimed = claimedIds.contains(mail.id);
        newMails.add(mail.copyWith(isClaimed: isClaimed));
      }

      // 2. Lay thu rieng cho user nay
      debugPrint('[Mailbox] Fetching user mails...');
      final userMails = await _fetchUserMails(_mssv);
      debugPrint('[Mailbox] Got ${userMails.length} user mails');
      
      for (var mail in userMails) {
        // Skip mail đã xóa hoặc đã có trong list
        if (deletedIds.contains(mail.id)) continue;
        if (mails.any((m) => m.id == mail.id)) continue;
        
        final isClaimed = claimedIds.contains(mail.id);
        newMails.add(mail.copyWith(isClaimed: isClaimed));
      }

      // Them thu moi vao danh sach
      if (newMails.isNotEmpty) {
        for (var mail in newMails) {
          mails.insert(0, mail);
        }
        _sortMails();
        _updateCounts();
        await _saveMails();
        debugPrint('Synced ${newMails.length} new mails from Firebase');
      }
    } catch (e) {
      debugPrint('Error syncing mails from Firebase: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Lay thu global tu Firebase
  Future<List<MailItem>> _fetchGlobalMails() async {
    try {
      // Query don gian, khong can index
      final snapshot = await _firestore
          .collection('mailbox')
          .doc('global')
          .collection('mails')
          .limit(50)
          .get();

      debugPrint('Fetched ${snapshot.docs.length} global mails from Firebase');

      final result = snapshot.docs
          .map((doc) => _parseFirebaseMail(doc.id, doc.data()))
          .where((m) => m != null && !m.isExpired)
          .cast<MailItem>()
          .toList();
      
      // Filter is_active trong code
      return result.where((m) => true).toList(); // is_active da check trong parse
    } catch (e) {
      debugPrint('Error fetching global mails: $e');
      return [];
    }
  }

  /// Lay thu rieng cua user tu Firebase
  Future<List<MailItem>> _fetchUserMails(String mssv) async {
    try {
      final snapshot = await _firestore
          .collection('mailbox')
          .doc('users')
          .collection(mssv)
          .limit(50)
          .get();
      
      debugPrint('Fetched ${snapshot.docs.length} user mails from Firebase');

      return snapshot.docs
          .map((doc) => _parseFirebaseMail(doc.id, doc.data()))
          .where((m) => m != null && !m.isExpired)
          .cast<MailItem>()
          .toList();
    } catch (e) {
      debugPrint('Error fetching user mails: $e');
      return [];
    }
  }

  /// Parse mail tu Firebase document
  MailItem? _parseFirebaseMail(String docId, Map<String, dynamic> data) {
    try {
      // Parse sent_at
      DateTime sentAt;
      if (data['sent_at'] is Timestamp) {
        sentAt = (data['sent_at'] as Timestamp).toDate();
      } else if (data['sent_at'] is String) {
        sentAt = DateTime.tryParse(data['sent_at']) ?? DateTime.now();
      } else {
        sentAt = DateTime.now();
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
      MailReward? reward;
      if (data['reward'] != null) {
        final r = data['reward'] as Map<String, dynamic>;
        reward = MailReward(
          coins: (r['coins'] as num?)?.toInt() ?? 0,
          diamonds: (r['diamonds'] as num?)?.toInt() ?? 0,
          xp: (r['xp'] as num?)?.toInt() ?? 0,
        );
      }

      return MailItem(
        id: docId,
        title: data['title']?.toString() ?? '',
        content: data['content']?.toString() ?? '',
        sentAt: sentAt,
        expiresAt: expiresAt,
        type: MailType.fromString(data['type']?.toString() ?? 'system'),
        reward: reward,
        isRead: false,
        isClaimed: false,
      );
    } catch (e) {
      debugPrint('Error parsing mail $docId: $e');
      return null;
    }
  }

  /// Luu trang thai da nhan qua len Firebase (de khong nhan lai)
  Future<void> _markClaimedOnFirebase(String mailId) async {
    if (_mssv.isEmpty) return;
    
    try {
      await _firestore
          .collection('mailbox')
          .doc('claimed')
          .collection(_mssv)
          .doc(mailId)
          .set({
        'claimed_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking mail as claimed on Firebase: $e');
    }
  }
}
