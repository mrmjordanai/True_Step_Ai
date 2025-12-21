import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/session_provider.dart';

/// Tool Audit screen for checking required tools before a session
///
/// Displays a checklist of all tools required for the guide and allows
/// users to mark which tools they have available.
class ToolAuditScreen extends ConsumerWidget {
  const ToolAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return const Scaffold(
        backgroundColor: TrueStepColors.bgPrimary,
        body: Center(
          child: Text(
            'No active session',
            style: TextStyle(color: TrueStepColors.textSecondary),
          ),
        ),
      );
    }

    // Collect all unique tools from all steps
    final allTools =
        session.guide.steps.expand((step) => step.tools).toSet().toList()
          ..sort();

    final checkedTools = session.checkedTools;
    final allChecked = allTools.every((tool) => checkedTools.contains(tool));
    final missingCount = allTools.length - checkedTools.length;

    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, session.guide.title),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TrueStepSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionCard(),
                    const SizedBox(height: TrueStepSpacing.lg),
                    _buildToolsList(context, ref, allTools, checkedTools),
                    if (!allChecked && checkedTools.isNotEmpty) ...[
                      const SizedBox(height: TrueStepSpacing.md),
                      _buildMissingWarning(missingCount),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomControls(context, ref, allChecked),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String guideTitle) {
    return Padding(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: TrueStepColors.textPrimary,
            ),
            onPressed: () => context.go(AppRoutes.sessionCalibration),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guideTitle,
                  style: TrueStepTypography.bodyLarge.copyWith(
                    color: TrueStepColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: TrueStepSpacing.xs),
                Text(
                  'Step 2 of 3: Tool Check',
                  style: TrueStepTypography.caption.copyWith(
                    color: TrueStepColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return GlassCard(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.checklist,
            color: TrueStepColors.accentBlue,
            size: 28,
          ),
          const SizedBox(height: TrueStepSpacing.sm),
          Text(
            'Tool Check',
            style: TrueStepTypography.title.copyWith(
              color: TrueStepColors.textPrimary,
            ),
          ),
          const SizedBox(height: TrueStepSpacing.sm),
          Text(
            'Gather the tools you\'ll need for this task. Check off each item as you collect it.',
            style: TrueStepTypography.bodyMedium.copyWith(
              color: TrueStepColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildToolsList(
    BuildContext context,
    WidgetRef ref,
    List<String> allTools,
    Set<String> checkedTools,
  ) {
    if (allTools.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(TrueStepSpacing.lg),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: TrueStepColors.sentinelGreen,
              size: 48,
            ),
            const SizedBox(height: TrueStepSpacing.md),
            Text(
              'No special tools required',
              style: TrueStepTypography.bodyLarge.copyWith(
                color: TrueStepColors.textPrimary,
              ),
            ),
            const SizedBox(height: TrueStepSpacing.xs),
            Text(
              'You\'re ready to start!',
              style: TrueStepTypography.body.copyWith(
                color: TrueStepColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: TrueStepSpacing.sm),
      child: Column(
        children: allTools.map((tool) {
          final isChecked = checkedTools.contains(tool);
          return _ToolChecklistItem(
            tool: tool,
            isChecked: isChecked,
            onChanged: (checked) {
              ref.read(sessionProvider.notifier).toggleTool(tool);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMissingWarning(int missingCount) {
    final itemText = missingCount == 1 ? 'item' : 'items';
    return Container(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      decoration: BoxDecoration(
        color: TrueStepColors.analysisYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        border: Border.all(
          color: TrueStepColors.analysisYellow.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: TrueStepColors.analysisYellow,
            size: 24,
          ),
          const SizedBox(width: TrueStepSpacing.sm),
          Expanded(
            child: Text(
              '$missingCount $itemText missing. You can still proceed, but some steps may be difficult.',
              style: TrueStepTypography.body.copyWith(
                color: TrueStepColors.analysisYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    WidgetRef ref,
    bool allChecked,
  ) {
    return Container(
      padding: const EdgeInsets.all(TrueStepSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: 'Start Session',
            onPressed: () {
              ref.read(sessionProvider.notifier).confirmToolsReady();
              _navigateToActiveSession(context);
            },
          ),
          if (!allChecked) ...[
            const SizedBox(height: TrueStepSpacing.sm),
            Text(
              'Some tools not checked',
              style: TrueStepTypography.caption.copyWith(
                color: TrueStepColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToActiveSession(BuildContext context) {
    context.go(AppRoutes.sessionActive);
  }
}

/// Individual tool checklist item widget
class _ToolChecklistItem extends StatelessWidget {
  final String tool;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _ToolChecklistItem({
    required this.tool,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TrueStepSpacing.md,
          vertical: TrueStepSpacing.sm,
        ),
        child: Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: TrueStepColors.sentinelGreen,
              checkColor: TrueStepColors.bgPrimary,
              side: BorderSide(
                color: isChecked
                    ? TrueStepColors.sentinelGreen
                    : TrueStepColors.textSecondary,
                width: 2,
              ),
            ),
            const SizedBox(width: TrueStepSpacing.sm),
            Expanded(
              child: Text(
                tool,
                style: TrueStepTypography.bodyLarge.copyWith(
                  color: isChecked
                      ? TrueStepColors.textPrimary
                      : TrueStepColors.textSecondary,
                  decoration: isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            if (isChecked)
              const Icon(
                Icons.check_circle,
                color: TrueStepColors.sentinelGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
