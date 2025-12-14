import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:truestep/app/theme.dart';

/// Extension on WidgetTester for convenient app pumping
extension PumpApp on WidgetTester {
  /// Pumps the app with a single widget wrapped in necessary providers
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
    GoRouter? router,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: TrueStepTheme.darkTheme,
          home: widget,
        ),
      ),
    );
  }

  /// Pumps the app with routing support
  Future<void> pumpAppWithRouter(
    GoRouter router, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(
          theme: TrueStepTheme.darkTheme,
          routerConfig: router,
        ),
      ),
    );
  }

  /// Pumps a widget in a scaffold body
  Future<void> pumpScaffoldBody(
    Widget body, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: TrueStepTheme.darkTheme,
          home: Scaffold(body: body),
        ),
      ),
    );
  }

  /// Pumps a widget centered in a scaffold
  Future<void> pumpCentered(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: TrueStepTheme.darkTheme,
          home: Scaffold(
            body: Center(child: widget),
          ),
        ),
      ),
    );
  }

  /// Pumps a widget with specific size constraints
  Future<void> pumpWithSize(
    Widget widget, {
    double width = 400,
    double height = 800,
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: TrueStepTheme.darkTheme,
          home: Scaffold(
            body: SizedBox(
              width: width,
              height: height,
              child: widget,
            ),
          ),
        ),
      ),
    );
  }
}

/// Creates a simple GoRouter for testing navigation
GoRouter createTestRouter({
  required String initialLocation,
  required Map<String, Widget Function(BuildContext, GoRouterState)> routes,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: routes.entries
        .map(
          (entry) => GoRoute(
            path: entry.key,
            builder: entry.value,
          ),
        )
        .toList(),
  );
}
