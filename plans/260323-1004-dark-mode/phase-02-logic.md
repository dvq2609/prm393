# Phase 02: Logic & Local Storage
Status: ✅ Complete
Dependencies: Phase 01

## Objective
Viết hàm kết nối với SharePreferences để ghi nhớ trạng thái và buộc App phản ứng với biến đó.

## Implementation Steps
1. [x] Đảm bảo hàm Khởi tạo Của `main.dart` gọi `WidgetsFlutterBinding.ensureInitialized()` trước để Init SharePreferences.
2. [x] Tạo một File Service mới gọi là `theme_manager.dart` (Tuỳ cách App đang xài State để setup). Khai báo các hàm lưu và đọc String biến "dark"/"light".
3. [x] Ở File `main.dart`, Bọc `MaterialApp` lại trong Builder hoặc Provider, gọi biến `themeMode` truyền vào. Truyền `theme: AppTheme.lightTheme` và `darkTheme: AppTheme.darkTheme`.

## Files to Create/Modify
- `lib/main.dart`
- Thêm file quản lý State logic (tuỳ cấu trúc đang có).

---
Next Phase: `/code phase-03`
