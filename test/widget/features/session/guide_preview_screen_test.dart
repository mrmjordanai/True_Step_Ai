import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truestep/features/session/screens/guide_preview_screen.dart';
import 'package:truestep/core/models/guide.dart';

void main() {
  late Guide testGuide;

  setUp(() {
    final now = DateTime.now();
    testGuide = Guide(
      guideId: 'test-guide-123',
      title: 'Perfect Scrambled Eggs',
      category: GuideCategory.culinary,
      sourceUrl: 'https://recipe.com/scrambled-eggs',
      steps: [
        GuideStep(
          stepId: 1,
          title: 'Crack the eggs',
          instruction: 'Crack 3 eggs into a bowl',
          successCriteria: 'Eggs are in bowl without shells',
          estimatedDuration: 30,
          tools: ['Bowl'],
        ),
        GuideStep(
          stepId: 2,
          title: 'Beat eggs',
          instruction: 'Whisk the eggs until combined',
          successCriteria: 'Eggs are uniformly yellow',
          estimatedDuration: 20,
          tools: ['Whisk'],
        ),
        GuideStep(
          stepId: 3,
          title: 'Cook',
          instruction: 'Cook on medium heat, stirring constantly',
          successCriteria: 'Eggs are fluffy and cooked through',
          estimatedDuration: 180,
          warnings: ['Pan handle may be hot'],
          tools: ['Non-stick pan', 'Spatula'],
        ),
      ],
      totalDuration: 230,
      difficulty: GuideDifficulty.easy,
      tools: ['Bowl', 'Whisk', 'Non-stick pan', 'Spatula'],
      createdAt: now,
      updatedAt: now,
    );
  });

  Widget buildTestWidget({
    required Guide guide,
    VoidCallback? onStartSession,
    VoidCallback? onBack,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: GuidePreviewScreen(
          guide: guide,
          onStartSession: onStartSession,
          onBack: onBack,
        ),
      ),
    );
  }

  group('GuidePreviewScreen', () {
    group('rendering', () {
      testWidgets('displays guide title', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.text('Perfect Scrambled Eggs'), findsOneWidget);
      });

      testWidgets('displays source URL when available', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.textContaining('recipe.com'), findsOneWidget);
      });

      testWidgets('does not show source section when no URL', (tester) async {
        // Create a new guide without sourceUrl (copyWith doesn't clear it)
        final now = DateTime.now();
        final guideNoUrl = Guide(
          guideId: 'no-url-guide',
          title: 'Test Guide',
          category: GuideCategory.culinary,
          steps: const [],
          createdAt: now,
          updatedAt: now,
        );
        await tester.pumpWidget(buildTestWidget(guide: guideNoUrl));
        await tester.pumpAndSettle();

        expect(find.textContaining('Source'), findsNothing);
      });

      testWidgets('displays step count', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        // Should show "3 steps" or similar
        expect(find.textContaining('3'), findsWidgets);
        expect(find.textContaining('step'), findsWidgets);
      });

      testWidgets('displays difficulty level', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.textContaining('Easy'), findsOneWidget);
      });

      testWidgets('displays estimated duration', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        // Duration is 230 seconds = 3:50
        // Should show some time format
        expect(find.textContaining('min'), findsWidgets);
      });

      testWidgets('displays tools list', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.text('Bowl'), findsOneWidget);
        expect(find.text('Whisk'), findsOneWidget);
      });

      testWidgets('displays Start Session button', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.text('Start Session'), findsOneWidget);
      });

      testWidgets('displays back button', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('tapping Start Session calls onStartSession', (tester) async {
        bool startCalled = false;

        await tester.pumpWidget(buildTestWidget(
          guide: testGuide,
          onStartSession: () => startCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Session'));
        await tester.pumpAndSettle();

        expect(startCalled, isTrue);
      });

      testWidgets('tapping back button calls onBack', (tester) async {
        bool backCalled = false;

        await tester.pumpWidget(buildTestWidget(
          guide: testGuide,
          onBack: () => backCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(backCalled, isTrue);
      });
    });

    group('category display', () {
      testWidgets('displays culinary category correctly', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.textContaining('Cooking'), findsWidgets);
      });

      testWidgets('displays DIY category correctly', (tester) async {
        final diyGuide = testGuide.copyWith(category: GuideCategory.diy);
        await tester.pumpWidget(buildTestWidget(guide: diyGuide));
        await tester.pumpAndSettle();

        expect(find.textContaining('DIY'), findsWidgets);
      });
    });

    group('layout', () {
      testWidgets('has proper screen structure', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('is scrollable when content overflows', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsWidgets);
      });
    });

    group('steps preview', () {
      testWidgets('shows step titles', (tester) async {
        await tester.pumpWidget(buildTestWidget(guide: testGuide));
        await tester.pumpAndSettle();

        expect(find.text('Crack the eggs'), findsOneWidget);
        expect(find.text('Beat eggs'), findsOneWidget);
        expect(find.text('Cook'), findsOneWidget);
      });
    });
  });
}
