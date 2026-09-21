import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm/main.dart';

void main() {
  testWidgets('PocketLLM smoke test renders landing screen and navigates to chat and back', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketLLMApp());

    // Verify Get Started button is present on fullscreen landing page
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Chat Screen is shown
    expect(find.text('Welcome to PocketLLM'), findsWidgets);
    expect(find.text('CHAT HISTORY'), findsWidgets);

    // Tap the back button to return to the landing page
    final backButton = find.byTooltip('Back to Landing Page');
    expect(backButton, findsWidgets);
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();

    // Verify we are back on the landing screen
    expect(find.text('Get Started'), findsOneWidget);
  });
}
