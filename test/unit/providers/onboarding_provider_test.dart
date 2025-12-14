import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:truestep/core/models/onboarding_status.dart';
import 'package:truestep/features/onboarding/providers/onboarding_provider.dart';

// Mock Hive Box
class MockBox extends Mock implements Box<OnboardingStatus> {}

void main() {
  late MockBox mockBox;
  late ProviderContainer container;

  setUpAll(() {
    // Register fallback value for OnboardingStatus used with any()/captureAny()
    registerFallbackValue(const OnboardingStatus());
  });

  setUp(() {
    mockBox = MockBox();
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer({OnboardingStatus? initialStatus}) {
    return ProviderContainer(
      overrides: [
        onboardingBoxProvider.overrideWithValue(mockBox),
      ],
    );
  }

  group('OnboardingProvider', () {
    group('initialization', () {
      test('returns initial status when box is empty', () {
        when(() => mockBox.get('status')).thenReturn(null);

        container = createContainer();
        final status = container.read(onboardingStatusProvider);

        expect(status.hasCompletedOnboarding, isFalse);
        expect(status.currentPage, equals(0));
        expect(status.selectedFirstTask, isNull);
        expect(status.completedAt, isNull);
      });

      test('returns saved status when box has data', () {
        final savedStatus = OnboardingStatus(
          hasCompletedOnboarding: true,
          completedAt: DateTime(2024, 1, 1),
          selectedFirstTask: 'cook',
          currentPage: 2,
        );
        when(() => mockBox.get('status')).thenReturn(savedStatus);

        container = createContainer();
        final status = container.read(onboardingStatusProvider);

        expect(status.hasCompletedOnboarding, isTrue);
        expect(status.selectedFirstTask, equals('cook'));
        expect(status.currentPage, equals(2));
      });
    });

    group('hasCompletedOnboarding', () {
      test('returns false for new users', () {
        when(() => mockBox.get('status')).thenReturn(null);

        container = createContainer();
        final hasCompleted = container.read(hasCompletedOnboardingProvider);

        expect(hasCompleted, isFalse);
      });

      test('returns true for users who completed onboarding', () {
        when(() => mockBox.get('status')).thenReturn(
          const OnboardingStatus(hasCompletedOnboarding: true),
        );

        container = createContainer();
        final hasCompleted = container.read(hasCompletedOnboardingProvider);

        expect(hasCompleted, isTrue);
      });
    });

    group('setCurrentPage', () {
      test('updates current page in status', () async {
        when(() => mockBox.get('status')).thenReturn(null);
        when(() => mockBox.put('status', any())).thenAnswer((_) async {});

        container = createContainer();
        final notifier = container.read(onboardingNotifierProvider.notifier);

        notifier.setCurrentPage(2);

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        final savedStatus = captured.first as OnboardingStatus;
        expect(savedStatus.currentPage, equals(2));
      });

      test('preserves other fields when updating page', () async {
        when(() => mockBox.get('status')).thenReturn(
          const OnboardingStatus(selectedFirstTask: 'fix'),
        );
        when(() => mockBox.put('status', any())).thenAnswer((_) async {});

        container = createContainer();
        final notifier = container.read(onboardingNotifierProvider.notifier);

        notifier.setCurrentPage(1);

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        final savedStatus = captured.first as OnboardingStatus;
        expect(savedStatus.currentPage, equals(1));
        expect(savedStatus.selectedFirstTask, equals('fix'));
      });
    });

    group('setFirstTask', () {
      test('saves selected first task', () async {
        when(() => mockBox.get('status')).thenReturn(null);
        when(() => mockBox.put('status', any())).thenAnswer((_) async {});

        container = createContainer();
        final notifier = container.read(onboardingNotifierProvider.notifier);

        notifier.setFirstTask(FirstTaskOption.cook);

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        final savedStatus = captured.first as OnboardingStatus;
        expect(savedStatus.selectedFirstTask, equals('cook'));
      });

      test('updates existing status with new task selection', () async {
        when(() => mockBox.get('status')).thenReturn(
          const OnboardingStatus(currentPage: 2),
        );
        when(() => mockBox.put('status', any())).thenAnswer((_) async {});

        container = createContainer();
        final notifier = container.read(onboardingNotifierProvider.notifier);

        notifier.setFirstTask(FirstTaskOption.scan);

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        final savedStatus = captured.first as OnboardingStatus;
        expect(savedStatus.selectedFirstTask, equals('scan'));
        expect(savedStatus.currentPage, equals(2));
      });
    });

    group('completeOnboarding', () {
      test('marks onboarding as completed', () async {
        when(() => mockBox.get('status')).thenReturn(null);
        when(() => mockBox.put('status', any())).thenAnswer((_) async {});

        container = createContainer();
        final notifier = container.read(onboardingNotifierProvider.notifier);

        notifier.completeOnboarding();

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        final savedStatus = captured.first as OnboardingStatus;
        expect(savedStatus.hasCompletedOnboarding, isTrue);
        expect(savedStatus.completedAt, isNotNull);
      });

      test('preserves first task selection when completing', () async {
        when(() => mockBox.get('status')).thenReturn(
          const OnboardingStatus(selectedFirstTask: 'explore'),
        );
        when(() => mockBox.put('status', any())).thenAnswer((_) async {});

        container = createContainer();
        final notifier = container.read(onboardingNotifierProvider.notifier);

        notifier.completeOnboarding();

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        final savedStatus = captured.first as OnboardingStatus;
        expect(savedStatus.hasCompletedOnboarding, isTrue);
        expect(savedStatus.selectedFirstTask, equals('explore'));
      });
    });

    group('resetOnboarding', () {
      test('resets all onboarding data', () async {
        when(() => mockBox.get('status')).thenReturn(
          OnboardingStatus(
            hasCompletedOnboarding: true,
            completedAt: DateTime.now(),
            selectedFirstTask: 'cook',
            currentPage: 2,
          ),
        );
        when(() => mockBox.put('status', any())).thenAnswer((_) async {});

        container = createContainer();
        final notifier = container.read(onboardingNotifierProvider.notifier);

        notifier.resetOnboarding();

        final captured = verify(() => mockBox.put('status', captureAny())).captured;
        final savedStatus = captured.first as OnboardingStatus;
        expect(savedStatus.hasCompletedOnboarding, isFalse);
        expect(savedStatus.completedAt, isNull);
        expect(savedStatus.selectedFirstTask, isNull);
        expect(savedStatus.currentPage, equals(0));
      });
    });

    group('currentPageProvider', () {
      test('returns current page from status', () {
        when(() => mockBox.get('status')).thenReturn(
          const OnboardingStatus(currentPage: 1),
        );

        container = createContainer();
        final currentPage = container.read(currentPageProvider);

        expect(currentPage, equals(1));
      });

      test('returns 0 for new users', () {
        when(() => mockBox.get('status')).thenReturn(null);

        container = createContainer();
        final currentPage = container.read(currentPageProvider);

        expect(currentPage, equals(0));
      });
    });

    group('selectedFirstTaskProvider', () {
      test('returns selected task from status', () {
        when(() => mockBox.get('status')).thenReturn(
          const OnboardingStatus(selectedFirstTask: 'fix'),
        );

        container = createContainer();
        final task = container.read(selectedFirstTaskProvider);

        expect(task, equals(FirstTaskOption.fix));
      });

      test('returns null when no task selected', () {
        when(() => mockBox.get('status')).thenReturn(null);

        container = createContainer();
        final task = container.read(selectedFirstTaskProvider);

        expect(task, isNull);
      });
    });
  });

  group('FirstTaskOption', () {
    test('fromId returns correct option for valid ID', () {
      expect(FirstTaskOption.fromId('cook'), equals(FirstTaskOption.cook));
      expect(FirstTaskOption.fromId('fix'), equals(FirstTaskOption.fix));
      expect(FirstTaskOption.fromId('scan'), equals(FirstTaskOption.scan));
      expect(FirstTaskOption.fromId('explore'), equals(FirstTaskOption.explore));
    });

    test('fromId returns null for invalid ID', () {
      expect(FirstTaskOption.fromId('invalid'), isNull);
      expect(FirstTaskOption.fromId(''), isNull);
    });

    test('fromId returns null for null input', () {
      expect(FirstTaskOption.fromId(null), isNull);
    });

    test('each option has correct id and label', () {
      expect(FirstTaskOption.cook.id, equals('cook'));
      expect(FirstTaskOption.cook.label, equals('Cook Something'));
      expect(FirstTaskOption.fix.id, equals('fix'));
      expect(FirstTaskOption.fix.label, equals('Fix Something'));
      expect(FirstTaskOption.scan.id, equals('scan'));
      expect(FirstTaskOption.scan.label, equals('Scan My Device'));
      expect(FirstTaskOption.explore.id, equals('explore'));
      expect(FirstTaskOption.explore.label, equals('Just Explore'));
    });
  });

  group('OnboardingStatus model', () {
    test('initial factory creates default status', () {
      final status = OnboardingStatus.initial();

      expect(status.hasCompletedOnboarding, isFalse);
      expect(status.completedAt, isNull);
      expect(status.selectedFirstTask, isNull);
      expect(status.currentPage, equals(0));
    });

    test('completed factory creates completed status', () {
      final status = OnboardingStatus.completed(selectedFirstTask: 'cook');

      expect(status.hasCompletedOnboarding, isTrue);
      expect(status.completedAt, isNotNull);
      expect(status.selectedFirstTask, equals('cook'));
    });

    test('copyWith preserves unchanged fields', () {
      final original = OnboardingStatus(
        hasCompletedOnboarding: true,
        completedAt: DateTime(2024, 1, 1),
        selectedFirstTask: 'cook',
        currentPage: 2,
      );

      final copied = original.copyWith(currentPage: 3);

      expect(copied.hasCompletedOnboarding, isTrue);
      expect(copied.completedAt, equals(DateTime(2024, 1, 1)));
      expect(copied.selectedFirstTask, equals('cook'));
      expect(copied.currentPage, equals(3));
    });

    test('equality works correctly', () {
      final a = OnboardingStatus(
        hasCompletedOnboarding: true,
        completedAt: DateTime(2024, 1, 1),
        selectedFirstTask: 'cook',
        currentPage: 0,
      );
      final b = OnboardingStatus(
        hasCompletedOnboarding: true,
        completedAt: DateTime(2024, 1, 1),
        selectedFirstTask: 'cook',
        currentPage: 0,
      );
      final c = OnboardingStatus(
        hasCompletedOnboarding: false,
        currentPage: 0,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
