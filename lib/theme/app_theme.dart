import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme: White + Black
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF000000),
        onPrimary: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
        secondary: Color(0xFF222222),
        onSecondary: Color(0xFFFFFFFF),
        surfaceContainerHighest: Color(0xFFF3F3F5),
        outline: Color(0xFFE2E2E6),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF000000),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF000000),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEAEAEA),
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFF9F9FB),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF000000),
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF222222),
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF666666),
          fontSize: 12,
        ),
      ),
    );
  }

  // Dark Theme: Charcoal Black + White
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFFFFF),
        onPrimary: Color(0xFF121212),
        surface: Color(0xFF18181B),
        onSurface: Color(0xFFFFFFFF),
        secondary: Color(0xFFDDDDDD),
        onSecondary: Color(0xFF121212),
        surfaceContainerHighest: Color(0xFF232328),
        outline: Color(0xFF2C2C32),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF27272C),
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF28282E)),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFE2E2E6),
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF9E9EA5),
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
