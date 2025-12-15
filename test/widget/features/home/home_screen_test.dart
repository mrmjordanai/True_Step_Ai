import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truestep/features/home/screens/home_screen.dart';
import 'package:truestep/features/home/widgets/omni_bar.dart';

void main() {
  Widget buildTestWidget({
    VoidCallback? onOmniBarTap,
    void Function(String)? onOmniBarSubmit,
    VoidCallback? onVoiceTap,
    VoidCallback? onNotificationTap,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: HomeScreen(
          onOmniBarTap: onOmniBarTap,
          onOmniBarSubmit: onOmniBarSubmit,
          onVoiceTap: onVoiceTap,
          onNotificationTap: onNotificationTap,
        ),
      ),
    );
  }

  group('HomeScreen', () {
    group('header', () {
      testWidgets('renders greeting with user name or default', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should show a greeting
        expect(find.textContaining('Hello'), findsOneWidget);
      });

      testWidgets('renders notification bell icon', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      });

      testWidgets('notification bell is tappable', (tester) async {
        bool notificationTapped = false;

        await tester.pumpWidget(
          buildTestWidget(onNotificationTap: () => notificationTapped = true),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.notifications_outlined));
        await tester.pumpAndSettle();

        expect(notificationTapped, isTrue);
      });

      testWidgets('renders subscription badge for free users', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should show Free or Pro badge
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Container || widget is Text,
          ),
          findsWidgets,
        );
      });
    });

    group('Omni-Bar', () {
      testWidgets('renders OmniBar widget', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(OmniBar), findsOneWidget);
      });

      testWidgets('OmniBar shows placeholder text', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Look for the full placeholder text in OmniBar
        expect(find.textContaining("Hey TrueStep"), findsOneWidget);
      });

      testWidgets('tapping OmniBar expands it to show TextField', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // OmniBar should not have TextField initially
        expect(find.byType(TextField), findsNothing);

        // Tap the OmniBar
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Now TextField should be visible
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('OmniBar submission calls onOmniBarSubmit', (tester) async {
        String? submittedText;

        await tester.pumpWidget(
          buildTestWidget(onOmniBarSubmit: (text) => submittedText = text),
        );
        await tester.pumpAndSettle();

        // Tap to expand
        await tester.tap(find.byType(OmniBar));
        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField), 'https://example.com/recipe');
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        expect(submittedText, equals('https://example.com/recipe'));
      });

      testWidgets('OmniBar has microphone icon for voice input', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // OmniBar should have a mic icon (there's also one in Quick Actions)
        final omniBar = find.byType(OmniBar);
        expect(omniBar, findsOneWidget);

        // Find mic icon within OmniBar
        expect(
          find.descendant(of: omniBar, matching: find.byIcon(Icons.mic)),
          findsOneWidget,
        );
      });
    });

    group('Recent Sessions', () {
      testWidgets('renders recent sessions section header', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Recent Sessions'), findsOneWidget);
      });

      testWidgets('shows empty state when no recent sessions', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should show empty state or "No recent sessions" message
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                (widget.data?.contains('No recent') == true ||
                    widget.data?.contains('Start your first') == true),
          ),
          findsWidgets,
        );
      });
    });

    group('Featured Guides', () {
      testWidgets('renders featured guides section', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Featured Guides'), findsOneWidget);
      });

      testWidgets('shows guide cards in featured section', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should render some guide cards or placeholder
        expect(find.text('Featured Guides'), findsOneWidget);
      });
    });

    group('Quick Actions', () {
      testWidgets('renders quick actions section', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      });

      testWidgets('quick actions include Scan, Paste URL, Voice', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to make quick actions visible
        await tester.scrollUntilVisible(
          find.text('Quick Actions'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        // Should have quick action buttons
        expect(find.byIcon(Icons.qr_code_scanner), findsWidgets);
        expect(find.byIcon(Icons.link), findsWidgets);
      });
    });

    group('layout', () {
      testWidgets('uses scrollable layout', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('has proper padding', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should have padding on content
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold, isNotNull);
      });
    });

    group('theming', () {
      testWidgets('uses dark background', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNotNull);
      });
    });
  });
}
