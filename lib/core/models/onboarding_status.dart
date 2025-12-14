import 'package:hive_flutter/hive_flutter.dart';

/// Onboarding completion status stored locally via Hive
///
/// Tracks whether the user has completed the onboarding flow
/// and stores their first task selection for personalization.
class OnboardingStatus {
  /// Whether the user has completed the onboarding flow
  final bool hasCompletedOnboarding;

  /// When the onboarding was completed
  final DateTime? completedAt;

  /// The first task the user selected (cook, fix, scan, explore)
  final String? selectedFirstTask;

  /// Current page index in the welcome carousel
  final int currentPage;

  const OnboardingStatus({
    this.hasCompletedOnboarding = false,
    this.completedAt,
    this.selectedFirstTask,
    this.currentPage = 0,
  });

  /// Create a copy with updated values
  OnboardingStatus copyWith({
    bool? hasCompletedOnboarding,
    DateTime? completedAt,
    String? selectedFirstTask,
    int? currentPage,
  }) {
    return OnboardingStatus(
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      completedAt: completedAt ?? this.completedAt,
      selectedFirstTask: selectedFirstTask ?? this.selectedFirstTask,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  /// Default empty status for new users
  factory OnboardingStatus.initial() => const OnboardingStatus();

  /// Create a completed status
  factory OnboardingStatus.completed({String? selectedFirstTask}) => OnboardingStatus(
        hasCompletedOnboarding: true,
        completedAt: DateTime.now(),
        selectedFirstTask: selectedFirstTask,
        currentPage: 0,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingStatus &&
        other.hasCompletedOnboarding == hasCompletedOnboarding &&
        other.completedAt == completedAt &&
        other.selectedFirstTask == selectedFirstTask &&
        other.currentPage == currentPage;
  }

  @override
  int get hashCode => Object.hash(
        hasCompletedOnboarding,
        completedAt,
        selectedFirstTask,
        currentPage,
      );
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
