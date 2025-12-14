import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:truestep/features/onboarding/screens/account_screen.dart';
import 'package:truestep/services/auth_service.dart';
import 'package:truestep/shared/widgets/primary_button.dart';

import '../../../helpers/mock_services.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget buildTestWidget({
    VoidCallback? onContinue,
    VoidCallback? onSkip,
  }) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
      child: MaterialApp(
        home: AccountScreen(
          onContinue: onContinue ?? () {},
          onSkip: onSkip,
        ),
      ),
    );
  }

  group('AccountScreen', () {
    group('rendering', () {
      testWidgets('renders account creation UI', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Create Account'), findsOneWidget);
      });

      testWidgets('renders Continue with Apple button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Continue with Apple'), findsOneWidget);
      });

      testWidgets('renders Continue with Google button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Continue with Google'), findsOneWidget);
      });

      testWidgets('renders Continue with Email button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Continue with Email'), findsOneWidget);
      });

      testWidgets('renders Continue as Guest button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Continue as Guest'), findsOneWidget);
      });

      testWidgets('renders divider between social and email options', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('or'), findsOneWidget);
      });
    });

    group('Apple Sign-In (Coming Soon)', () {
      testWidgets('shows Coming Soon snackbar when Apple tapped', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Apple'));
        await tester.pumpAndSettle();

        expect(find.text('Coming Soon'), findsOneWidget);
      });
    });

    group('Google Sign-In (Coming Soon)', () {
      testWidgets('shows Coming Soon snackbar when Google tapped', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();

        expect(find.text('Coming Soon'), findsOneWidget);
      });
    });

    group('Email Sign-In', () {
      testWidgets('shows email form when Continue with Email tapped', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Should show email input field
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('email form has email and password fields', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('email form validates empty email', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Try to submit empty form
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('email form validates invalid email format', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(find.byType(TextField).first, 'invalid-email');
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('email form validates password length', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Enter valid email but short password
        await tester.enterText(find.byType(TextField).first, 'test@example.com');
        await tester.enterText(find.byType(TextField).last, '123');
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });

      testWidgets('submits valid email/password and calls onContinue', (tester) async {
        bool continueCalled = false;
        final mockCredential = MockUserCredential();

        when(() => mockAuthService.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        await tester.pumpWidget(buildTestWidget(
          onContinue: () => continueCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(find.byType(TextField).first, 'test@example.com');
        await tester.enterText(find.byType(TextField).last, 'password123');
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        verify(() => mockAuthService.createUserWithEmailAndPassword(
              email: 'test@example.com',
              password: 'password123',
            )).called(1);
        expect(continueCalled, isTrue);
      });
    });

    group('Guest Sign-In', () {
      testWidgets('signs in anonymously when Continue as Guest tapped', (tester) async {
        bool continueCalled = false;
        final mockCredential = MockUserCredential();

        when(() => mockAuthService.signInAnonymously())
            .thenAnswer((_) async => mockCredential);

        await tester.pumpWidget(buildTestWidget(
          onContinue: () => continueCalled = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue as Guest'));
        await tester.pumpAndSettle();

        verify(() => mockAuthService.signInAnonymously()).called(1);
        expect(continueCalled, isTrue);
      });

      testWidgets('shows error message when guest sign-in fails', (tester) async {
        when(() => mockAuthService.signInAnonymously())
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue as Guest'));
        await tester.pumpAndSettle();

        // Should show error snackbar
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('back button returns to main view from email form', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Go to email form
        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Tap back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Should be back at main view
        expect(find.text('Continue with Apple'), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('buttons are accessible', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // All buttons should be findable
        expect(find.text('Continue with Apple'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Continue with Email'), findsOneWidget);
        expect(find.text('Continue as Guest'), findsOneWidget);
      });
    });
  });
}
