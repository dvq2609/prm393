import 'package:flutter/material.dart';

class AppTheme {
  // Giao diện Sáng (Mặc định)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black, // Chữ đen trên nền trắng
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Giao diện Tối (Dark Mode)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark, // Bắt buộc để nó sinh ra bảng màu dark
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212), // Chuẩn màu nền Dark Mode
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white, // Chữ trắng trên nền xám đậm
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1F1F1F),
      selectedItemColor: Colors.deepPurpleAccent,
      unselectedItemColor: Colors.grey,
    ),
  );
}
