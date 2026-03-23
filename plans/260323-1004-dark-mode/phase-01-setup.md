# Phase 01: Setup Environment & Colors
Status: ✅ Complete

## Objective
Thêm thư viện đọc bộ nhớ tạm. Khai báo 2 Bảng Màu tách biệt (Nền đen - Nền Trắng) cho App.

## Implementation Steps
1. [x] Mở terminal gõ `flutter pub add shared_preferences`.
2. [x] Thêm file `lib/theme.dart` chứa class `AppTheme`.
3. [x] Khai báo `static ThemeData lightTheme` (background trắng, chữ đen, appbar trắng...)
4. [x] Khai báo `static ThemeData darkTheme` (background đen xám đậm `grey[900]` hoặc `black`, chữ trắng...)

## Files to Create/Modify
- `pubspec.yaml` - Register dependency.
- `lib/theme.dart` - Nơi quản lý Data Màu.

---
Next Phase: `/code phase-02`
