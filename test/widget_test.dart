import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm/main.dart';

void main() {
  testWidgets('PocketLLM smoke test renders landing screen and navigates to chat', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketLLMApp());

    // Verify Get Started button is present on fullscreen landing page
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Chat Screen is shown - empty state with prompt text
    expect(find.textContaining('What should we focus'), findsOneWidget);

    // Verify model selector is visible
    expect(find.textContaining('PocketLLM'), findsWidgets);

    // Tap the back button to return to the landing page via menu
    // The new layout uses a hamburger menu, so test the empty state
    expect(find.byTooltip('Open menu'), findsOneWidget);
  });
}
