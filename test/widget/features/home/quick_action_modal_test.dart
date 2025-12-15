import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:truestep/features/home/widgets/quick_action_modal.dart';

void main() {
  Future<void> showModal(
    WidgetTester tester, {
    void Function(QuickAction)? onActionSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showQuickActionModal(
                    context,
                    onActionSelected: onActionSelected ?? (_) {},
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap button to open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();
  }

  group('QuickActionModal', () {
    group('rendering', () {
      testWidgets('displays modal when showQuickActionModal is called', (
        tester,
      ) async {
        await showModal(tester);

        // Modal should be visible
        expect(find.text('Quick Start'), findsOneWidget);
      });

      testWidgets('shows "Paste URL" option', (tester) async {
        await showModal(tester);

        expect(find.text('Paste URL'), findsOneWidget);
        expect(find.byIcon(Icons.link), findsOneWidget);
      });

      testWidgets('shows "Describe Task" option', (tester) async {
        await showModal(tester);

        expect(find.text('Describe Task'), findsOneWidget);
        expect(find.byIcon(Icons.edit_note), findsOneWidget);
      });

      testWidgets('shows "Voice Input" option', (tester) async {
        await showModal(tester);

        expect(find.text('Voice Input'), findsOneWidget);
        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('shows "Scan QR" option', (tester) async {
        await showModal(tester);

        expect(find.text('Scan QR'), findsOneWidget);
        expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      });

      testWidgets('shows all four quick action options', (tester) async {
        await showModal(tester);

        expect(find.text('Paste URL'), findsOneWidget);
        expect(find.text('Describe Task'), findsOneWidget);
        expect(find.text('Voice Input'), findsOneWidget);
        expect(find.text('Scan QR'), findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('tapping Paste URL calls onActionSelected with pasteUrl', (
        tester,
      ) async {
        QuickAction? selectedAction;

        await showModal(
          tester,
          onActionSelected: (action) => selectedAction = action,
        );

        await tester.tap(find.text('Paste URL'));
        await tester.pumpAndSettle();

        expect(selectedAction, equals(QuickAction.pasteUrl));
      });

      testWidgets('tapping Describe Task calls onActionSelected with describeTask', (
        tester,
      ) async {
        QuickAction? selectedAction;

        await showModal(
          tester,
          onActionSelected: (action) => selectedAction = action,
        );

        await tester.tap(find.text('Describe Task'));
        await tester.pumpAndSettle();

        expect(selectedAction, equals(QuickAction.describeTask));
      });

      testWidgets('tapping Voice Input calls onActionSelected with voiceInput', (
        tester,
      ) async {
        QuickAction? selectedAction;

        await showModal(
          tester,
          onActionSelected: (action) => selectedAction = action,
        );

        await tester.tap(find.text('Voice Input'));
        await tester.pumpAndSettle();

        expect(selectedAction, equals(QuickAction.voiceInput));
      });

      testWidgets('tapping Scan QR calls onActionSelected with scanQr', (
        tester,
      ) async {
        QuickAction? selectedAction;

        await showModal(
          tester,
          onActionSelected: (action) => selectedAction = action,
        );

        await tester.tap(find.text('Scan QR'));
        await tester.pumpAndSettle();

        expect(selectedAction, equals(QuickAction.scanQr));
      });

      testWidgets('modal closes after action is selected', (tester) async {
        await showModal(tester);

        // Modal is open
        expect(find.text('Quick Start'), findsOneWidget);

        // Tap an action
        await tester.tap(find.text('Paste URL'));
        await tester.pumpAndSettle();

        // Modal should be closed
        expect(find.text('Quick Start'), findsNothing);
      });

      testWidgets('modal can be dismissed by tapping outside', (tester) async {
        await showModal(tester);

        // Modal is open
        expect(find.text('Quick Start'), findsOneWidget);

        // Tap outside the modal (on the barrier)
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Modal should be closed
        expect(find.text('Quick Start'), findsNothing);
      });
    });

    group('styling', () {
      testWidgets('has proper title', (tester) async {
        await showModal(tester);

        expect(find.text('Quick Start'), findsOneWidget);
      });

      testWidgets('has subtitle text', (tester) async {
        await showModal(tester);

        expect(find.text('Choose how to start your session'), findsOneWidget);
      });
    });
  });
}
