import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static late SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

 
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    
    if (savedTheme == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else {
      themeNotifier.value = ThemeMode.system;
    }
  }

  
  static Future<void> changeTheme(ThemeMode mode) async {
    themeNotifier.value = mode; 
    
    if (mode == ThemeMode.dark) {
      await _prefs.setString(_themeKey, 'dark');
    } else if (mode == ThemeMode.light) {
      await _prefs.setString(_themeKey, 'light');
    } else {
      await _prefs.remove(_themeKey); 
    }
  }
}
