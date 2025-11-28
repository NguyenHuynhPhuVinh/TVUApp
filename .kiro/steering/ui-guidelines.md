# UI Development Guidelines

## QUAN TRỌNG - ĐỌC TRƯỚC KHI LÀM BẤT KỲ UI NÀO

### 1. BẮT BUỘC SỬ DỤNG THEME

**LUÔN LUÔN** sử dụng `AppColors` và `AppStyles` cho mọi UI:

```dart
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
```

- **Màu sắc**: Dùng `AppColors.primary`, `AppColors.textPrimary`, v.v. - KHÔNG dùng `Colors.blue` trực tiếp
- **Spacing**: Dùng `AppStyles.space1` đến `AppStyles.space8` - KHÔNG dùng số cứng như `16.0`
- **Typography**: Dùng `AppStyles.textSm`, `AppStyles.fontBold`, v.v.
- **Border radius**: Dùng `AppStyles.roundedSm`, `AppStyles.roundedLg`, v.v.

### 2. ƯU TIÊN SỬ DỤNG WIDGET CÓ SẴN

**TRƯỚC KHI TẠO MỚI**, kiểm tra widgets có sẵn trong `lib/app/core/widgets/`:

```dart
import '../../../core/widgets/widgets.dart';
```

**Cấu trúc widgets:**
- `base/` - DuoButton, DuoCard, DuoAvatar
- `feedback/` - DuoAlert, DuoBadge, DuoProgress, DuoEmptyState, DuoFeedbackMessage
- `navigation/` - DuoAppBar, DuoNavBar, DuoIconButton
- `form/` - DuoInput, DuoDropdown, DuoChipSelector, DuoNumberInput
- `display/` - DuoListTile, DuoStatCard, DuoProfileCard, DuoMessageCard, DuoMiniStat, TVUMascot
- `game/` - DuoCurrencyCard, DuoLevelBadge, DuoLevelProgressCard, DuoRewardRow, DuoXpProgress, DuoGameStatsBar, DuoAttendanceCard, DuoAttendanceRateCard

### 3. TUYỆT ĐỐI KHÔNG TẠO WIDGET TRONG VIEW

❌ **SAI:**
```dart
class MyView extends StatelessWidget {
  Widget _buildCustomCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(...),
      child: ...
    );
  }
}
```

✅ **ĐÚNG:**
1. Tạo widget riêng trong `lib/app/core/widgets/[category]/`
2. Export trong `widgets.dart`
3. Import và sử dụng trong view

```dart
// lib/app/core/widgets/display/duo_custom_card.dart
class DuoCustomCard extends StatelessWidget { ... }

// lib/app/core/widgets/widgets.dart
export 'display/duo_custom_card.dart';

// Trong view
import '../../../core/widgets/widgets.dart';
DuoCustomCard(...)
```

### 4. TIỆN ÍCH LOGIC - SỬ DỤNG CHUNG

**Utilities có sẵn trong `lib/app/core/utils/`:**
- `NumberFormatter` - Format số (compact, currency, percent, parseDouble, parseInt)
- `DateFormatter` - Parse/format ngày (parseVietnamese, toVietnamese, isDateInRange, formatIsoToVietnamese)

**TRƯỚC KHI TẠO UTILITY MỚI:**
1. Kiểm tra `lib/app/core/utils/` xem có sẵn chưa
2. Nếu tạo mới, đặt trong `lib/app/core/utils/`
3. Kiểm tra toàn bộ dự án xem có code trùng lặp không → Refactor

### 5. QUY TRÌNH TẠO WIDGET MỚI

1. **Kiểm tra** widget tương tự đã có chưa
2. **Xác định category** phù hợp (base, feedback, navigation, form, display, game)
3. **Tạo file** trong thư mục category: `lib/app/core/widgets/[category]/duo_[name].dart`
4. **Export** trong `widgets.dart`
5. **Import** và sử dụng

### 6. NAMING CONVENTION

- Widget: `Duo[Name]` (VD: `DuoButton`, `DuoCard`)
- File: `duo_[name].dart` (VD: `duo_button.dart`)
- Màu: `AppColors.[name]` hoặc `AppColors.[name]Soft/Dark/Light`
- Style: `AppStyles.[category][Size/Weight]`

### 7. SỬ DỤNG ASSETS GAME

**LUÔN LUÔN** sử dụng ảnh từ `assets/game/` cho các icon game:

```dart
// Coins
Image.asset('assets/game/currency/coin_golden_coin_1st_64px.png', width: 24.w)

// Diamonds  
Image.asset('assets/game/currency/diamond_blue_diamond_1st_64px.png', width: 24.w)

// XP/Star
Image.asset('assets/game/main/star_golden_star_1st_64px.png', width: 24.w)

// Gift
Image.asset('assets/game/item/gift_red_gift_1st_64px.png', width: 24.w)

// Check/Verify
Image.asset('assets/game/main/verify_verify_1st_64px.png', width: 24.w)

// Calendar
Image.asset('assets/game/item/calendar_calendar_1st_64px.png', width: 24.w)
```

**KHÔNG** dùng emoji hoặc Icon cho các element game (coins, diamonds, XP, rewards...)

### 8. CHECKLIST TRƯỚC KHI COMMIT

- [ ] Tất cả màu sắc dùng `AppColors`
- [ ] Tất cả spacing dùng `AppStyles.space*`
- [ ] Không có widget inline trong view
- [ ] Không có utility function trùng lặp
- [ ] Widget mới đã export trong `widgets.dart`
- [ ] Sử dụng ảnh từ `assets/game/` cho icon game
