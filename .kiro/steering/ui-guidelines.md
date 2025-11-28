# UI Development Guidelines

## QUY TẮC BẮT BUỘC

### 1. Dùng Theme
- Màu sắc: Dùng `AppColors` - KHÔNG dùng `Colors.xxx` trực tiếp
- Spacing: Dùng `AppStyles.space*` - KHÔNG dùng số cứng
- Border radius: Dùng `AppStyles.rounded*`

### 2. Dùng Widget có sẵn
- Kiểm tra `lib/app/core/widgets/` trước khi tạo mới
- Import từ `widgets.dart`

### 3. KHÔNG tạo widget inline trong View
- Tạo widget riêng trong `lib/app/core/widgets/[category]/`
- Export trong `widgets.dart`

### 4. Naming
- Widget: `Duo[Name]`
- File: `duo_[name].dart`

### 5. Utilities
- Dùng utilities có sẵn trong `lib/app/core/utils/`

---

## GAME UI

### Icon game - BẮT BUỘC dùng ảnh từ assets
- Coins, diamonds, XP, rewards... phải dùng ảnh từ `assets/game/`
- KHÔNG dùng emoji hoặc Icon widget

### UI phải đủ trạng thái
Mọi UI liên quan đến game action phải có đủ các trạng thái:
- **Loading** - Đang xử lý
- **Success** - Thành công
- **Error** - Thất bại / bị block
- **Disabled** - Không thể thực hiện (VD: chưa đủ điều kiện)
- **Already done** - Đã thực hiện rồi (VD: đã tính, đã nhận)
- **Waiting** - Đang chờ (VD: countdown timer)

### Hiển thị rewards
- Luôn hiển thị preview rewards trước khi user thực hiện action
- Hiển thị animation/dialog khi nhận rewards thành công
