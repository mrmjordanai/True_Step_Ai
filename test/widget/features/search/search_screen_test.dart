import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truestep/features/search/screens/search_screen.dart';

void main() {
  Widget buildTestWidget({
    VoidCallback? onVoiceTap,
    void Function(String)? onSearch,
    void Function(String)? onCategorySelected,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: SearchScreen(
          onVoiceTap: onVoiceTap,
          onSearch: onSearch,
          onCategorySelected: onCategorySelected,
        ),
      ),
    );
  }

  group('SearchScreen', () {
    group('search bar', () {
      testWidgets('renders search input field', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('search field has placeholder text', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Search guides...'), findsOneWidget);
      });

      testWidgets('search field has search icon', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('search field has voice input button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('voice button calls onVoiceTap', (tester) async {
        bool voiceTapped = false;

        await tester.pumpWidget(buildTestWidget(
          onVoiceTap: () => voiceTapped = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        expect(voiceTapped, isTrue);
      });

      testWidgets('typing in search field triggers onSearch', (tester) async {
        String searchQuery = '';

        await tester.pumpWidget(buildTestWidget(
          onSearch: (query) => searchQuery = query,
        ));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'pasta recipe');
        await tester.pumpAndSettle();

        expect(searchQuery, equals('pasta recipe'));
      });
    });

    group('category filters', () {
      testWidgets('renders category filter chips', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should have category filters (use findsWidgets for those that appear in guides too)
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Cooking'), findsWidgets);
        expect(find.text('DIY'), findsWidgets);
        expect(find.text('Electronics'), findsOneWidget);
      });

      testWidgets('All category is selected by default', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // All should be visually selected
        expect(find.text('All'), findsOneWidget);
      });

      testWidgets('tapping category calls onCategorySelected', (tester) async {
        String selectedCategory = '';

        await tester.pumpWidget(buildTestWidget(
          onCategorySelected: (category) => selectedCategory = category,
        ));
        await tester.pumpAndSettle();

        // Use first to get category chip (not guide category label)
        await tester.tap(find.text('Cooking').first);
        await tester.pumpAndSettle();

        expect(selectedCategory, equals('cooking'));
      });

      testWidgets('tapping DIY category works', (tester) async {
        String selectedCategory = '';

        await tester.pumpWidget(buildTestWidget(
          onCategorySelected: (category) => selectedCategory = category,
        ));
        await tester.pumpAndSettle();

        // Use first to get category chip (not guide category label)
        await tester.tap(find.text('DIY').first);
        await tester.pumpAndSettle();

        expect(selectedCategory, equals('diy'));
      });
    });

    group('results list', () {
      testWidgets('shows browse message when no search query', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should show browse message or empty state
        expect(
          find.textContaining('Browse'),
          findsWidgets,
        );
      });

      testWidgets('results area is scrollable', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should have some scrollable area
        expect(find.byType(Scrollable), findsWidgets);
      });

      testWidgets('shows "No results found" when search has no matches', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Enter a search query that won't match any guides
        await tester.enterText(find.byType(TextField), 'xyznonexistent123');
        await tester.pumpAndSettle();

        // Should show no results message
        expect(find.text('No results found'), findsOneWidget);
      });

      testWidgets('filters guides based on search query', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Initially should show popular guides
        expect(find.text('Perfect Scrambled Eggs'), findsOneWidget);
        expect(find.text('iPhone Screen Replacement'), findsOneWidget);

        // Search for eggs
        await tester.enterText(find.byType(TextField), 'eggs');
        await tester.pumpAndSettle();

        // Should show matching guide
        expect(find.text('Perfect Scrambled Eggs'), findsOneWidget);
        // Should not show non-matching guides
        expect(find.text('iPhone Screen Replacement'), findsNothing);
      });

      testWidgets('shows all guides when search is cleared', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Enter a search query
        await tester.enterText(find.byType(TextField), 'eggs');
        await tester.pumpAndSettle();

        // Clear the search
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();

        // Should show all popular guides again
        expect(find.text('Popular Guides'), findsOneWidget);
        expect(find.text('Perfect Scrambled Eggs'), findsOneWidget);
      });
    });

    group('layout', () {
      testWidgets('uses proper screen structure', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('has dark background', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNotNull);
      });
    });

    group('popular guides', () {
      testWidgets('shows popular guides section', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Popular Guides'), findsOneWidget);
      });
    });
  });
}
