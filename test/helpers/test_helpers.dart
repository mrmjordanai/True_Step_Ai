import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/app/theme.dart';

/// Wraps a widget with MaterialApp and ProviderScope for testing
Widget buildTestableWidget(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: TrueStepTheme.darkTheme,
      home: Scaffold(body: child),
    ),
  );
}

/// Wraps a widget with MaterialApp only (no ProviderScope)
Widget buildTestableWidgetWithoutProvider(Widget child) {
  return MaterialApp(
    theme: TrueStepTheme.darkTheme,
    home: Scaffold(body: child),
  );
}

/// Wraps a widget in a constrained box for testing layout
Widget buildConstrainedWidget(
  Widget child, {
  double width = 400,
  double height = 800,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: TrueStepTheme.darkTheme,
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    ),
  );
}

/// Extension to simplify pumping widgets in tests
extension WidgetTesterExtension on WidgetTester {
  /// Pumps a widget wrapped with test helpers
  Future<void> pumpTestWidget(
    Widget child, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(buildTestableWidget(child, overrides: overrides));
  }

  /// Pumps a widget and settles all animations
  Future<void> pumpAndSettleTestWidget(
    Widget child, {
    List<Override> overrides = const [],
    Duration duration = const Duration(seconds: 10),
  }) async {
    await pumpWidget(buildTestableWidget(child, overrides: overrides));
    await pumpAndSettle(duration);
  }
}

/// Test group helper for organizing widget tests
void widgetTestGroup(String description, void Function() body) {
  group('Widget: $description', body);
}

/// Golden test helper (for future visual regression testing)
Future<void> expectGolden(
  WidgetTester tester,
  Widget widget,
  String goldenName,
) async {
  await tester.pumpTestWidget(widget);
  await expectLater(
    find.byType(widget.runtimeType),
    matchesGoldenFile('goldens/$goldenName.png'),
  );
}
