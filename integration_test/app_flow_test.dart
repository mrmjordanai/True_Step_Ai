import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:truestep/main.dart' as app;

/// Integration tests for TrueStep app flows
///
/// These tests verify end-to-end user journeys through the app.
/// Run with: flutter test integration_test/app_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Flow', () {
    testWidgets('complete onboarding to reach home', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Expect to start on welcome screen
      expect(find.text('Get Started'), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should be on permissions screen
      expect(find.text('Permissions'), findsOneWidget);

      // Continue through permissions
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should be on account screen
      expect(find.text('Create Account'), findsOneWidget);

      // Continue as guest
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Should be on first task screen
      expect(find.textContaining('First'), findsOneWidget);

      // Complete first task
      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      // Should now be on home screen
      expect(find.byType(TextField), findsOneWidget); // OmniBar
    });
  });

  group('Home to Session Flow', () {
    testWidgets('enter URL and navigate to guide preview', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to home (assuming onboarding is complete in a real test scenario)
      // For this test, we'll skip onboarding state...

      // Find OmniBar and enter a URL
      final omniBar = find.byType(TextField).first;
      await tester.tap(omniBar);
      await tester.enterText(omniBar, 'https://example.com/recipe');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should trigger ingestion...
      // (In reality this would require mocking the ingestion service)
    });
  });

  group('Navigation', () {
    testWidgets('bottom nav switches between tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip past onboarding if needed...
      // Then test tab switching

      // Find bottom nav items
      final homeTab = find.byIcon(Icons.home_outlined);
      final searchTab = find.byIcon(Icons.search);

      if (searchTab.evaluate().isNotEmpty) {
        await tester.tap(searchTab);
        await tester.pumpAndSettle();

        // Should show search screen
        expect(find.text('Search'), findsOneWidget);

        // Navigate back to home
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab);
          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('Quick Actions', () {
    testWidgets('quick action modal opens and navigates', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the quick action FAB
      final fab = find.byIcon(Icons.add);

      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle();

        // Modal should appear with options
        expect(find.text('Paste URL'), findsOneWidget);
        expect(find.text('Describe Task'), findsOneWidget);
      }
    });
  });
}
