# Game System Rules

## QUAN TRỌNG - QUY TẮC BẮT BUỘC CHO MỌI HOẠT ĐỘNG GAME

### 3 BƯỚC BẮT BUỘC CHO MỌI HOẠT ĐỘNG GAME

Mọi hoạt động liên quan đến hệ thống game (coins, diamonds, XP, level, attendance, rewards...) **PHẢI** thực hiện đủ 3 bước theo thứ tự:

#### 1. SECURITY CHECK
```dart
// Kiểm tra bảo mật trước khi cho phép thao tác
if (!isSecure.value) {
  await _checkSecurity();
  if (!isSecure.value) {
    debugPrint('⚠️ Action blocked: Security issues detected');
    return null; // Từ chối thao tác
  }
}
```

#### 2. LƯU LOCAL
```dart
// Cập nhật stats và lưu vào SharedPreferences
stats.value = stats.value.copyWith(...);
await _saveLocalStats();
```

#### 3. SYNC FIREBASE
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
Future<Map<String, dynamic>?> gameAction({
  required String mssv,
  // ... other params
}) async {
  // 1. SECURITY CHECK
  if (!isSecure.value) {
    await _checkSecurity();
    if (!isSecure.value) {
      debugPrint('⚠️ Action blocked: Security issues detected');
      return null;
    }
  }
  
  // 2. Thực hiện logic và cập nhật stats
  stats.value = stats.value.copyWith(
    // ... update values
  );
  
  // 3. LƯU LOCAL
  await _saveLocalStats();
  
  // 4. SYNC FIREBASE (với signed data)
  await syncToFirebase(mssv);
  
  return {
    // ... return results
  };
}
```

### LƯU Ý

- **KHÔNG BAO GIỜ** bỏ qua security check cho các hoạt động nhận thưởng
- **KHÔNG BAO GIỜ** chỉ lưu local mà không sync Firebase
- **KHÔNG BAO GIỜ** sync Firebase mà không có signed data (checksum)
- Nếu security check fail → return null và hiển thị thông báo lỗi cho user
- `syncToFirebase` đã tự động sign data với checksum và device fingerprint

### FILES LIÊN QUAN

- `lib/app/data/services/game_service.dart` - Service chính quản lý game
- `lib/app/data/services/security_service.dart` - Service kiểm tra bảo mật
- `lib/app/data/models/player_stats.dart` - Model lưu trữ stats
