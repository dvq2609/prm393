# Phase 03: UI Integration
Status: ✅ Complete
Dependencies: Phase 02

## Objective
Gắn công tắc vật lý lên màn hình, và đi "lau dọn" các màn hình đang bị hardcode màu.

## Implementation Steps
1. [x] Mở page `lib/pages/profile.dart` (Trang thông tin tài khoản), thêm dòng tùy chọn (Ví dụ: `SwitchListTile` hoặc `Row` chứa Text và `Switch` Icon mặt trăng).
2. [x] Khi Gạt công tắc, kích hoạt hàm Update thay đổi State Mode. App sẽ lập tức nháy đổi màu.
3. [x] Kiểm tra nhanh `login.dart`, `home.dart`, `details.dart` (Những file này hay xài màu tĩnh lắm). Chuyển về gọi `Theme.of(context)` để nếu nền đen thì chữ không bị hoà vào nền vô hình.
4. [x] Đặc biệt xử lý `bottom_nav.dart` vì phần này dễ lỗi nền thanh công cụ nhất.

## Files to Modify
- `lib/pages/profile.dart`
- Các trang Widget phụ như `login.dart`, `home.dart` ...

---
Next Phase: `/code phase-04`
