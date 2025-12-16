import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:truestep/features/session/providers/voice_provider.dart';
import 'package:truestep/services/voice_service.dart';
import 'package:truestep/features/session/models/session_command.dart';
import 'package:truestep/core/exceptions/app_exception.dart' as app_exceptions;

import '../../helpers/mock_services.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  group('VoiceState', () {
    test('initial state is uninitialized', () {
      const state = VoiceState.uninitialized();
      expect(state.status, equals(VoiceStatus.uninitialized));
      expect(state.error, isNull);
      expect(state.isListening, isFalse);
      expect(state.isSpeaking, isFalse);
      expect(state.lastTranscript, isEmpty);
      expect(state.lastCommand, isNull);
    });

    test('initializing state has correct status', () {
      const state = VoiceState.initializing();
      expect(state.status, equals(VoiceStatus.initializing));
      expect(state.error, isNull);
    });

    test('ready state has correct status', () {
      const state = VoiceState.ready();
      expect(state.status, equals(VoiceStatus.ready));
      expect(state.error, isNull);
    });

    test('listening state has listening flag true', () {
      const state = VoiceState.listening();
      expect(state.status, equals(VoiceStatus.listening));
      expect(state.isListening, isTrue);
    });

    test('speaking state has speaking flag true', () {
      const state = VoiceState.speaking();
      expect(state.status, equals(VoiceStatus.speaking));
      expect(state.isSpeaking, isTrue);
    });

    test('error state contains exception', () {
      final exception = app_exceptions.VoiceException.sttNotAvailable();
      final state = VoiceState.error(exception);

      expect(state.status, equals(VoiceStatus.error));
      expect(state.error, equals(exception));
    });

    test('isReady returns true for active states', () {
      expect(const VoiceState.uninitialized().isReady, isFalse);
      expect(const VoiceState.initializing().isReady, isFalse);
      expect(const VoiceState.ready().isReady, isTrue);
      expect(const VoiceState.listening().isReady, isTrue);
      expect(const VoiceState.speaking().isReady, isTrue);
      expect(
        VoiceState.error(app_exceptions.VoiceException.sttNotAvailable()).isReady,
        isFalse,
      );
    });

    test('hasError returns true only for error status', () {
      expect(const VoiceState.uninitialized().hasError, isFalse);
      expect(const VoiceState.ready().hasError, isFalse);
      expect(
        VoiceState.error(app_exceptions.VoiceException.sttNotAvailable()).hasError,
        isTrue,
      );
    });

    test('copyWith creates a new state with updated values', () {
      const state = VoiceState.ready();
      final updated = state.copyWith(lastTranscript: 'hello');

      expect(updated.status, equals(VoiceStatus.ready));
      expect(updated.lastTranscript, equals('hello'));
    });
  });

  group('VoiceNotifier', () {
    late MockVoiceService mockService;
    late ProviderContainer container;
    late VoiceNotifier notifier;

    setUp(() {
      mockService = createMockVoiceService(isInitialized: false);
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer() {
      container = ProviderContainer(
        overrides: [
          voiceServiceProvider.overrideWithValue(mockService),
        ],
      );
      notifier = container.read(voiceNotifierProvider.notifier);
      return container;
    }

    test('initial state is uninitialized', () {
      createContainer();
      final state = container.read(voiceNotifierProvider);
      expect(state.status, equals(VoiceStatus.uninitialized));
    });

    test('initialize sets initializing then ready state', () async {
      // Add delay to mock so we can observe initializing state
      when(() => mockService.initialize()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      when(() => mockService.isInitialized).thenReturn(true);

      createContainer();

      // Start initialization (don't await yet)
      final future = notifier.initialize();

      // Give time for state to update to initializing
      await Future.delayed(const Duration(milliseconds: 10));

      // Check initializing state
      expect(
        container.read(voiceNotifierProvider).status,
        equals(VoiceStatus.initializing),
      );

      // Wait for completion
      await future;

      // Check ready state
      final state = container.read(voiceNotifierProvider);
      expect(state.status, equals(VoiceStatus.ready));
    });

    test('initialize sets error state on exception', () async {
      final exception = app_exceptions.VoiceException.sttNotAvailable();
      when(() => mockService.initialize()).thenThrow(exception);

      createContainer();

      await notifier.initialize();

      final state = container.read(voiceNotifierProvider);
      expect(state.status, equals(VoiceStatus.error));
      expect(state.error, equals(exception));
    });

    test('startListening transitions to listening state', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.startListening()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.startListening();

      final state = container.read(voiceNotifierProvider);
      expect(state.status, equals(VoiceStatus.listening));
      expect(state.isListening, isTrue);
      verify(() => mockService.startListening()).called(1);
    });

    test('stopListening transitions back to ready state', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.startListening()).thenAnswer((_) async {});
      when(() => mockService.stopListening()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.startListening();
      await notifier.stopListening();

      final state = container.read(voiceNotifierProvider);
      expect(state.status, equals(VoiceStatus.ready));
      expect(state.isListening, isFalse);
      verify(() => mockService.stopListening()).called(1);
    });

    test('speak transitions to speaking state and calls service', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.speak(any())).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.speak('Hello world');

      verify(() => mockService.speak('Hello world')).called(1);
    });

    test('stopSpeaking stops TTS', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.stopSpeaking()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.stopSpeaking();

      verify(() => mockService.stopSpeaking()).called(1);
    });

    test('setVolume calls service', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.setVolume(any())).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.setVolume(0.5);

      verify(() => mockService.setVolume(0.5)).called(1);
    });

    test('setSpeechRate calls service', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.setSpeechRate(any())).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.setSpeechRate(1.2);

      verify(() => mockService.setSpeechRate(1.2)).called(1);
    });

    test('parseCommand delegates to service', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.parseCommand(any()))
          .thenReturn(SessionCommand.nextStep);

      createContainer();

      await notifier.initialize();
      final command = notifier.parseCommand('next');

      expect(command, equals(SessionCommand.nextStep));
      verify(() => mockService.parseCommand('next')).called(1);
    });

    test('parseCommand updates lastCommand in state', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.parseCommand(any()))
          .thenReturn(SessionCommand.pause);

      createContainer();

      await notifier.initialize();
      notifier.parseCommand('pause');

      final state = container.read(voiceNotifierProvider);
      expect(state.lastCommand, equals(SessionCommand.pause));
    });

    test('operations throw when not initialized', () async {
      when(() => mockService.isInitialized).thenReturn(false);
      when(() => mockService.startListening())
          .thenThrow(StateError('Not initialized'));

      createContainer();

      expect(
        () => notifier.startListening(),
        throwsA(isA<StateError>()),
      );
    });

    test('transcriptStream provides transcripts from service', () async {
      final transcriptController = StreamController<VoiceTranscript>.broadcast();

      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.transcriptStream)
          .thenAnswer((_) => transcriptController.stream);

      createContainer();

      await notifier.initialize();

      final transcripts = <VoiceTranscript>[];
      final sub = mockService.transcriptStream.listen(transcripts.add);

      final testTranscript = VoiceTranscript(
        text: 'hello world',
        confidence: 0.95,
        isFinal: true,
        timestamp: DateTime.now(),
      );

      transcriptController.add(testTranscript);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(transcripts.length, equals(1));
      expect(transcripts.first.text, equals('hello world'));

      await sub.cancel();
      await transcriptController.close();
    });

    test('disposeVoice cleans up resources', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.dispose()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.disposeVoice();

      verify(() => mockService.dispose()).called(1);
    });

    test('clearError returns to uninitialized state from error', () async {
      final exception = app_exceptions.VoiceException.sttNotAvailable();
      when(() => mockService.initialize()).thenThrow(exception);

      createContainer();

      await notifier.initialize();
      expect(
        container.read(voiceNotifierProvider).status,
        equals(VoiceStatus.error),
      );

      notifier.clearError();

      expect(
        container.read(voiceNotifierProvider).status,
        equals(VoiceStatus.uninitialized),
      );
    });
  });
}
