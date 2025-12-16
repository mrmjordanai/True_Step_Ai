import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/guide.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/primary_button.dart';

/// Guide Preview screen
///
/// Displays a guide's details before starting a session:
/// - Title and source URL
/// - Step count, duration, difficulty
/// - Tools required
/// - Steps overview
/// - Start Session CTA
class GuidePreviewScreen extends ConsumerWidget {
  /// The guide to preview
  final Guide guide;

  /// Callback when Start Session is tapped
  final VoidCallback? onStartSession;

  /// Callback when back button is tapped
  final VoidCallback? onBack;

  const GuidePreviewScreen({
    super.key,
    required this.guide,
    this.onStartSession,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueStepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(TrueStepSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Category
                      _buildHeader(),
                      const SizedBox(height: TrueStepSpacing.md),

                      // Source URL (if available)
                      if (guide.isFromUrl) ...[
                        _buildSourceSection(),
                        const SizedBox(height: TrueStepSpacing.lg),
                      ],

                      // Stats (steps, duration, difficulty)
                      _buildStatsSection(),
                      const SizedBox(height: TrueStepSpacing.lg),

                      // Tools Required
                      if (guide.tools.isNotEmpty) ...[
                        _buildToolsSection(),
                        const SizedBox(height: TrueStepSpacing.lg),
                      ],

                      // Steps Preview
                      _buildStepsSection(),
                      const SizedBox(height: TrueStepSpacing.xl),
                    ],
                  ),
                ),
              ),

              // Bottom CTA
              _buildBottomCTA(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TrueStepSpacing.sm,
        vertical: TrueStepSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: TrueStepColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Share button (future feature)
          IconButton(
            onPressed: () {
              // TODO: Implement share
            },
            icon: const Icon(
              Icons.share_outlined,
              color: TrueStepColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TrueStepSpacing.sm,
            vertical: TrueStepSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _getCategoryColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(TrueStepSpacing.radiusSm),
          ),
          child: Text(
            _getCategoryLabel(),
            style: TrueStepTypography.caption.copyWith(
              color: _getCategoryColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: TrueStepSpacing.sm),

        // Title
        Text(
          guide.title,
          style: TrueStepTypography.headline.copyWith(fontSize: 28),
        ),
      ],
    );
  }

  Widget _buildSourceSection() {
    final host = Uri.tryParse(guide.sourceUrl ?? '')?.host ?? guide.sourceUrl;

    return Row(
      children: [
        Icon(Icons.link, size: 16, color: TrueStepColors.textTertiary),
        const SizedBox(width: TrueStepSpacing.xs),
        Text(
          'Source: ',
          style: TrueStepTypography.caption.copyWith(
            color: TrueStepColors.textTertiary,
          ),
        ),
        Text(
          host ?? 'Unknown',
          style: TrueStepTypography.caption.copyWith(
            color: TrueStepColors.accentBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.format_list_numbered,
            value: '${guide.stepCount}',
            label: guide.stepCount == 1 ? 'step' : 'steps',
          ),
        ),
        const SizedBox(width: TrueStepSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            value: _formatDuration(
              guide.totalDuration > 0
                  ? guide.totalDuration
                  : guide.calculatedDuration,
            ),
            label: 'min',
          ),
        ),
        const SizedBox(width: TrueStepSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up,
            value: _getDifficultyLabel(),
            label: 'difficulty',
            valueColor: _getDifficultyColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildToolsSection() {
    return GlassCard(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.build_outlined,
                size: 20,
                color: TrueStepColors.analysisYellow,
              ),
              const SizedBox(width: TrueStepSpacing.sm),
              Text(
                'Tools Required',
                style: TrueStepTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: TrueStepSpacing.md),
          Wrap(
            spacing: TrueStepSpacing.sm,
            runSpacing: TrueStepSpacing.sm,
            children: guide.tools.map((tool) => _ToolChip(tool: tool)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Steps Overview', style: TrueStepTypography.title),
        const SizedBox(height: TrueStepSpacing.md),

        // Steps list
        ...guide.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: TrueStepSpacing.sm),
            child: _StepPreviewCard(
              stepNumber: index + 1,
              title: step.title,
              hasWarning: step.warnings.isNotEmpty,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(TrueStepSpacing.lg),
      decoration: BoxDecoration(
        color: TrueStepColors.bgSurface,
        border: Border(top: BorderSide(color: TrueStepColors.glassBorder)),
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: 'Start Session',
          onPressed: onStartSession,
          icon: Icons.play_arrow,
        ),
      ),
    );
  }

  // Helper methods
  String _getCategoryLabel() {
    switch (guide.category) {
      case GuideCategory.culinary:
        return 'Cooking';
      case GuideCategory.diy:
        return 'DIY';
    }
  }

  Color _getCategoryColor() {
    switch (guide.category) {
      case GuideCategory.culinary:
        return TrueStepColors.analysisYellow;
      case GuideCategory.diy:
        return TrueStepColors.accentBlue;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '<1';
    final minutes = (seconds / 60).ceil();
    return '$minutes';
  }

  String _getDifficultyLabel() {
    switch (guide.difficulty) {
      case GuideDifficulty.easy:
        return 'Easy';
      case GuideDifficulty.medium:
        return 'Medium';
      case GuideDifficulty.hard:
        return 'Hard';
    }
  }

  Color _getDifficultyColor() {
    switch (guide.difficulty) {
      case GuideDifficulty.easy:
        return TrueStepColors.sentinelGreen;
      case GuideDifficulty.medium:
        return TrueStepColors.analysisYellow;
      case GuideDifficulty.hard:
        return TrueStepColors.interventionRed;
    }
  }
}

/// Stat card for displaying guide statistics
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: Column(
        children: [
          Icon(icon, size: 24, color: TrueStepColors.textSecondary),
          const SizedBox(height: TrueStepSpacing.xs),
          Text(
            value,
            style: TrueStepTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? TrueStepColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TrueStepTypography.caption.copyWith(
              color: TrueStepColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tool chip widget
class _ToolChip extends StatelessWidget {
  final String tool;

  const _ToolChip({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TrueStepSpacing.sm,
        vertical: TrueStepSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: TrueStepColors.glassSurface,
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusSm),
        border: Border.all(color: TrueStepColors.glassBorder),
      ),
      child: Text(
        tool,
        style: TrueStepTypography.caption.copyWith(
          color: TrueStepColors.textPrimary,
        ),
      ),
    );
  }
}

/// Step preview card
class _StepPreviewCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool hasWarning;

  const _StepPreviewCard({
    required this.stepNumber,
    required this.title,
    this.hasWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: Row(
        children: [
          // Step number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: TrueStepColors.accentBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TrueStepTypography.body.copyWith(
                  color: TrueStepColors.accentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: TrueStepSpacing.md),

          // Title
          Expanded(
            child: Text(
              title,
              style: TrueStepTypography.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Warning indicator
          if (hasWarning)
            const Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: TrueStepColors.analysisYellow,
            ),
        ],
      ),
    );
  }
}
