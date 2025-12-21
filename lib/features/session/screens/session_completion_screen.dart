import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/session_data.dart';

/// Session Completion screen showing results and stats
///
/// Displays:
/// - Celebration animation
/// - Steps completed
/// - Time taken
/// - AI confidence score
/// - Intervention count
class SessionCompletionScreen extends ConsumerWidget {
  final SessionSummary summary;

  const SessionCompletionScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullyCompleted =
        summary.wasCompleted && summary.stepsCompleted == summary.totalSteps;

    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TrueStepSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: TrueStepSpacing.xl),
              _buildCelebrationHeader(isFullyCompleted),
              const SizedBox(height: TrueStepSpacing.lg),
              _buildGuideInfo(),
              const SizedBox(height: TrueStepSpacing.xl),
              _buildStatsGrid(),
              const SizedBox(height: TrueStepSpacing.lg),
              _buildCompletionMessage(isFullyCompleted),
              const SizedBox(height: TrueStepSpacing.xxl),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationHeader(bool isFullyCompleted) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFullyCompleted
                  ? [
                      TrueStepColors.sentinelGreen,
                      TrueStepColors.sentinelGreen.withOpacity(0.7),
                    ]
                  : [
                      TrueStepColors.analysisYellow,
                      TrueStepColors.analysisYellow.withOpacity(0.7),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isFullyCompleted
                            ? TrueStepColors.sentinelGreen
                            : TrueStepColors.analysisYellow)
                        .withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            isFullyCompleted ? Icons.celebration : Icons.flag,
            size: 48,
            color: TrueStepColors.bgPrimary,
          ),
        ),
        const SizedBox(height: TrueStepSpacing.lg),
        Text(
          isFullyCompleted ? 'Session Complete!' : 'Session Ended',
          style: TrueStepTypography.headline.copyWith(
            color: TrueStepColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TrueStepColors.accentBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(TrueStepSpacing.radiusSm),
            ),
            child: Center(
              child: Icon(
                summary.guide.category.name == 'culinary'
                    ? Icons.restaurant
                    : Icons.build,
                color: TrueStepColors.accentBlue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: TrueStepSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.guide.title,
                  style: TrueStepTypography.title.copyWith(
                    color: TrueStepColors.textPrimary,
                  ),
                ),
                Text(
                  summary.guide.category.name.toUpperCase(),
                  style: TrueStepTypography.caption.copyWith(
                    color: TrueStepColors.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle,
                label: 'Steps',
                value: '${summary.stepsCompleted}/${summary.totalSteps}',
                color: TrueStepColors.sentinelGreen,
              ),
            ),
            const SizedBox(width: TrueStepSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.timer,
                label: 'Duration',
                value: summary.formattedDuration,
                color: TrueStepColors.accentBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: TrueStepSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.psychology,
                label: 'AI Confidence',
                value: '${(summary.averageConfidence * 100).round()}%',
                color: TrueStepColors.accentPurple,
              ),
            ),
            const SizedBox(width: TrueStepSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.warning_amber,
                label: 'Interventions',
                value: '${summary.interventionCount}',
                color: summary.interventionCount > 0
                    ? TrueStepColors.analysisYellow
                    : TrueStepColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionMessage(bool isFullyCompleted) {
    final message = isFullyCompleted
        ? 'Congratulations! You\'ve successfully completed all steps.'
        : 'Session ended with partial progress. You can resume later.';

    return Container(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      decoration: BoxDecoration(
        color:
            (isFullyCompleted
                    ? TrueStepColors.sentinelGreen
                    : TrueStepColors.analysisYellow)
                .withOpacity(0.1),
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        border: Border.all(
          color:
              (isFullyCompleted
                      ? TrueStepColors.sentinelGreen
                      : TrueStepColors.analysisYellow)
                  .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFullyCompleted ? Icons.check_circle : Icons.info_outline,
            color: isFullyCompleted
                ? TrueStepColors.sentinelGreen
                : TrueStepColors.analysisYellow,
          ),
          const SizedBox(width: TrueStepSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TrueStepTypography.body.copyWith(
                color: isFullyCompleted
                    ? TrueStepColors.sentinelGreen
                    : TrueStepColors.analysisYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: 'Done',
          onPressed: () {
            // Navigate back to home
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        const SizedBox(height: TrueStepSpacing.md),
        TextButton(
          onPressed: () {
            // TODO: Implement sharing functionality
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Share coming soon!')));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.share,
                color: TrueStepColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: TrueStepSpacing.sm),
              Text(
                'Share Results',
                style: TrueStepTypography.bodyMedium.copyWith(
                  color: TrueStepColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: TrueStepSpacing.sm),
          Text(
            value,
            style: TrueStepTypography.headline.copyWith(
              color: TrueStepColors.textPrimary,
            ),
          ),
          const SizedBox(height: TrueStepSpacing.xs),
          Text(
            label,
            style: TrueStepTypography.caption.copyWith(
              color: TrueStepColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
