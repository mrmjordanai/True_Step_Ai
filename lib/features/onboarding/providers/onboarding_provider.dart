import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/onboarding_status.dart';

/// Hive box name for onboarding data
const String onboardingBoxName = 'onboarding';

/// Provider for the Hive box storing onboarding status
/// This can be overridden in tests with a mock box
final onboardingBoxProvider = Provider<Box<OnboardingStatus>>((ref) {
  throw UnimplementedError(
    'onboardingBoxProvider must be overridden with an open Hive box',
  );
});

/// Provider for the current onboarding status
/// Reads from Hive and returns initial status if not found
final onboardingStatusProvider = Provider<OnboardingStatus>((ref) {
  final box = ref.watch(onboardingBoxProvider);
  return box.get('status') ?? OnboardingStatus.initial();
});

/// Provider that returns whether onboarding has been completed
final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  final status = ref.watch(onboardingStatusProvider);
  return status.hasCompletedOnboarding;
});

/// Provider for the current page in the welcome carousel
final currentPageProvider = Provider<int>((ref) {
  final status = ref.watch(onboardingStatusProvider);
  return status.currentPage;
});

/// Provider for the selected first task option
final selectedFirstTaskProvider = Provider<FirstTaskOption?>((ref) {
  final status = ref.watch(onboardingStatusProvider);
  return FirstTaskOption.fromId(status.selectedFirstTask);
});

/// Notifier for managing onboarding state changes
class OnboardingNotifier extends Notifier<OnboardingStatus> {
  @override
  OnboardingStatus build() {
    final box = ref.watch(onboardingBoxProvider);
    return box.get('status') ?? OnboardingStatus.initial();
  }

  Box<OnboardingStatus> get _box => ref.read(onboardingBoxProvider);

  /// Update the current page in the welcome carousel
  void setCurrentPage(int page) {
    final newStatus = state.copyWith(currentPage: page);
    state = newStatus;
    _box.put('status', newStatus);
  }

  /// Set the selected first task
  void setFirstTask(FirstTaskOption task) {
    final newStatus = state.copyWith(selectedFirstTask: task.id);
    state = newStatus;
    _box.put('status', newStatus);
  }

  /// Mark onboarding as completed
  void completeOnboarding() {
    final newStatus = state.copyWith(
      hasCompletedOnboarding: true,
      completedAt: DateTime.now(),
    );
    state = newStatus;
    _box.put('status', newStatus);
  }

  /// Reset onboarding to initial state
  void resetOnboarding() {
    final newStatus = OnboardingStatus.initial();
    state = newStatus;
    _box.put('status', newStatus);
  }
}

/// Provider for the onboarding notifier
final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingStatus>(
  OnboardingNotifier.new,
);

/// Helper function to initialize onboarding Hive box
/// Call this in main.dart before runApp
Future<Box<OnboardingStatus>> initializeOnboardingBox() async {
  // Register the adapter if not already registered
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(OnboardingStatusAdapter());
  }
  return await Hive.openBox<OnboardingStatus>(onboardingBoxName);
}
