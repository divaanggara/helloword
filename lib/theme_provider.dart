import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // Aplikasi ini defaultnya Dark Mode (seperti desain aslinya)
    final isDark = prefs.getBool('isDarkMode') ?? true; 
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    themeModeNotifier.value = newMode;
    await prefs.setBool('isDarkMode', isDark);
  }
}
