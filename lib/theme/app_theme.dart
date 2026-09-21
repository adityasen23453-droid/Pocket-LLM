import 'package:flutter/material.dart';

class AppTheme {
  // PocketLLM-style Dark Theme (Primary - OLED Black + Deep Blue ambient)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8AB4F8), // PocketLLM blue accent
        onPrimary: Color(0xFF000000),
        surface: Color(0xFF0D0E11),
        onSurface: Color(0xFFE3E3E8),
        secondary: Color(0xFFAECBFA),
        onSecondary: Color(0xFF000000),
        surfaceContainerHighest: Color(0xFF1E1F24),
        outline: Color(0xFF2C2D33),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE3E3E8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFE3E3E8),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E1F24),
        thickness: 0.5,
        space: 0.5,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1F24),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFFE3E3E8),
          fontWeight: FontWeight.w400,
          fontSize: 28,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFE3E3E8),
          fontWeight: FontWeight.w400,
          fontSize: 24,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFE3E3E8),
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFE3E3E8),
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFBBBBC3),
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF8E8E98),
          fontSize: 12,
        ),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A73E8),
        onPrimary: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1F1F1F),
        secondary: Color(0xFF444746),
        onSecondary: Color(0xFFFFFFFF),
        surfaceContainerHighest: Color(0xFFF0F4F9),
        outline: Color(0xFFDADCE0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1F1F1F),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1F1F1F),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFDADCE0),
        thickness: 0.5,
        space: 0.5,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFF0F4F9),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF1F1F1F),
          fontWeight: FontWeight.w400,
          fontSize: 28,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF1F1F1F),
          fontWeight: FontWeight.w400,
          fontSize: 24,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF1F1F1F),
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF1F1F1F),
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF444746),
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF70757A),
          fontSize: 12,
        ),
      ),
    );
  }
}

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.value = ThemeMode.dark]);

  bool get isDarkMode => value == ThemeMode.dark;

  void toggleTheme() {
    value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeController = ThemeController(ThemeMode.dark);
