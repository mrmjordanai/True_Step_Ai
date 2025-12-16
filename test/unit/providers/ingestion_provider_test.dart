import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:truestep/shared/providers/ingestion_provider.dart';
import 'package:truestep/services/ingestion_service.dart';
import 'package:truestep/core/models/guide.dart';
import 'package:truestep/core/exceptions/app_exception.dart';

// Mock classes
class MockIngestionService extends Mock implements IngestionService {}

void main() {
  group('IngestionState', () {
    test('initial state is idle', () {
      const state = IngestionState.idle();
      expect(state.status, equals(IngestionStatus.idle));
      expect(state.guide, isNull);
      expect(state.error, isNull);
    });

    test('loading state has correct status', () {
      const state = IngestionState.loading();
      expect(state.status, equals(IngestionStatus.loading));
      expect(state.guide, isNull);
      expect(state.error, isNull);
    });

    test('success state contains guide', () {
      final guide = Guide(
        guideId: 'test-123',
        title: 'Test Guide',
        category: GuideCategory.culinary,
        steps: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final state = IngestionState.success(guide);

      expect(state.status, equals(IngestionStatus.success));
      expect(state.guide, equals(guide));
      expect(state.error, isNull);
    });

    test('error state contains exception', () {
      final exception = IngestionException.invalidUrl();
      final state = IngestionState.error(exception);

      expect(state.status, equals(IngestionStatus.error));
      expect(state.guide, isNull);
      expect(state.error, equals(exception));
    });

    test('isLoading returns true only for loading status', () {
      expect(const IngestionState.idle().isLoading, isFalse);
      expect(const IngestionState.loading().isLoading, isTrue);
      expect(
        IngestionState.success(Guide(
          guideId: 'test',
          title: 'Test',
          category: GuideCategory.culinary,
          steps: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )).isLoading,
        isFalse,
      );
      expect(
        IngestionState.error(IngestionException.invalidUrl()).isLoading,
        isFalse,
      );
    });

    test('hasError returns true only for error status', () {
      expect(const IngestionState.idle().hasError, isFalse);
      expect(const IngestionState.loading().hasError, isFalse);
      expect(
        IngestionState.error(IngestionException.invalidUrl()).hasError,
        isTrue,
      );
    });

    test('hasGuide returns true only when guide exists', () {
      expect(const IngestionState.idle().hasGuide, isFalse);
      expect(const IngestionState.loading().hasGuide, isFalse);

      final guide = Guide(
        guideId: 'test',
        title: 'Test',
        category: GuideCategory.culinary,
        steps: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(IngestionState.success(guide).hasGuide, isTrue);
    });
  });

  group('IngestionNotifier', () {
    late MockIngestionService mockService;
    late ProviderContainer container;
    late IngestionNotifier notifier;

    setUp(() {
      mockService = MockIngestionService();

      // Override the service provider
      container = ProviderContainer(
        overrides: [
          ingestionServiceProvider.overrideWithValue(mockService),
        ],
      );

      notifier = container.read(ingestionNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is idle', () {
      final state = container.read(ingestionNotifierProvider);
      expect(state.status, equals(IngestionStatus.idle));
    });

    test('ingest sets loading state then success state', () async {
      final guide = Guide(
        guideId: 'test-123',
        title: 'Test Guide',
        category: GuideCategory.culinary,
        steps: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add delay to mock so we can observe loading state
      when(() => mockService.ingest(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return guide;
      });

      // Start ingestion (don't await yet)
      final future = notifier.ingest('test input');

      // Give time for state to update to loading
      await Future.delayed(const Duration(milliseconds: 10));

      // Check loading state
      expect(
        container.read(ingestionNotifierProvider).status,
        equals(IngestionStatus.loading),
      );

      // Wait for completion
      await future;

      // Check success state
      final state = container.read(ingestionNotifierProvider);
      expect(state.status, equals(IngestionStatus.success));
      expect(state.guide, equals(guide));
    });

    test('ingest sets error state on exception', () async {
      final exception = IngestionException.invalidUrl('bad-url');

      when(() => mockService.ingest(any())).thenThrow(exception);

      await notifier.ingest('bad-url');

      final state = container.read(ingestionNotifierProvider);
      expect(state.status, equals(IngestionStatus.error));
      expect(state.error, equals(exception));
    });

    test('ingest wraps non-IngestionException in IngestionException', () async {
      when(() => mockService.ingest(any())).thenThrow(Exception('random error'));

      await notifier.ingest('input');

      final state = container.read(ingestionNotifierProvider);
      expect(state.status, equals(IngestionStatus.error));
      expect(state.error, isA<IngestionException>());
    });

    test('reset returns to idle state', () async {
      final guide = Guide(
        guideId: 'test',
        title: 'Test',
        category: GuideCategory.culinary,
        steps: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockService.ingest(any())).thenAnswer((_) async => guide);

      await notifier.ingest('input');
      expect(
        container.read(ingestionNotifierProvider).status,
        equals(IngestionStatus.success),
      );

      notifier.reset();

      expect(
        container.read(ingestionNotifierProvider).status,
        equals(IngestionStatus.idle),
      );
    });

    test('clearError returns to idle state from error', () async {
      when(() => mockService.ingest(any()))
          .thenThrow(IngestionException.invalidUrl());

      await notifier.ingest('bad input');
      expect(
        container.read(ingestionNotifierProvider).status,
        equals(IngestionStatus.error),
      );

      notifier.clearError();

      expect(
        container.read(ingestionNotifierProvider).status,
        equals(IngestionStatus.idle),
      );
    });

    test('multiple rapid calls only process the last one', () async {
      final guide1 = Guide(
        guideId: 'guide-1',
        title: 'Guide 1',
        category: GuideCategory.culinary,
        steps: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final guide2 = Guide(
        guideId: 'guide-2',
        title: 'Guide 2',
        category: GuideCategory.diy,
        steps: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // First call takes longer
      when(() => mockService.ingest('input1')).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return guide1;
      });

      // Second call is faster
      when(() => mockService.ingest('input2')).thenAnswer((_) async => guide2);

      // Start both calls
      notifier.ingest('input1');
      await Future.delayed(const Duration(milliseconds: 10));
      await notifier.ingest('input2');

      // Final state should be guide2
      final state = container.read(ingestionNotifierProvider);
      expect(state.guide?.guideId, equals('guide-2'));
    });
  });
}
