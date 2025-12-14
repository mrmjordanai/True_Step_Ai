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

    // Verify that our app shows the home screen
    expect(find.text('TrueStep'), findsOneWidget);
    expect(find.text('The Briefing'), findsOneWidget);
  });
}
