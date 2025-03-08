// lib/providers/theme_provider.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  light,
  dark,
  pink,
}

class AppThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color incomeColor;
  final Color expenseColor;
  final Brightness brightness;

  AppThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.incomeColor,
    required this.expenseColor,
    required this.brightness,
  });
}

class ThemeProvider extends ChangeNotifier {
  static const String themePreferenceKey = 'app_theme';
  
  AppTheme _currentTheme = AppTheme.light;

  AppTheme get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  // Theme data maps
  static final Map<AppTheme, AppThemeData> themeData = {
    AppTheme.light: AppThemeData(
      primaryColor: CupertinoColors.activeGreen,
      secondaryColor: CupertinoColors.activeBlue,
      accentColor: CupertinoColors.systemIndigo,
      backgroundColor: CupertinoColors.systemGroupedBackground,
      cardColor: CupertinoColors.white,
      textColor: CupertinoColors.black,
      incomeColor: CupertinoColors.activeGreen,
      expenseColor: CupertinoColors.destructiveRed,
      brightness: Brightness.light,
    ),
    
    AppTheme.dark: AppThemeData(
      primaryColor: Color(0xFF30D158), // Dark mode green
      secondaryColor: Color(0xFF0A84FF), // Dark mode blue
      accentColor: Color(0xFF5E5CE6), // Dark mode indigo
      backgroundColor: Color(0xFF1C1C1E), // Dark background
      cardColor: Color(0xFF2C2C2E), // Dark cards
      textColor: CupertinoColors.white,
      incomeColor: Color(0xFF30D158), // Dark mode green
      expenseColor: Color(0xFFFF453A), // Dark mode red
      brightness: Brightness.dark,
    ),
    
    AppTheme.pink: AppThemeData(
      primaryColor: Color(0xFFFF6B8B), // Pink theme primary
      secondaryColor: Color(0xFFFF9EB1), // Light pink
      accentColor: Color(0xFFFFB5C5), // Lighter pink
      backgroundColor: Color(0xFFFFF0F5), // Light pink background
      cardColor: CupertinoColors.white,
      textColor: Color(0xFF4A4A4A), // Dark gray for contrast
      incomeColor: Color(0xFFFF6B8B), // Income pink
      expenseColor: Color(0xFFFF3B30), // Keep expense as red for clarity
      brightness: Brightness.light,
    ),
  };

  // Get current theme data
  AppThemeData get currentThemeData => themeData[_currentTheme]!;

  // Load theme from shared preferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(themePreferenceKey);
    
    if (themeName != null) {
      try {
        _currentTheme = AppTheme.values.firstWhere(
          (theme) => theme.toString() == themeName,
        );
        notifyListeners();
      } catch (e) {
        // If theme name is invalid, default to light
        _currentTheme = AppTheme.light;
      }
    }
  }

  // Set and save theme
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(themePreferenceKey, theme.toString());
    }
  }

  // Helper method to get readable theme name
  String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light Mode';
      case AppTheme.dark:
        return 'Dark Mode';
      case AppTheme.pink:
        return 'Pink Mode';
      default:
        return 'Unknown';
    }
  }
}