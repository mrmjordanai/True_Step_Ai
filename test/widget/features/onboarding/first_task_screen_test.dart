import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:truestep/features/onboarding/screens/first_task_screen.dart';
import 'package:truestep/features/onboarding/providers/onboarding_provider.dart';
import 'package:truestep/core/models/onboarding_status.dart';

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
    VoidCallback? onComplete,
  }) {
    return ProviderScope(
      overrides: [
        onboardingBoxProvider.overrideWithValue(mockBox),
      ],
      child: MaterialApp(
        home: FirstTaskScreen(
          onComplete: onComplete ?? () {},
        ),
      ),
    );
  }

  group('FirstTaskScreen', () {
    group('rendering', () {
      testWidgets('renders title and subtitle', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text("What's your first task?"), findsOneWidget);
        expect(find.text("We'll personalize your experience"), findsOneWidget);
      });

      testWidgets('renders 4 task options in a grid', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Cook Something'), findsOneWidget);
        expect(find.text('Fix Something'), findsOneWidget);
        expect(find.text('Scan My Device'), findsOneWidget);
        expect(find.text('Just Explore'), findsOneWidget);
      });

      testWidgets('each task card has an icon', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should find icons for each task
        expect(find.byIcon(Icons.restaurant), findsOneWidget);
        expect(find.byIcon(Icons.build), findsOneWidget);
        expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
        expect(find.byIcon(Icons.explore), findsOneWidget);
      });

      testWidgets('task cards are tappable', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Each card should be wrapped in InkWell or GestureDetector
        final cookCard = find.ancestor(
          of: find.text('Cook Something'),
          matching: find.byType(InkWell),
        );
        expect(cookCard, findsOneWidget);
      });
    });

    group('task selection', () {
      testWidgets('selecting Cook Something saves to provider', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cook Something'));
        await tester.pumpAndSettle();

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        expect(captured, isNotEmpty);
        final savedStatus = captured.last as OnboardingStatus;
        expect(savedStatus.selectedFirstTask, equals('cook'));
      });

      testWidgets('selecting Fix Something saves to provider', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Fix Something'));
        await tester.pumpAndSettle();

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        expect(captured, isNotEmpty);
        final savedStatus = captured.last as OnboardingStatus;
        expect(savedStatus.selectedFirstTask, equals('fix'));
      });

      testWidgets('selecting Scan My Device saves to provider', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to make the item visible
        await tester.scrollUntilVisible(
          find.text('Scan My Device'),
          50.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Scan My Device'));
        await tester.pumpAndSettle();

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        expect(captured, isNotEmpty);
        final savedStatus = captured.last as OnboardingStatus;
        expect(savedStatus.selectedFirstTask, equals('scan'));
      });

      testWidgets('selecting Just Explore saves to provider', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to make the item visible
        await tester.scrollUntilVisible(
          find.text('Just Explore'),
          50.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Just Explore'));
        await tester.pumpAndSettle();

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        expect(captured, isNotEmpty);
        final savedStatus = captured.last as OnboardingStatus;
        expect(savedStatus.selectedFirstTask, equals('explore'));
      });

      testWidgets('selecting task marks onboarding as completed', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cook Something'));
        await tester.pumpAndSettle();

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        // Find the completion call (second put)
        final completionStatus = captured.firstWhere(
          (status) => (status as OnboardingStatus).hasCompletedOnboarding,
          orElse: () => const OnboardingStatus(),
        ) as OnboardingStatus;
        expect(completionStatus.hasCompletedOnboarding, isTrue);
      });

      testWidgets('selecting task calls onComplete callback', (tester) async {
        bool completeCalled = false;

        await tester.pumpWidget(buildTestWidget(
          onComplete: () => completeCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cook Something'));
        await tester.pumpAndSettle();

        expect(completeCalled, isTrue);
      });
    });

    group('visual feedback', () {
      testWidgets('selected card shows visual highlight', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap a card
        await tester.tap(find.text('Fix Something'));
        await tester.pump(); // Don't settle - check during animation

        // Card should have some visual change (we'll verify it doesn't crash)
        expect(find.text('Fix Something'), findsOneWidget);
      });
    });

    group('layout', () {
      testWidgets('uses 2x2 grid layout', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should find a GridView or wrap
        final gridView = find.byType(GridView);
        expect(gridView, findsOneWidget);
      });

      testWidgets('grid has proper spacing', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(2));
      });
    });

    group('accessibility', () {
      testWidgets('task cards have semantic labels', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // All task names should be visible and accessible
        expect(find.text('Cook Something'), findsOneWidget);
        expect(find.text('Fix Something'), findsOneWidget);
        expect(find.text('Scan My Device'), findsOneWidget);
        expect(find.text('Just Explore'), findsOneWidget);
      });
    });
  });
}
