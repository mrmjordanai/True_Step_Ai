import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:truestep/features/onboarding/screens/welcome_screen.dart';
import 'package:truestep/features/onboarding/widgets/page_indicator.dart';
import 'package:truestep/features/onboarding/providers/onboarding_provider.dart';
import 'package:truestep/core/models/onboarding_status.dart';
import 'package:truestep/shared/widgets/primary_button.dart';

import '../../../helpers/pump_app.dart';

// Mock Hive Box
class MockBox extends Mock implements Box<OnboardingStatus> {}

void main() {
  late MockBox mockBox;

  setUpAll(() {
    registerFallbackValue(const OnboardingStatus());
  });

  setUp(() {
    mockBox = MockBox();
    when(() => mockBox.get('status')).thenReturn(null);
    when(() => mockBox.put('status', any())).thenAnswer((_) async {});
  });

  Widget buildTestWidget({
    void Function(String)? onNavigate,
  }) {
    return ProviderScope(
      overrides: [
        onboardingBoxProvider.overrideWithValue(mockBox),
      ],
      child: MaterialApp(
        home: WelcomeScreen(
          onGetStarted: () => onNavigate?.call('get_started'),
          onSignIn: () => onNavigate?.call('sign_in'),
          onSkip: () => onNavigate?.call('skip'),
        ),
      ),
    );
  }

  group('WelcomeScreen', () {
    group('rendering', () {
      testWidgets('renders PageView with 3 pages', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(PageView), findsOneWidget);
      });

      testWidgets('renders PageIndicator with 3 dots', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final pageIndicator = tester.widget<PageIndicator>(
          find.byType(PageIndicator),
        );
        expect(pageIndicator.pageCount, equals(3));
      });

      testWidgets('renders Skip button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Skip'), findsOneWidget);
      });

      testWidgets('renders Get Started button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Get Started'), findsOneWidget);
      });

      testWidgets('renders Sign In link', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Already have an account? Sign In'), findsOneWidget);
      });
    });

    group('page content', () {
      testWidgets('first page shows AI Repair Partner content', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Your AI Repair Partner'), findsOneWidget);
        expect(find.text('Never miss a step again'), findsOneWidget);
      });

      testWidgets('second page shows Visual Verification content', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Swipe to second page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        expect(find.text('Visual Verification'), findsOneWidget);
        expect(find.text('AI that actually watches'), findsOneWidget);
      });

      testWidgets('third page shows Mistake Insurance content', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Swipe to third page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        expect(find.text('Mistake Insurance'), findsOneWidget);
        expect(find.text('Protected when it matters'), findsOneWidget);
      });
    });

    group('page navigation', () {
      testWidgets('swiping left advances to next page', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Verify on first page
        expect(find.text('Your AI Repair Partner'), findsOneWidget);

        // Swipe left
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Should be on second page
        expect(find.text('Visual Verification'), findsOneWidget);
      });

      testWidgets('swiping right goes to previous page', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Go to second page
        await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
        await tester.pumpAndSettle();

        // Verify on second page via PageIndicator
        var pageIndicator = tester.widget<PageIndicator>(
          find.byType(PageIndicator),
        );
        expect(pageIndicator.currentPage, equals(1));

        // Swipe right (fling with velocity)
        await tester.fling(find.byType(PageView), const Offset(300, 0), 1000);
        await tester.pumpAndSettle();

        // Should be back on first page
        pageIndicator = tester.widget<PageIndicator>(
          find.byType(PageIndicator),
        );
        expect(pageIndicator.currentPage, equals(0));
      });

      testWidgets('PageIndicator updates when page changes', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Initial state - first page active
        var pageIndicator = tester.widget<PageIndicator>(
          find.byType(PageIndicator),
        );
        expect(pageIndicator.currentPage, equals(0));

        // Swipe to second page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // PageIndicator should show second page active
        pageIndicator = tester.widget<PageIndicator>(
          find.byType(PageIndicator),
        );
        expect(pageIndicator.currentPage, equals(1));
      });

      testWidgets('tapping PageIndicator dot navigates to that page', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Find the PageIndicator and tap the third dot
        final pageIndicator = find.byType(PageIndicator);
        final dots = find.descendant(
          of: pageIndicator,
          matching: find.byType(GestureDetector),
        );

        await tester.tap(dots.at(2));
        await tester.pumpAndSettle();

        // Should be on third page
        expect(find.text('Mistake Insurance'), findsOneWidget);
      });
    });

    group('button actions', () {
      testWidgets('Skip button calls onSkip callback', (tester) async {
        String? navigatedTo;

        await tester.pumpWidget(buildTestWidget(
          onNavigate: (route) => navigatedTo = route,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        expect(navigatedTo, equals('skip'));
      });

      testWidgets('Get Started button calls onGetStarted callback', (tester) async {
        String? navigatedTo;

        await tester.pumpWidget(buildTestWidget(
          onNavigate: (route) => navigatedTo = route,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        expect(navigatedTo, equals('get_started'));
      });

      testWidgets('Sign In link calls onSignIn callback', (tester) async {
        String? navigatedTo;

        await tester.pumpWidget(buildTestWidget(
          onNavigate: (route) => navigatedTo = route,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Already have an account? Sign In'));
        await tester.pumpAndSettle();

        expect(navigatedTo, equals('sign_in'));
      });
    });

    group('persistence', () {
      testWidgets('saves current page to provider when swiping', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Swipe to second page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Verify the page was saved
        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        expect(captured, isNotEmpty);
        final savedStatus = captured.last as OnboardingStatus;
        expect(savedStatus.currentPage, equals(1));
      });

      testWidgets('restores saved page on mount', (tester) async {
        // Setup mock to return saved page
        when(() => mockBox.get('status')).thenReturn(
          const OnboardingStatus(currentPage: 2),
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should start on page 3 (index 2)
        expect(find.text('Mistake Insurance'), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('buttons have semantic labels', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Verify skip button is accessible (may find multiple semantic nodes)
        expect(
          find.bySemanticsLabel('Skip'),
          findsWidgets,
        );
      });

      testWidgets('page content is accessible', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Verify page title is readable
        expect(
          find.text('Your AI Repair Partner'),
          findsOneWidget,
        );
      });
    });
  });
}
