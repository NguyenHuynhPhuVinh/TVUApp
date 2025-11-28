# Game System Rules

## NGUYÊN TẮC CỐT LÕI

> **FIREBASE LÀ SOURCE OF TRUTH - LOCAL CHỈ LÀ CACHE**

## KHI LÀM TÍNH NĂNG GAME MỚI

### 1. Flow 3 bước cho mọi action nhận rewards
- **Bước 1**: Check Firebase trước (ngăn duplicate)
- **Bước 2**: Lưu local (cache)
- **Bước 3**: Sync Firebase (source of truth)

### 2. Validate input
- Không cho số âm
- Giới hạn giá trị hợp lý

### 3. Security checks
- Gọi security check trước khi cho nhận rewards
- Block nếu thiết bị không an toàn (root/jailbreak/emulator)

### 4. Ngăn race condition
- Dùng lock để ngăn double click
- Check lock → add lock → finally remove lock

### 5. Server time validation
- Validate thời gian với Firebase Server cho action time-sensitive
- Block nếu đồng hồ thiết bị sai quá nhiều

### 6. Ngăn duplicate rewards
- Check Firebase trước khi thực hiện action
- Action chỉ được thực hiện 1 lần phải có check đã làm chưa

### 7. Signed data
- Sync lên Firebase với checksum
- Verify checksum khi load từ Firebase

### 8. Sync khi khởi động app
- Sync game stats từ Firebase về local
- Merge data từ Firebase nếu local thiếu
