import 'package:flutter/material.dart';

class AppTheme {
  // Warm Editorial Cream & Forest Emerald Theme (Matching Starting Landing Page)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F4EE), // Warm Editorial Cream
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF172C1E), // Deep Forest Emerald
        onPrimary: Colors.white,
        surface: Color(0xFFFAF7F0), // Frosted Travertine White
        onSurface: Color(0xFF14261A), // Deep Forest Charcoal
        secondary: Color(0xFF2D4D36),
        onSecondary: Colors.white,
        surfaceContainerHighest: Color(0xFFEDE8DC),
        outline: Color(0x38DFCDBC),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF14261A),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF14261A),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x35DFCDBC),
        thickness: 0.8,
        space: 0.8,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFAF7F0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x35DFCDBC), width: 0.8),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF14261A),
          fontWeight: FontWeight.w800,
          fontSize: 30,
          letterSpacing: -0.6,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF14261A),
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: -0.4,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF14261A),
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF14261A),
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: -0.1,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF14261A),
          fontSize: 15,
          height: 1.5,
          letterSpacing: -0.15,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF424742),
          fontSize: 13.5,
          height: 1.45,
          letterSpacing: -0.1,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF6E736E),
          fontSize: 12,
          height: 1.35,
        ),
        labelLarge: TextStyle(
          color: Color(0xFF14261A),
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          letterSpacing: -0.1,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF5A605A),
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF6E736E),
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // Deep Obsidian Slate & Luminous Emerald Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF101211), // Deep Forest Obsidian
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8BB596), // Luminous Mint Sage
        onPrimary: Color(0xFF101211),
        surface: Color(0xFF181B19), // Deep Forest Card
        onSurface: Color(0xFFF7F4EE), // Warm Alabaster White
        secondary: Color(0xFFA6D4B0),
        onSecondary: Colors.black,
        surfaceContainerHighest: Color(0xFF222624),
        outline: Color(0x33FFFFFF),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF7F4EE),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFF7F4EE),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x20FFFFFF),
        thickness: 0.8,
        space: 0.8,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF181B19),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x24FFFFFF), width: 0.8),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFFF7F4EE),
          fontWeight: FontWeight.w800,
          fontSize: 30,
          letterSpacing: -0.6,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFF7F4EE),
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: -0.4,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFF7F4EE),
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFF7F4EE),
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: -0.1,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFF7F4EE),
          fontSize: 15,
          height: 1.5,
          letterSpacing: -0.15,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFACAFAB),
          fontSize: 13.5,
          height: 1.45,
          letterSpacing: -0.1,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF8E928E),
          fontSize: 12,
          height: 1.35,
        ),
        labelLarge: TextStyle(
          color: Color(0xFFF7F4EE),
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          letterSpacing: -0.1,
        ),
        labelMedium: TextStyle(
          color: Color(0xFFACAFAB),
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF8E928E),
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.value = ThemeMode.light]);

  bool get isDarkMode => value == ThemeMode.dark;

  void toggleTheme() {
    value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    value = mode;
  }
}

final themeController = ThemeController(ThemeMode.light);

