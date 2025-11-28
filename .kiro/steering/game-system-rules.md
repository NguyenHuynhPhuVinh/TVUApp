# Game System Rules

## QUAN TRỌNG - QUY TẮC BẮT BUỘC CHO MỌI HOẠT ĐỘNG GAME

### NGUYÊN TẮC CỐT LÕI

> **FIREBASE LÀ SOURCE OF TRUTH - LOCAL CHỈ LÀ CACHE**
> 
> Mọi dữ liệu game (stats, check-ins, rewards) phải được verify với Firebase trước khi thực hiện.
> Local storage chỉ dùng để cache, giúp UX nhanh hơn.

### 3 BƯỚC BẮT BUỘC CHO MỌI HOẠT ĐỘNG GAME

Mọi hoạt động liên quan đến hệ thống game (coins, diamonds, XP, level, attendance, rewards, check-in...) **PHẢI** thực hiện đủ 3 bước theo thứ tự:

#### BƯỚC 1: CHECK FIREBASE + SECURITY
```dart
// 1a. Kiểm tra trên Firebase trước (Source of Truth)
// Ngăn chặn hack bằng cách xóa local data
final alreadyExists = await _gameService.hasCheckedInOnFirebase(mssv, key);
if (alreadyExists) {
  return null; // Đã tồn tại trên Firebase
}

// 1b. Kiểm tra bảo mật
if (!isSecure.value) {
  await _checkSecurity();
  if (!isSecure.value) {
    debugPrint('⚠️ Action blocked: Security issues detected');
    return null; // Từ chối thao tác
  }
}
```

#### BƯỚC 2: LƯU LOCAL (Cache)
```dart
// Cập nhật stats và lưu vào SharedPreferences (cache)
stats.value = stats.value.copyWith(...);
await _saveLocalStats();
```

#### BƯỚC 3: SYNC FIREBASE (Source of Truth)
```dart
// Đẩy dữ liệu lên Firebase với signed data (checksum)
await syncToFirebase(mssv);
```

### CÁC HOẠT ĐỘNG CẦN ÁP DỤNG

- ✅ Check-in buổi học (`checkInLesson`)
- ✅ Thêm coins (`addCoins`)
- ✅ Thêm diamonds (`addDiamonds`)
- ✅ Thêm XP (`addXp`)
- ✅ Khởi tạo game (`initializeGame`)
- ✅ Ghi nhận điểm danh (`recordAttendance`)
- ✅ Mua vật phẩm (nếu có)
- ✅ Quay gacha (nếu có)
- ✅ Nhận thưởng daily (nếu có)

### TEMPLATE CODE

```dart
/// Template cho mọi hoạt động game
/// TUÂN THỦ: Check Firebase → Lưu Local → Sync Firebase
Future<Map<String, dynamic>?> gameAction({
  required String mssv,
  required String actionKey, // Key duy nhất cho action
  // ... other params
}) async {
  // ========== BƯỚC 1: CHECK FIREBASE (Source of Truth) ==========
  // Kiểm tra trên Firebase trước - ngăn chặn hack
  final alreadyDone = await hasActionOnFirebase(mssv, actionKey);
  if (alreadyDone) {
    return null; // Đã thực hiện rồi
  }
  
  // Security check
  if (!isSecure.value) {
    await _checkSecurity();
    if (!isSecure.value) {
      debugPrint('⚠️ Action blocked: Security issues detected');
      return null;
    }
  }
  
  // ========== BƯỚC 2: LƯU LOCAL (Cache) ==========
  stats.value = stats.value.copyWith(
    // ... update values
  );
  await _saveLocalStats();
  
  // ========== BƯỚC 3: SYNC FIREBASE (Source of Truth) ==========
  await syncToFirebase(mssv);
  await saveActionToFirebase(mssv, actionKey, actionData);
  
  return {
    // ... return results
  };
}
```

### SYNC KHI KHỞI ĐỘNG APP

Khi app khởi động (splash screen), **BẮT BUỘC** phải:

```dart
// 1. Sync game stats từ Firebase về local
await _gameService.syncFromFirebase(mssv);

// 2. Sync check-ins từ Firebase về local
final firebaseCheckIns = await _gameService.getCheckInsFromFirebase(mssv);
if (firebaseCheckIns.isNotEmpty) {
  await _localStorage.mergeCheckInsFromFirebase(firebaseCheckIns);
}
```

Điều này đảm bảo:
- Nếu user xóa app data → data được restore từ Firebase
- Không thể hack bằng cách clear cache
- Data luôn consistent giữa các thiết bị

### LƯU Ý QUAN TRỌNG

- **KHÔNG BAO GIỜ** chỉ check local mà không check Firebase
- **KHÔNG BAO GIỜ** bỏ qua security check cho các hoạt động nhận thưởng
- **KHÔNG BAO GIỜ** chỉ lưu local mà không sync Firebase
- **KHÔNG BAO GIỜ** sync Firebase mà không có signed data (checksum)
- Nếu security check fail → return null và hiển thị thông báo lỗi cho user
- `syncToFirebase` đã tự động sign data với checksum và device fingerprint
- Local cache chỉ dùng để hiển thị UI nhanh, KHÔNG dùng để verify

### FILES LIÊN QUAN

- `lib/app/data/services/game_service.dart` - Service chính quản lý game
- `lib/app/data/services/security_service.dart` - Service kiểm tra bảo mật
- `lib/app/data/models/player_stats.dart` - Model lưu trữ stats
- `lib/app/modules/schedule/controllers/schedule_controller.dart` - Check-in logic
- `lib/app/modules/splash/controllers/splash_controller.dart` - Sync khi khởi động
