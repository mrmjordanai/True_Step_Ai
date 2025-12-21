import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// Converter for Firestore Timestamps
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    return DateTime.parse(json as String);
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Converter for nullable Firestore Timestamps
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) {
      return json.toDate();
    }
    return DateTime.parse(json as String);
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

/// Converter for Map<int, String> with string keys in JSON
class IntStringMapConverter
    implements JsonConverter<Map<int, String>, Map<String, dynamic>> {
  const IntStringMapConverter();

  @override
  Map<int, String> fromJson(Map<String, dynamic> json) {
    return json.map((k, v) => MapEntry(int.parse(k), v as String));
  }

  @override
  Map<String, dynamic> toJson(Map<int, String> map) {
    return map.map((k, v) => MapEntry(k.toString(), v));
  }
}

/// Input method used to create the guide
@JsonEnum(alwaysCreate: true)
enum InputMethod {
  url,
  text,
  voice,
  image;

  String toJson() => name;

  static InputMethod fromJson(String json) {
    return InputMethod.values.firstWhere(
      (m) => m.name == json,
      orElse: () => InputMethod.text,
    );
  }
}

/// Log entry for a single step in a session
@freezed
class StepLog with _$StepLog {
  const factory StepLog({
    /// Step index (0-based)
    required int stepIndex,

    /// Whether the step was verified successfully
    required bool verified,

    /// Confidence score from AI verification
    required double confidence,

    /// Time spent on this step in seconds
    required int durationSeconds,

    /// Number of verification attempts
    @Default(1) int attempts,

    /// Whether a safety alert was triggered
    @Default(false) bool safetyAlert,

    /// Timestamp when step was completed
    required DateTime completedAt,

    /// Path to step verification clip (if recorded)
    String? clipPath,
  }) = _StepLog;

  factory StepLog.fromJson(Map<String, dynamic> json) =>
      _$StepLogFromJson(json);
}

/// Recording metadata for a session
@freezed
class Recording with _$Recording {
  const factory Recording({
    /// URL to full session video in Firebase Storage
    required String fullSessionUrl,

    /// Total duration in seconds
    required int durationSeconds,

    /// File size in bytes
    required int sizeBytes,

    /// Retention period in days (default 30)
    @Default(30) int retentionDays,

    /// URLs to per-step clips
    @IntStringMapConverter()
    @Default({})
    Map<int, String> stepClipUrls,
  }) = _Recording;

  factory Recording.fromJson(Map<String, dynamic> json) =>
      _$RecordingFromJson(json);
}

/// A completed session stored in Firestore
@freezed
class Session with _$Session {
  const Session._();

  const factory Session({
    /// Unique session identifier
    required String sessionId,

    /// User who completed the session
    required String userId,

    /// Guide that was executed
    required String guideId,

    /// Guide title for display
    required String guideTitle,

    /// How the guide was created
    required InputMethod inputMethod,

    /// When session started
    @TimestampConverter() required DateTime startedAt,

    /// When session completed (null if cancelled)
    @NullableTimestampConverter() DateTime? completedAt,

    /// When session data expires (startedAt + 30 days)
    @TimestampConverter() required DateTime expiresAt,

    /// Total steps in the guide
    required int totalSteps,

    /// Steps completed successfully
    required int stepsCompleted,

    /// Recording data (if recorded)
    Recording? recording,

    /// Per-step logs
    @Default([]) List<StepLog> stepLogs,

    /// Total interventions triggered
    @Default(0) int interventionCount,

    /// Average verification confidence
    @Default(0.0) double averageConfidence,
  }) = _Session;

  /// Whether session was completed (vs cancelled)
  bool get wasCompleted => completedAt != null;

  /// Whether session has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Duration in seconds
  int get durationSeconds {
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt).inSeconds;
  }

  /// Completion percentage
  double get completionPercent =>
      totalSteps == 0 ? 0.0 : stepsCompleted / totalSteps;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
