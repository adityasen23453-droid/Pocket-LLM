import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm/models/chat_message.dart';
import 'package:pocketllm/widgets/chat_bubble.dart';
import 'package:pocketllm/widgets/chat_input.dart';

void main() {
  group('New UX & RAG Features Tests', () {
    test('TextbookFormattedText.cleanMath parses physics and math formulas correctly', () {
      // 1. Newton's Second Law
      final newton = TextbookFormattedText.cleanMath(r'\[ F = m \times a \]');
      expect(newton, contains('F = m × a'));

      // 2. Kinetic Energy with fraction and superscript
      final ke = TextbookFormattedText.cleanMath(r'\[ KE = \frac{1}{2} m v^2 \]');
      expect(ke, contains('1 / 2'));
      expect(ke, contains('v²'));

      // 3. Greek symbols (lambda, theta, delta)
      final wave = TextbookFormattedText.cleanMath(r'\[ \lambda = \frac{h}{p} \]');
      expect(wave, contains('λ = h / p'));

      // 4. Subscripts
      final initVel = TextbookFormattedText.cleanMath(r'\[ v = v_0 + a t \]');
      expect(initVel, contains('v₀'));
    });

    test('ChatMessage model correctly stores attachedFileName and chunks', () {
      final msg = ChatMessage(
        id: 'test_1',
        text: 'Explain this chapter',
        isUser: true,
        timestamp: DateTime.now(),
        attachedFileName: 'physics_ch3.pdf',
        attachedFileChunks: 12,
      );

      expect(msg.attachedFileName, equals('physics_ch3.pdf'));
      expect(msg.attachedFileChunks, equals(12));
    });

    testWidgets('ChatBubble renders attached file pill in user message', (WidgetTester tester) async {
      final msg = ChatMessage(
        id: 'msg_attach',
        text: 'Summarize the attached notes',
        isUser: true,
        timestamp: DateTime.now(),
        attachedFileName: 'ncert_motion.pdf',
        attachedFileChunks: 8,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(message: msg),
          ),
        ),
      );

      // Verify file pill is rendered
      expect(find.text('ncert_motion.pdf • 8 chunks'), findsOneWidget);
      expect(find.byIcon(Icons.description_rounded), findsOneWidget);
      expect(find.text('Summarize the attached notes'), findsOneWidget);
    });

    testWidgets('ChatInput shows Stop button when isBusy is true', (WidgetTester tester) async {
      bool stopClicked = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: (_) {},
              onStop: () {
                stopClicked = true;
              },
              isBusy: true,
              selectedModel: 'Smart',
            ),
          ),
        ),
      );

      // Verify Stop Generating button is shown
      expect(find.byTooltip('Stop response'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);

      // Tap stop button
      await tester.tap(find.byTooltip('Stop response'));
      await tester.pump();
      expect(stopClicked, isTrue);
    });

    testWidgets('ChatInput shows staged file preview pill before sending', (WidgetTester tester) async {
      bool fileRemoved = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: (_) {},
              isBusy: false,
              selectedModel: 'Smart',
              stagedFileName: 'chemistry_lab.pdf',
              stagedFileChunks: 5,
              onRemoveStagedFile: () {
                fileRemoved = true;
              },
            ),
          ),
        ),
      );

      // Verify staged file preview
      expect(find.text('chemistry_lab.pdf • 5 chunks ready'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap remove button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(fileRemoved, isTrue);
    });
  });
}

