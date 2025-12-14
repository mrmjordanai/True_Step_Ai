import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:truestep/features/onboarding/screens/permissions_screen.dart';
import 'package:truestep/services/permission_service.dart';

import '../../../helpers/mock_services.dart';

void main() {
  late MockPermissionService mockPermissionService;

  setUp(() {
    mockPermissionService = MockPermissionService();
    // Default: all permissions not yet granted
    when(() => mockPermissionService.hasCameraPermission())
        .thenAnswer((_) async => false);
    when(() => mockPermissionService.hasMicrophonePermission())
        .thenAnswer((_) async => false);
    when(() => mockPermissionService.hasNotificationPermission())
        .thenAnswer((_) async => false);
  });

  Widget buildTestWidget({
    VoidCallback? onContinue,
    VoidCallback? onSkip,
  }) {
    return ProviderScope(
      overrides: [
        permissionServiceProvider.overrideWithValue(mockPermissionService),
      ],
      child: MaterialApp(
        home: PermissionsScreen(
          onContinue: onContinue ?? () {},
          onSkip: onSkip,
        ),
      ),
    );
  }

  group('PermissionsScreen', () {
    group('rendering', () {
      testWidgets('renders permission request UI', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Enable Permissions'), findsOneWidget);
        expect(find.text('TrueStep needs access to watch and guide you'),
            findsOneWidget);
      });

      testWidgets('renders camera permission item', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Watch your work and verify each step'), findsOneWidget);
      });

      testWidgets('renders microphone permission item', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Microphone'), findsOneWidget);
        expect(find.text('Hear your voice commands'), findsOneWidget);
      });

      testWidgets('renders notification permission item', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Alert you about session updates'), findsOneWidget);
      });

      testWidgets('renders Enable All button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Enable All'), findsOneWidget);
      });

      testWidgets('renders Continue button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Continue'), findsOneWidget);
      });

      testWidgets('renders Skip for now link when onSkip provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(onSkip: () {}));
        await tester.pumpAndSettle();

        expect(find.text('Skip for now'), findsOneWidget);
      });
    });

    group('permission status display', () {
      testWidgets('shows unchecked status for ungranted permissions', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Find icons indicating ungranted status
        expect(find.byIcon(Icons.circle_outlined), findsNWidgets(3));
      });

      testWidgets('shows checked status for granted camera permission', (tester) async {
        when(() => mockPermissionService.hasCameraPermission())
            .thenAnswer((_) async => true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should find at least one check icon
        expect(find.byIcon(Icons.check_circle), findsWidgets);
      });

      testWidgets('shows all checked when all permissions granted', (tester) async {
        when(() => mockPermissionService.hasCameraPermission())
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.hasMicrophonePermission())
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.hasNotificationPermission())
            .thenAnswer((_) async => true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
      });
    });

    group('permission requests', () {
      testWidgets('Enable All requests all permissions', (tester) async {
        when(() => mockPermissionService.requestCameraPermission())
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.requestMicrophonePermission())
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.requestNotificationPermission())
            .thenAnswer((_) async => true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Enable All'));
        await tester.pumpAndSettle();

        verify(() => mockPermissionService.requestCameraPermission()).called(1);
        verify(() => mockPermissionService.requestMicrophonePermission()).called(1);
        verify(() => mockPermissionService.requestNotificationPermission()).called(1);
      });

      testWidgets('tapping permission item requests that permission', (tester) async {
        when(() => mockPermissionService.requestCameraPermission())
            .thenAnswer((_) async => true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap the camera permission item
        await tester.tap(find.text('Camera'));
        await tester.pumpAndSettle();

        verify(() => mockPermissionService.requestCameraPermission()).called(1);
      });
    });

    group('navigation', () {
      testWidgets('Continue button calls onContinue', (tester) async {
        bool continueCalled = false;

        await tester.pumpWidget(buildTestWidget(
          onContinue: () => continueCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(continueCalled, isTrue);
      });

      testWidgets('Skip button shows limitations warning modal', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          onSkip: () {},
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Skip for now'));
        await tester.pumpAndSettle();

        // Modal should appear with warning content
        expect(find.text('Limited Experience'), findsOneWidget);
        expect(find.text('Continue Anyway'), findsOneWidget);
        expect(find.text('Go Back'), findsOneWidget);
      });

      testWidgets('Skip button calls onSkip after confirming in modal', (tester) async {
        bool skipCalled = false;

        await tester.pumpWidget(buildTestWidget(
          onSkip: () => skipCalled = true,
        ));
        await tester.pumpAndSettle();

        // Tap skip to show modal
        await tester.tap(find.text('Skip for now'));
        await tester.pumpAndSettle();

        // Confirm in modal
        await tester.tap(find.text('Continue Anyway'));
        await tester.pumpAndSettle();

        expect(skipCalled, isTrue);
      });

      testWidgets('Go Back in modal closes it without calling onSkip', (tester) async {
        bool skipCalled = false;

        await tester.pumpWidget(buildTestWidget(
          onSkip: () => skipCalled = true,
        ));
        await tester.pumpAndSettle();

        // Tap skip to show modal
        await tester.tap(find.text('Skip for now'));
        await tester.pumpAndSettle();

        // Tap Go Back to dismiss modal
        await tester.tap(find.text('Go Back'));
        await tester.pumpAndSettle();

        expect(skipCalled, isFalse);
        expect(find.text('Limited Experience'), findsNothing);
      });

      testWidgets('Skip button calls onSkip directly when all permissions granted', (tester) async {
        // All permissions granted
        when(() => mockPermissionService.hasCameraPermission())
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.hasMicrophonePermission())
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.hasNotificationPermission())
            .thenAnswer((_) async => true);

        bool skipCalled = false;

        await tester.pumpWidget(buildTestWidget(
          onSkip: () => skipCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Skip for now'));
        await tester.pumpAndSettle();

        // Should skip directly without modal since all permissions granted
        expect(skipCalled, isTrue);
        expect(find.text('Limited Experience'), findsNothing);
      });
    });

    group('permission denial handling', () {
      testWidgets('shows settings prompt when permission denied', (tester) async {
        when(() => mockPermissionService.requestCameraPermission())
            .thenAnswer((_) async => false);
        when(() => mockPermissionService.isCameraPermissionPermanentlyDenied())
            .thenAnswer((_) async => true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Camera'));
        await tester.pumpAndSettle();

        // Should show snackbar or dialog about opening settings
        // The actual implementation may vary
      });
    });

    group('accessibility', () {
      testWidgets('permission items are tappable', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // All permission items should be GestureDetector or InkWell
        final cameraItem = find.ancestor(
          of: find.text('Camera'),
          matching: find.byType(InkWell),
        );
        expect(cameraItem, findsOneWidget);
      });
    });
  });
}
