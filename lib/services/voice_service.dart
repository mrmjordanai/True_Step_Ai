import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'base_service.dart';
import '../core/exceptions/app_exception.dart';
import '../features/session/models/session_command.dart';

/// A voice transcript from speech recognition
class VoiceTranscript {
  /// The recognized text
  final String text;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Whether this is the final result
  final bool isFinal;

  /// When the transcript was received
  final DateTime timestamp;

  const VoiceTranscript({
    required this.text,
    required this.confidence,
    required this.isFinal,
    required this.timestamp,
  });
}

/// Service for voice input/output
///
/// Handles speech-to-text, text-to-speech, and voice command
/// processing for hands-free session control.
class VoiceService extends BaseService {
  /// Speech-to-text instance
  final stt.SpeechToText _speechToText;

  /// Text-to-speech instance
  final FlutterTts _flutterTts;

  /// Stream controller for voice transcripts
  final StreamController<VoiceTranscript> _transcriptController =
      StreamController<VoiceTranscript>.broadcast();

  /// Whether currently listening for speech
  bool _isListening = false;

  /// Whether currently speaking via TTS
  bool _isSpeaking = false;

  /// Last recognized transcript
  String _lastTranscript = '';

  /// Creates a new VoiceService
  VoiceService()
      : _speechToText = stt.SpeechToText(),
        _flutterTts = FlutterTts();

  /// Creates a VoiceService for testing with injected dependencies
  @visibleForTesting
  VoiceService.forTesting({
    required stt.SpeechToText speechToText,
    required FlutterTts flutterTts,
  })  : _speechToText = speechToText,
        _flutterTts = flutterTts;

  /// Stream of voice transcripts from speech recognition
  Stream<VoiceTranscript> get transcriptStream => _transcriptController.stream;

  /// Whether the service is currently listening for speech
  bool get isListening => _isListening;

  /// Whether the service is currently speaking via TTS
  bool get isSpeaking => _isSpeaking;

  /// The last recognized transcript text
  String get lastTranscript => _lastTranscript;

  @override
  Future<void> onInitialize() async {
    // Initialize speech-to-text
    final sttAvailable = await _speechToText.initialize(
      onStatus: _onSttStatus,
      onError: _onSttError,
    );

    if (!sttAvailable) {
      throw VoiceException.sttNotAvailable();
    }

    // Initialize text-to-speech
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    // Set up TTS completion handler
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  @override
  Future<void> onDispose() async {
    if (_isListening) {
      await stopListening();
    }
    await _flutterTts.stop();
    await _transcriptController.close();
  }

  /// Start listening for speech input (push-to-talk)
  Future<void> startListening() async {
    ensureInitialized();

    if (_isListening) return;

    _isListening = true;

    await _speechToText.listen(
      onResult: _onSttResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
      ),
    );
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    await _speechToText.stop();
  }

  /// Speak the given text via TTS
  Future<void> speak(String text) async {
    ensureInitialized();

    _isSpeaking = true;
    await _flutterTts.speak(text);
  }

  /// Stop any ongoing TTS playback
  Future<void> stopSpeaking() async {
    _isSpeaking = false;
    await _flutterTts.stop();
  }

  /// Set the TTS volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Set the TTS speech rate (0.0 to 2.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 2.0));
  }

  /// Parse a transcript into a SessionCommand
  ///
  /// Returns null if no command is recognized.
  SessionCommand? parseCommand(String transcript) {
    return CommandParser.parse(transcript);
  }

  /// Handle STT status changes
  void _onSttStatus(String status) {
    if (status == 'notListening') {
      _isListening = false;
    }
  }

  /// Handle STT errors
  void _onSttError(dynamic error) {
    _isListening = false;
    // Errors are handled via the stream - we don't throw here
    // to avoid unhandled exceptions in callback context
  }

  /// Handle STT results
  void _onSttResult(dynamic result) {
    _lastTranscript = result.recognizedWords;

    final transcript = VoiceTranscript(
      text: result.recognizedWords,
      confidence: result.confidence,
      isFinal: result.finalResult,
      timestamp: DateTime.now(),
    );

    if (!_transcriptController.isClosed) {
      _transcriptController.add(transcript);
    }
  }
}
