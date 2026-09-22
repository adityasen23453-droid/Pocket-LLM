import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm/main.dart';
import 'package:pocketllm/theme/app_theme.dart';

void main() {
  testWidgets('PocketLLM smoke test renders landing screen and navigates to chat', (WidgetTester tester) async {
    themeController.setTheme(ThemeMode.light);
    await tester.pumpWidget(const PocketLLMApp());

    // Verify Get Started button is present on fullscreen landing page
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started
    await tester.tap(find.text('Get Started'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Chat Screen is shown - Student AI assistant empty state
    expect(find.textContaining('How can', findRichText: true), findsOneWidget);
    expect(find.text('Summarize Notes'), findsOneWidget);

    // Verify filter pills are present
    expect(find.text('Docs'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.text('Sheets'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);

    // Verify chat input prompt is visible
    expect(find.text('Ask me anything...'), findsOneWidget);

    // Verify menu button is present
    expect(find.byTooltip('Open menu'), findsOneWidget);

    // Verify Dark Mode Toggle button is present and functional
    expect(find.byTooltip('Switch to Dark Mode'), findsOneWidget);

    // Tap Theme Toggle
    await tester.tap(find.byTooltip('Switch to Dark Mode'));
    await tester.pumpAndSettle();

    // Verify Dark Mode is active
    expect(themeController.isDarkMode, isTrue);
    expect(find.byTooltip('Switch to Light Mode'), findsOneWidget);
  });
}
