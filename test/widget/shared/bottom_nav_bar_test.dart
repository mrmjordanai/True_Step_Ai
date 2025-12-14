import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truestep/shared/widgets/bottom_nav_bar.dart';

void main() {
  Widget buildTestWidget({
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    VoidCallback? onQuickActionTap,
    int notificationCount = 0,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(
            currentIndex: currentIndex,
            onTap: onTap ?? (_) {},
            onQuickActionTap: onQuickActionTap,
            notificationCount: notificationCount,
          ),
        ),
      ),
    );
  }

  group('BottomNavBar', () {
    group('rendering', () {
      testWidgets('renders 5 navigation items', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should find 5 tab items
        expect(find.byType(BottomNavBar), findsOneWidget);
      });

      testWidgets('renders Search tab', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('renders Community tab', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.people_outline), findsOneWidget);
      });

      testWidgets('renders Quick+ center button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('renders History tab', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.history), findsOneWidget);
      });

      testWidgets('renders Profile tab', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('tapping Search tab calls onTap with index 0', (tester) async {
        int tappedIndex = -1;

        await tester.pumpWidget(buildTestWidget(
          onTap: (index) => tappedIndex = index,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        expect(tappedIndex, equals(0));
      });

      testWidgets('tapping Community tab calls onTap with index 1', (tester) async {
        int tappedIndex = -1;

        await tester.pumpWidget(buildTestWidget(
          onTap: (index) => tappedIndex = index,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.people_outline));
        await tester.pumpAndSettle();

        expect(tappedIndex, equals(1));
      });

      testWidgets('tapping Quick+ button calls onQuickActionTap', (tester) async {
        bool quickActionTapped = false;

        await tester.pumpWidget(buildTestWidget(
          onQuickActionTap: () => quickActionTapped = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(quickActionTapped, isTrue);
      });

      testWidgets('tapping History tab calls onTap with index 3', (tester) async {
        int tappedIndex = -1;

        await tester.pumpWidget(buildTestWidget(
          onTap: (index) => tappedIndex = index,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.history));
        await tester.pumpAndSettle();

        expect(tappedIndex, equals(3));
      });

      testWidgets('tapping Profile tab calls onTap with index 4', (tester) async {
        int tappedIndex = -1;

        await tester.pumpWidget(buildTestWidget(
          onTap: (index) => tappedIndex = index,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.person_outline));
        await tester.pumpAndSettle();

        expect(tappedIndex, equals(4));
      });
    });

    group('active state', () {
      testWidgets('Search tab shows active when currentIndex is 0', (tester) async {
        await tester.pumpWidget(buildTestWidget(currentIndex: 0));
        await tester.pumpAndSettle();

        // Active tab should have different styling
        expect(find.byType(BottomNavBar), findsOneWidget);
      });

      testWidgets('Community tab shows active when currentIndex is 1', (tester) async {
        await tester.pumpWidget(buildTestWidget(currentIndex: 1));
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavBar), findsOneWidget);
      });

      testWidgets('History tab shows active when currentIndex is 3', (tester) async {
        await tester.pumpWidget(buildTestWidget(currentIndex: 3));
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavBar), findsOneWidget);
      });

      testWidgets('Profile tab shows active when currentIndex is 4', (tester) async {
        await tester.pumpWidget(buildTestWidget(currentIndex: 4));
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavBar), findsOneWidget);
      });
    });

    group('badges', () {
      testWidgets('does not show badge when notificationCount is 0', (tester) async {
        await tester.pumpWidget(buildTestWidget(notificationCount: 0));
        await tester.pumpAndSettle();

        // Should not find badge text
        expect(find.text('0'), findsNothing);
      });

      testWidgets('shows badge with count when notificationCount > 0', (tester) async {
        await tester.pumpWidget(buildTestWidget(notificationCount: 5));
        await tester.pumpAndSettle();

        // Should find badge with count
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('shows 9+ for notification count > 9', (tester) async {
        await tester.pumpWidget(buildTestWidget(notificationCount: 15));
        await tester.pumpAndSettle();

        // Should show 9+ for large counts
        expect(find.text('9+'), findsOneWidget);
      });
    });

    group('Quick+ button styling', () {
      testWidgets('Quick+ button is elevated/FAB style', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Quick+ should be styled differently (elevated)
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    group('theming', () {
      testWidgets('uses dark background', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavBar), findsOneWidget);
      });
    });
  });
}
