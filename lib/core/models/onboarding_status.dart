import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'onboarding_status.freezed.dart';
part 'onboarding_status.g.dart';

/// Onboarding completion status stored locally via Hive
///
/// Tracks whether the user has completed the onboarding flow
/// and stores their first task selection for personalization.
@freezed
class OnboardingStatus with _$OnboardingStatus {
  const OnboardingStatus._();

  const factory OnboardingStatus({
    /// Whether the user has completed the onboarding flow
    @Default(false) bool hasCompletedOnboarding,

    /// When the onboarding was completed
    DateTime? completedAt,

    /// The first task the user selected (cook, fix, scan, explore)
    String? selectedFirstTask,

    /// Current page index in the welcome carousel
    @Default(0) int currentPage,
  }) = _OnboardingStatus;

  /// Default empty status for new users
  factory OnboardingStatus.initial() => const OnboardingStatus();

  /// Create a completed status
  factory OnboardingStatus.completed({String? selectedFirstTask}) =>
      OnboardingStatus(
        hasCompletedOnboarding: true,
        completedAt: DateTime.now(),
        selectedFirstTask: selectedFirstTask,
        currentPage: 0,
      );

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStatusFromJson(json);
}

/// First task options available during onboarding
enum FirstTaskOption {
  cook('cook', 'Cook Something'),
  fix('fix', 'Fix Something'),
  scan('scan', 'Scan My Device'),
  explore('explore', 'Just Explore');

  const FirstTaskOption(this.id, this.label);

  final String id;
  final String label;

  /// Get option by ID
  static FirstTaskOption? fromId(String? id) {
    if (id == null) return null;
    return FirstTaskOption.values.cast<FirstTaskOption?>().firstWhere(
          (option) => option?.id == id,
          orElse: () => null,
        );
  }
}

/// Hive TypeAdapter for OnboardingStatus
///
/// Manually serializes the Freezed class for Hive storage.
class OnboardingStatusAdapter extends TypeAdapter<OnboardingStatus> {
  @override
  final int typeId = 0;

  @override
  OnboardingStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OnboardingStatus(
      hasCompletedOnboarding: fields[0] as bool? ?? false,
      completedAt: fields[1] as DateTime?,
      selectedFirstTask: fields[2] as String?,
      currentPage: fields[3] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, OnboardingStatus obj) {
    writer
      ..writeByte(4) // number of fields
      ..writeByte(0)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(1)
      ..write(obj.completedAt)
      ..writeByte(2)
      ..write(obj.selectedFirstTask)
      ..writeByte(3)
      ..write(obj.currentPage);
  }
}
