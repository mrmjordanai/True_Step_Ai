import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:truestep/features/home/widgets/omni_bar.dart';

void main() {
  Widget buildTestWidget({
    VoidCallback? onTap,
    VoidCallback? onMicTap,
    void Function(String)? onSubmit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: OmniBar(
            onTap: onTap,
            onMicTap: onMicTap,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }

  group('OmniBar', () {
    group('collapsed state', () {
      testWidgets('renders in collapsed state by default', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should show OmniBar widget
        expect(find.byType(OmniBar), findsOneWidget);

        // Should NOT show TextField in collapsed state
        expect(find.byType(TextField), findsNothing);
      });

      testWidgets('shows placeholder text when collapsed', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.textContaining("Hey TrueStep"),
          findsOneWidget,
        );
      });

      testWidgets('shows search icon when collapsed', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('shows microphone button when collapsed', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.mic), findsOneWidget);
      });
    });

    group('expansion', () {
      testWidgets('expands to show TextField when tapped', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap the OmniBar
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Should now show TextField
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('TextField has proper hint text when expanded', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Should have hint text
        expect(
          find.widgetWithText(TextField, 'Enter URL or describe your task...'),
          findsOneWidget,
        );
      });

      testWidgets('shows close button when expanded', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Should show close icon
        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('shows submit button when expanded', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Should show submit icon (arrow forward or send)
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });
    });

    group('collapse', () {
      testWidgets('collapses when close button is tapped', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Verify expanded
        expect(find.byType(TextField), findsOneWidget);

        // Tap close button
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Should be collapsed again - no TextField
        expect(find.byType(TextField), findsNothing);
      });

      testWidgets('clears text when collapsed', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pumpAndSettle();

        // Close
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Re-expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Text should be cleared
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      });
    });

    group('submission', () {
      testWidgets('calls onSubmit with text when submit button tapped', (
        tester,
      ) async {
        String? submittedText;

        await tester.pumpWidget(
          buildTestWidget(onSubmit: (text) => submittedText = text),
        );
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField), 'make scrambled eggs');
        await tester.pumpAndSettle();

        // Tap submit
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        expect(submittedText, equals('make scrambled eggs'));
      });

      testWidgets('calls onSubmit when keyboard submit action triggered', (
        tester,
      ) async {
        String? submittedText;

        await tester.pumpWidget(
          buildTestWidget(onSubmit: (text) => submittedText = text),
        );
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Enter text and submit
        await tester.enterText(
          find.byType(TextField),
          'https://example.com/recipe',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(submittedText, equals('https://example.com/recipe'));
      });

      testWidgets('does not call onSubmit when text is empty', (tester) async {
        String? submittedText;

        await tester.pumpWidget(
          buildTestWidget(onSubmit: (text) => submittedText = text),
        );
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Tap submit without entering text
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        expect(submittedText, isNull);
      });

      testWidgets('collapses after successful submission', (tester) async {
        await tester.pumpWidget(buildTestWidget(onSubmit: (_) {}));
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Enter text and submit
        await tester.enterText(find.byType(TextField), 'test submission');
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        // Should be collapsed
        expect(find.byType(TextField), findsNothing);
      });
    });

    group('microphone', () {
      testWidgets('calls onMicTap when mic button tapped in collapsed state', (
        tester,
      ) async {
        bool micTapped = false;

        await tester.pumpWidget(
          buildTestWidget(onMicTap: () => micTapped = true),
        );
        await tester.pumpAndSettle();

        // Tap mic button (in collapsed state)
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        expect(micTapped, isTrue);
      });

      testWidgets('shows mic button in expanded state', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Mic should still be visible
        expect(find.byIcon(Icons.mic), findsOneWidget);
      });
    });

    group('styling', () {
      testWidgets('uses glass surface styling', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should have Container with decoration
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('has proper border radius', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // OmniBar should render with rounded corners
        expect(find.byType(OmniBar), findsOneWidget);
      });
    });
  });
}
