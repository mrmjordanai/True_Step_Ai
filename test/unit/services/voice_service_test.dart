import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'package:truestep/services/voice_service.dart';
import 'package:truestep/core/exceptions/app_exception.dart' as app_exceptions;
import 'package:truestep/features/session/models/session_command.dart';

// Mock classes
class MockSpeechToText extends Mock implements stt.SpeechToText {}

class MockFlutterTts extends Mock implements FlutterTts {}

void main() {
  group('VoiceService', () {
    late VoiceService service;
    late MockSpeechToText mockStt;
    late MockFlutterTts mockTts;

    setUp(() {
      mockStt = MockSpeechToText();
      mockTts = MockFlutterTts();

      // Default stubs for initialization
      when(() => mockStt.initialize(
            onStatus: any(named: 'onStatus'),
            onError: any(named: 'onError'),
          )).thenAnswer((_) async => true);
      when(() => mockStt.hasPermission).thenAnswer((_) async => true);
      when(() => mockStt.isAvailable).thenReturn(true);
      when(() => mockStt.isListening).thenReturn(false);
      when(() => mockTts.setLanguage(any())).thenAnswer((_) async => 1);
      when(() => mockTts.setSpeechRate(any())).thenAnswer((_) async => 1);
      when(() => mockTts.setVolume(any())).thenAnswer((_) async => 1);
      when(() => mockTts.awaitSpeakCompletion(any()))
          .thenAnswer((_) async => 1);
      when(() => mockTts.stop()).thenAnswer((_) async => 1);
      when(() => mockStt.stop()).thenAnswer((_) async {});
      when(() => mockStt.cancel()).thenAnswer((_) async {});

      service = VoiceService.forTesting(
        speechToText: mockStt,
        flutterTts: mockTts,
      );
    });

    tearDown(() async {
      if (service.isInitialized) {
        await service.dispose();
      }
    });

    group('initialization', () {
      test('initializes STT and TTS engines successfully', () async {
        await service.initialize();

        expect(service.isInitialized, isTrue);
        verify(() => mockStt.initialize(
              onStatus: any(named: 'onStatus'),
              onError: any(named: 'onError'),
            )).called(1);
      });

      test('throws VoiceException.sttNotAvailable when STT unavailable',
          () async {
        when(() => mockStt.initialize(
              onStatus: any(named: 'onStatus'),
              onError: any(named: 'onError'),
            )).thenAnswer((_) async => false);

        expect(
          () => service.initialize(),
          throwsA(isA<app_exceptions.VoiceException>().having(
            (e) => e.code,
            'code',
            equals('stt_not_available'),
          )),
        );
      });

      test('is idempotent - second initialize is no-op', () async {
        await service.initialize();
        await service.initialize();

        verify(() => mockStt.initialize(
              onStatus: any(named: 'onStatus'),
              onError: any(named: 'onError'),
            )).called(1);
      });
    });

    group('speech-to-text', () {
      setUp(() async {
        await service.initialize();
      });

      test('startListening starts speech recognition', () async {
        when(() => mockStt.listen(
              onResult: any(named: 'onResult'),
              listenFor: any(named: 'listenFor'),
              pauseFor: any(named: 'pauseFor'),
              localeId: any(named: 'localeId'),
              listenOptions: any(named: 'listenOptions'),
            )).thenAnswer((_) async {});

        await service.startListening();

        expect(service.isListening, isTrue);
        verify(() => mockStt.listen(
              onResult: any(named: 'onResult'),
              listenFor: any(named: 'listenFor'),
              pauseFor: any(named: 'pauseFor'),
              localeId: any(named: 'localeId'),
              listenOptions: any(named: 'listenOptions'),
            )).called(1);
      });

      test('stopListening stops speech recognition', () async {
        when(() => mockStt.listen(
              onResult: any(named: 'onResult'),
              listenFor: any(named: 'listenFor'),
              pauseFor: any(named: 'pauseFor'),
              localeId: any(named: 'localeId'),
              listenOptions: any(named: 'listenOptions'),
            )).thenAnswer((_) async {});

        await service.startListening();
        await service.stopListening();

        expect(service.isListening, isFalse);
        verify(() => mockStt.stop()).called(1);
      });

      test('transcriptStream provides voice transcripts', () async {
        expect(service.transcriptStream, isA<Stream<VoiceTranscript>>());
      });

      test('throws when starting listening without initialization', () {
        final uninitService = VoiceService.forTesting(
          speechToText: mockStt,
          flutterTts: mockTts,
        );

        expect(
          () => uninitService.startListening(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('text-to-speech', () {
      setUp(() async {
        await service.initialize();
      });

      test('speak speaks the given text', () async {
        when(() => mockTts.speak(any())).thenAnswer((_) async => 1);

        await service.speak('Hello world');

        verify(() => mockTts.speak('Hello world')).called(1);
      });

      test('stopSpeaking stops TTS playback', () async {
        when(() => mockTts.speak(any())).thenAnswer((_) async => 1);

        await service.speak('Hello world');
        await service.stopSpeaking();

        verify(() => mockTts.stop()).called(1);
      });

      test('setVolume changes TTS volume', () async {
        await service.setVolume(0.5);

        verify(() => mockTts.setVolume(0.5)).called(1);
      });

      test('setSpeechRate changes TTS speed', () async {
        await service.setSpeechRate(1.5);

        verify(() => mockTts.setSpeechRate(1.5)).called(1);
      });

      test('isSpeaking reflects TTS state', () async {
        expect(service.isSpeaking, isFalse);
      });

      test('throws when speaking without initialization', () {
        final uninitService = VoiceService.forTesting(
          speechToText: mockStt,
          flutterTts: mockTts,
        );

        expect(
          () => uninitService.speak('test'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('command parsing', () {
      test('parseCommand recognizes "next" as nextStep', () {
        final command = service.parseCommand('next');
        expect(command, equals(SessionCommand.nextStep));
      });

      test('parseCommand recognizes "next step" as nextStep', () {
        final command = service.parseCommand('next step');
        expect(command, equals(SessionCommand.nextStep));
      });

      test('parseCommand recognizes "back" as previousStep', () {
        final command = service.parseCommand('back');
        expect(command, equals(SessionCommand.previousStep));
      });

      test('parseCommand recognizes "go back" as previousStep', () {
        final command = service.parseCommand('go back');
        expect(command, equals(SessionCommand.previousStep));
      });

      test('parseCommand recognizes "repeat" as repeatInstruction', () {
        final command = service.parseCommand('repeat');
        expect(command, equals(SessionCommand.repeatInstruction));
      });

      test('parseCommand recognizes "pause" as pause', () {
        final command = service.parseCommand('pause');
        expect(command, equals(SessionCommand.pause));
      });

      test('parseCommand recognizes "resume" as resume', () {
        final command = service.parseCommand('resume');
        expect(command, equals(SessionCommand.resume));
      });

      test('parseCommand recognizes "stop" as stop', () {
        final command = service.parseCommand('stop');
        expect(command, equals(SessionCommand.stop));
      });

      test('parseCommand recognizes "help" as help', () {
        final command = service.parseCommand('help');
        expect(command, equals(SessionCommand.help));
      });

      test('parseCommand is case insensitive', () {
        expect(service.parseCommand('NEXT'), equals(SessionCommand.nextStep));
        expect(service.parseCommand('Next'), equals(SessionCommand.nextStep));
        expect(service.parseCommand('nExT'), equals(SessionCommand.nextStep));
      });

      test('parseCommand returns null for unrecognized input', () {
        final command = service.parseCommand('hello world');
        expect(command, isNull);
      });

      test('parseCommand extracts command from sentence', () {
        final command = service.parseCommand('please go back now');
        expect(command, equals(SessionCommand.previousStep));
      });
    });

    group('lifecycle', () {
      test('disposes STT and TTS on dispose', () async {
        await service.initialize();
        await service.dispose();

        expect(service.isInitialized, isFalse);
      });

      test('stops listening on dispose if active', () async {
        when(() => mockStt.listen(
              onResult: any(named: 'onResult'),
              listenFor: any(named: 'listenFor'),
              pauseFor: any(named: 'pauseFor'),
              localeId: any(named: 'localeId'),
              listenOptions: any(named: 'listenOptions'),
            )).thenAnswer((_) async {});

        await service.initialize();
        await service.startListening();
        await service.dispose();

        verify(() => mockStt.stop()).called(1);
      });

      test('ensureInitialized throws when not initialized', () {
        final uninitService = VoiceService.forTesting(
          speechToText: mockStt,
          flutterTts: mockTts,
        );

        expect(
          () => uninitService.ensureInitialized(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('getters', () {
      setUp(() async {
        await service.initialize();
      });

      test('isListening returns false initially', () {
        expect(service.isListening, isFalse);
      });

      test('isSpeaking returns false initially', () {
        expect(service.isSpeaking, isFalse);
      });

      test('lastTranscript is empty initially', () {
        expect(service.lastTranscript, isEmpty);
      });
    });
  });

  group('VoiceTranscript', () {
    test('holds correct data', () {
      final transcript = VoiceTranscript(
        text: 'hello world',
        confidence: 0.95,
        isFinal: true,
        timestamp: DateTime(2024, 1, 1),
      );

      expect(transcript.text, equals('hello world'));
      expect(transcript.confidence, equals(0.95));
      expect(transcript.isFinal, isTrue);
      expect(transcript.timestamp, equals(DateTime(2024, 1, 1)));
    });
  });
}
