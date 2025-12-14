import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truestep/app/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TrueStepApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that our app shows the home screen with greeting
    expect(find.text('Hello there!'), findsOneWidget);
  });
}
