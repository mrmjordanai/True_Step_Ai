import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/exceptions/app_exception.dart' as app_exceptions;
import '../../../services/voice_service.dart';
import '../models/session_command.dart';

part 'voice_provider.g.dart';

/// Status of the voice service
enum VoiceStatus {
  /// Voice service not initialized
  uninitialized,

  /// Voice service is initializing
  initializing,

  /// Voice service is ready
  ready,

  /// Voice service is actively listening
  listening,

  /// Voice service is speaking via TTS
  speaking,

  /// An error occurred
  error,
}

/// State for voice management
class VoiceState {
  /// Current status
  final VoiceStatus status;

  /// Whether actively listening
  final bool isListening;

  /// Whether currently speaking
  final bool isSpeaking;

  /// Last recognized transcript
  final String lastTranscript;

  /// Last parsed command
  final SessionCommand? lastCommand;

  /// Error that occurred (if any)
  final app_exceptions.VoiceException? error;

  const VoiceState._({
    required this.status,
    this.isListening = false,
    this.isSpeaking = false,
    this.lastTranscript = '',
    this.lastCommand,
    this.error,
  });

  /// Create uninitialized state
  const VoiceState.uninitialized()
    : status = VoiceStatus.uninitialized,
      isListening = false,
      isSpeaking = false,
      lastTranscript = '',
      lastCommand = null,
      error = null;

  /// Create initializing state
  const VoiceState.initializing()
    : status = VoiceStatus.initializing,
      isListening = false,
      isSpeaking = false,
      lastTranscript = '',
      lastCommand = null,
      error = null;

  /// Create ready state
  const VoiceState.ready({
    String lastTranscript = '',
    SessionCommand? lastCommand,
  }) : status = VoiceStatus.ready,
       isListening = false,
       isSpeaking = false,
       lastTranscript = lastTranscript,
       lastCommand = lastCommand,
       error = null;

  /// Create listening state
  const VoiceState.listening({
    String lastTranscript = '',
    SessionCommand? lastCommand,
  }) : status = VoiceStatus.listening,
       isListening = true,
       isSpeaking = false,
       lastTranscript = lastTranscript,
       lastCommand = lastCommand,
       error = null;

  /// Create speaking state
  const VoiceState.speaking({
    String lastTranscript = '',
    SessionCommand? lastCommand,
  }) : status = VoiceStatus.speaking,
       isListening = false,
       isSpeaking = true,
       lastTranscript = lastTranscript,
       lastCommand = lastCommand,
       error = null;

  /// Create error state
  VoiceState.error(app_exceptions.VoiceException this.error)
    : status = VoiceStatus.error,
      isListening = false,
      isSpeaking = false,
      lastTranscript = '',
      lastCommand = null;

  /// Whether voice service is ready (ready, listening, or speaking)
  bool get isReady =>
      status == VoiceStatus.ready ||
      status == VoiceStatus.listening ||
      status == VoiceStatus.speaking;

  /// Whether an error occurred
  bool get hasError => status == VoiceStatus.error;

  /// Create a copy with updated values
  VoiceState copyWith({
    VoiceStatus? status,
    bool? isListening,
    bool? isSpeaking,
    String? lastTranscript,
    SessionCommand? lastCommand,
    app_exceptions.VoiceException? error,
  }) {
    return VoiceState._(
      status: status ?? this.status,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      lastTranscript: lastTranscript ?? this.lastTranscript,
      lastCommand: lastCommand ?? this.lastCommand,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceState &&
        other.status == status &&
        other.isListening == isListening &&
        other.isSpeaking == isSpeaking &&
        other.lastTranscript == lastTranscript &&
        other.lastCommand == lastCommand &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
    status,
    isListening,
    isSpeaking,
    lastTranscript,
    lastCommand,
    error,
  );
}

/// Provider for voice service (can be overridden in tests)
@riverpod
VoiceService voiceService(VoiceServiceRef ref) {
  return VoiceService();
}

/// Notifier for managing voice state
@Riverpod(keepAlive: true)
class VoiceNotifier extends _$VoiceNotifier {
  VoiceService get _service => ref.read(voiceServiceProvider);

  @override
  VoiceState build() => const VoiceState.uninitialized();

  /// Initialize the voice service
  Future<void> initialize() async {
    if (state.status == VoiceStatus.initializing ||
        state.status == VoiceStatus.ready ||
        state.status == VoiceStatus.listening ||
        state.status == VoiceStatus.speaking) {
      return;
    }

    state = const VoiceState.initializing();

    try {
      await _service.initialize();
      state = const VoiceState.ready();
    } on app_exceptions.VoiceException catch (e) {
      state = VoiceState.error(e);
    } catch (e) {
      state = VoiceState.error(
        app_exceptions.VoiceException(
          e.toString(),
          code: 'unknown_error',
          originalError: e,
        ),
      );
    }
  }

  /// Start listening for voice input
  Future<void> startListening() async {
    _ensureReady();

    await _service.startListening();
    state = VoiceState.listening(
      lastTranscript: state.lastTranscript,
      lastCommand: state.lastCommand,
    );
  }

  /// Stop listening for voice input
  Future<void> stopListening() async {
    if (!state.isListening) return;

    await _service.stopListening();
    state = VoiceState.ready(
      lastTranscript: state.lastTranscript,
      lastCommand: state.lastCommand,
    );
  }

  /// Speak the given text via TTS
  Future<void> speak(String text) async {
    _ensureReady();

    state = VoiceState.speaking(
      lastTranscript: state.lastTranscript,
      lastCommand: state.lastCommand,
    );

    await _service.speak(text);

    // Return to ready state after speaking completes
    state = VoiceState.ready(
      lastTranscript: state.lastTranscript,
      lastCommand: state.lastCommand,
    );
  }

  /// Stop any ongoing TTS playback
  Future<void> stopSpeaking() async {
    await _service.stopSpeaking();
    if (state.isSpeaking) {
      state = VoiceState.ready(
        lastTranscript: state.lastTranscript,
        lastCommand: state.lastCommand,
      );
    }
  }

  /// Set the TTS volume
  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
  }

  /// Set the TTS speech rate
  Future<void> setSpeechRate(double rate) async {
    await _service.setSpeechRate(rate);
  }

  /// Parse a transcript into a SessionCommand
  SessionCommand? parseCommand(String transcript) {
    final command = _service.parseCommand(transcript);
    if (command != null) {
      state = state.copyWith(lastTranscript: transcript, lastCommand: command);
    }
    return command;
  }

  /// Update the last transcript
  void updateTranscript(String transcript) {
    state = state.copyWith(lastTranscript: transcript);
  }

  /// Dispose the voice service resources
  Future<void> disposeVoice() async {
    await _service.dispose();
    state = const VoiceState.uninitialized();
  }

  /// Clear error and return to uninitialized state
  void clearError() {
    if (state.hasError) {
      state = const VoiceState.uninitialized();
    }
  }

  /// Ensure voice service is ready before operations
  void _ensureReady() {
    if (!state.isReady) {
      throw StateError(
        'Voice service is not ready. Current status: ${state.status}',
      );
    }
  }
}

/// Provider for voice transcript stream
@riverpod
Stream<VoiceTranscript> voiceTranscriptStream(VoiceTranscriptStreamRef ref) {
  final service = ref.watch(voiceServiceProvider);
  return service.transcriptStream;
}
