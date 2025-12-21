import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/guide.dart';
import 'session_state.dart';

part 'session_data.freezed.dart';
part 'session_data.g.dart';

/// Converter for Map<int, VerificationResult> with string keys in JSON
class VerificationResultMapConverter
    implements
        JsonConverter<Map<int, VerificationResult>, Map<String, dynamic>> {
  const VerificationResultMapConverter();

  @override
  Map<int, VerificationResult> fromJson(Map<String, dynamic> json) {
    return json.map(
      (k, v) => MapEntry(
        int.parse(k),
        VerificationResult.fromJson(v as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<int, VerificationResult> map) {
    return map.map((k, v) => MapEntry(k.toString(), v.toJson()));
  }
}

/// Complete session data including guide, progress, and results
///
/// This is the main state object managed by SessionNotifier.
@freezed
class SessionData with _$SessionData {
  const SessionData._();

  const factory SessionData({
    /// The guide being executed
    required Guide guide,

    /// Current session lifecycle phase
    @Default(SessionPhase.calibrating) SessionPhase phase,

    /// Traffic light state (only relevant when phase == active)
    @Default(SentinelState.watching) SentinelState sentinelState,

    /// Current step index (0-based)
    @Default(0) int currentStepIndex,

    /// Total elapsed time in seconds
    @Default(0) int elapsedSeconds,

    /// Per-step verification results (stepIndex -> result)
    @VerificationResultMapConverter()
    @Default({})
    Map<int, VerificationResult> stepResults,

    /// Number of interventions triggered during session
    @Default(0) int interventionCount,

    /// Whether recording is active
    @Default(false) bool isRecording,

    /// Current intervention message (when sentinelState == intervention)
    String? interventionMessage,

    /// Timestamp when session started
    required DateTime startTime,

    /// Whether calibration was skipped
    @Default(false) bool calibrationSkipped,

    /// Tools that have been checked off
    @Default({}) Set<String> checkedTools,

    /// Retry count for current step verification (resets on step advance)
    @Default(0) int currentStepRetryCount,

    /// Whether manual skip option should be shown (after max retries)
    @Default(false) bool showManualSkipOption,
  }) = _SessionData;

  /// Create initial session data for a guide
  factory SessionData.start(Guide guide) {
    return SessionData(guide: guide, startTime: DateTime.now());
  }

  // Computed properties

  /// Current step being executed
  GuideStep get currentStep => guide.steps[currentStepIndex];

  /// Whether currently on the last step
  bool get isLastStep => currentStepIndex >= guide.steps.length - 1;

  /// Whether currently on the first step
  bool get isFirstStep => currentStepIndex <= 0;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercent =>
      guide.steps.isEmpty ? 0.0 : (currentStepIndex + 1) / guide.steps.length;

  /// Number of steps completed (verified)
  int get stepsCompleted => stepResults.values.where((r) => r.verified).length;

  /// Average confidence score across verified steps
  double get averageConfidence {
    final verified = stepResults.values.where((r) => r.verified).toList();
    if (verified.isEmpty) return 0.0;
    return verified.map((r) => r.confidence).reduce((a, b) => a + b) /
        verified.length;
  }

  /// Whether the session is in an active state (not paused/completed/cancelled)
  bool get isActive =>
      phase == SessionPhase.active ||
      phase == SessionPhase.calibrating ||
      phase == SessionPhase.toolAudit;

  /// Whether all required tools are checked
  bool get allToolsChecked {
    final requiredTools = guide.steps.expand((step) => step.tools).toSet();
    return requiredTools.every((tool) => checkedTools.contains(tool));
  }

  /// Create a copy with intervention message cleared
  SessionData clearIntervention() {
    return copyWith(
      interventionMessage: null,
      sentinelState: SentinelState.watching,
    );
  }

  /// Create a copy with retry state reset
  SessionData resetRetryState() {
    return copyWith(
      currentStepRetryCount: 0,
      showManualSkipOption: false,
    );
  }

  factory SessionData.fromJson(Map<String, dynamic> json) =>
      _$SessionDataFromJson(json);
}

/// Summary of a completed session
@freezed
class SessionSummary with _$SessionSummary {
  const SessionSummary._();

  const factory SessionSummary({
    /// The guide that was executed
    required Guide guide,

    /// Total duration in seconds
    required int totalDurationSeconds,

    /// Number of steps completed
    required int stepsCompleted,

    /// Total number of steps
    required int totalSteps,

    /// Number of interventions triggered
    required int interventionCount,

    /// Average AI confidence score
    required double averageConfidence,

    /// Whether session was completed (vs cancelled)
    required bool wasCompleted,

    /// Session start time
    required DateTime startTime,

    /// Session end time
    required DateTime endTime,

    /// Per-step results
    @VerificationResultMapConverter()
    @Default({})
    Map<int, VerificationResult> stepResults,
  }) = _SessionSummary;

  /// Create summary from session data
  factory SessionSummary.fromSession(SessionData session) {
    final endTime = DateTime.now();
    return SessionSummary(
      guide: session.guide,
      totalDurationSeconds: session.elapsedSeconds,
      stepsCompleted: session.stepsCompleted,
      totalSteps: session.guide.steps.length,
      interventionCount: session.interventionCount,
      averageConfidence: session.averageConfidence,
      wasCompleted: session.phase == SessionPhase.completed,
      startTime: session.startTime,
      endTime: endTime,
      stepResults: session.stepResults,
    );
  }

  /// Completion percentage
  double get completionPercent =>
      totalSteps == 0 ? 0.0 : stepsCompleted / totalSteps;

  /// Format duration as "Xm Ys"
  String get formattedDuration {
    final minutes = totalDurationSeconds ~/ 60;
    final seconds = totalDurationSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  factory SessionSummary.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryFromJson(json);
}
