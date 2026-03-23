# 📖 Spec Chi Tiết: Tính năng Dark Mode

## 1. Mục tiêu (Executive Summary)
Cung cấp tính năng Giao diện Tối (Dark Mode) / Giao diện Sáng (Light Mode) cho ứng dụng Flutter. Bảo vệ mắt người dùng, tiết kiệm pin cho màn hình OLED, và nâng cấp tính thẩm mỹ chuyên nghiệp cho ứng dụng đồ ăn.

## 2. Trải nghiệm người dùng (User Stories)
- Tôi muốn ứng dụng nhận diện chế độ ban đêm của hệ thống điện thoại và áp dụng theo mặc định.
- Tôi muốn có một nút cài đặt ở phần Tài Khoản (Profile) để khóa hẳn sáng hoặc tối theo sở thích cá nhân.
- Khi tôi tắt app mở lại, tùy chọn này phải đứng yên vị trí cũ (Ghi nhớ lựa chọn).

## 3. Tech Stack & Libs
- **Nền tảng:** Flutter SDK
- **Giao diện:** Thư viện Material `ThemeData` & `ThemeMode` có sẵn với hiệu suất cao.
- **Lưu trữ tĩnh:** Plugin `shared_preferences` (chuyên dùng thay phiên SQL lưu string nhỏ/boolean - Cực kỳ phù hợp).
- **Quản lý biến (State Management):** Dùng ValueNotifier hoặc hệ thống State tự có của app để không bắt ứng dụng Reload chậm chạp mỗi khi chuyển nền.

## 4. Flowchart chuyển màu
1. App khởi động ➔ Đọc `shared_preferences`
2. Nếu "dark" ➔ Áp dụng `ThemeMode.dark` cho Root Widget.
3. Nếu "light" ➔ Áp dụng `ThemeMode.light`.
4. Nếu null ➔ Dùng `ThemeMode.system` (lấy theo điện thoại).

## 5. File thay đổi dự kiến
- `pubspec.yaml`
- `main.dart`
- Thêm file quản lý màu: `lib/theme.dart` (tuỳ ý)
- Chỉnh sủa `lib/pages/profile.dart` (add công tắc)
- Chỉnh sửa nhẹ các file giao diện con khác khi bị vỡ màu do dùng mã màu chết (black/white) thay vì Context Theme.
