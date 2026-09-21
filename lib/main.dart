import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/landing_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PocketLLMApp());
}

class PocketLLMApp extends StatelessWidget {
  const PocketLLMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'PocketLLM',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const LandingScreen(),
            '/chat': (context) => const ChatScreen(),
          },
        );
      },
    );
  }
}
