import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/onboarding_status.dart';
import '../providers/onboarding_provider.dart';

/// First task selection screen with 2x2 grid
///
/// Options:
/// - Cook Something
/// - Fix Something
/// - Scan My Device
/// - Just Explore
class FirstTaskScreen extends ConsumerWidget {
  /// Callback when a task is selected and onboarding completes
  final VoidCallback onComplete;

  const FirstTaskScreen({
    super.key,
    required this.onComplete,
  });

  static const _tasks = [
    _TaskOption(
      option: FirstTaskOption.cook,
      icon: Icons.restaurant,
      color: TrueStepColors.analysisYellow,
    ),
    _TaskOption(
      option: FirstTaskOption.fix,
      icon: Icons.build,
      color: TrueStepColors.accentBlue,
    ),
    _TaskOption(
      option: FirstTaskOption.scan,
      icon: Icons.qr_code_scanner,
      color: TrueStepColors.accentPurple,
    ),
    _TaskOption(
      option: FirstTaskOption.explore,
      icon: Icons.explore,
      color: TrueStepColors.sentinelGreen,
    ),
  ];

  void _selectTask(WidgetRef ref, FirstTaskOption option) {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    notifier.setFirstTask(option);
    notifier.completeOnboarding();
    onComplete();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueStepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(TrueStepSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: TrueStepSpacing.xl),

                // Title
                Text(
                  "What's your first task?",
                  style: TrueStepTypography.headline,
                ),
                const SizedBox(height: TrueStepSpacing.sm),

                // Subtitle
                Text(
                  "We'll personalize your experience",
                  style: TrueStepTypography.body.copyWith(
                    color: TrueStepColors.textSecondary,
                  ),
                ),
                const SizedBox(height: TrueStepSpacing.xl),

                // 2x2 Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: TrueStepSpacing.md,
                    crossAxisSpacing: TrueStepSpacing.md,
                    children: _tasks.map((task) {
                      return _TaskCard(
                        task: task,
                        onTap: () => _selectTask(ref, task.option),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Task option data
class _TaskOption {
  final FirstTaskOption option;
  final IconData icon;
  final Color color;

  const _TaskOption({
    required this.option,
    required this.icon,
    required this.color,
  });
}

/// Task card widget
class _TaskCard extends StatelessWidget {
  final _TaskOption task;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TrueStepSpacing.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: TrueStepColors.glassSurface,
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusLg),
          border: Border.all(
            color: TrueStepColors.glassBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: task.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                task.icon,
                size: 32,
                color: task.color,
              ),
            ),
            const SizedBox(height: TrueStepSpacing.md),

            // Label
            Text(
              task.option.label,
              style: TrueStepTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
