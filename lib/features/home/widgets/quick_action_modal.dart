import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';

/// Quick action types available from the modal
enum QuickAction {
  pasteUrl,
  describeTask,
  voiceInput,
  scanQr,
}

/// Shows the Quick Action modal bottom sheet
///
/// Returns the selected [QuickAction] or null if dismissed
Future<QuickAction?> showQuickActionModal(
  BuildContext context, {
  required void Function(QuickAction) onActionSelected,
}) {
  return showModalBottomSheet<QuickAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => QuickActionModal(
      onActionSelected: (action) {
        onActionSelected(action);
        Navigator.of(context).pop(action);
      },
    ),
  );
}

/// Quick Action Modal content widget
///
/// Displays a bottom sheet with quick start options:
/// - Paste URL
/// - Describe Task
/// - Voice Input
/// - Scan QR
class QuickActionModal extends StatelessWidget {
  /// Callback when an action is selected
  final void Function(QuickAction) onActionSelected;

  const QuickActionModal({
    super.key,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TrueStepColors.bgSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TrueStepSpacing.radiusXl),
          topRight: Radius.circular(TrueStepSpacing.radiusXl),
        ),
        border: Border.all(
          color: TrueStepColors.glassBorder,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(TrueStepSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TrueStepColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: TrueStepSpacing.lg),

              // Title
              Text(
                'Quick Start',
                style: TrueStepTypography.headline,
              ),
              const SizedBox(height: TrueStepSpacing.xs),
              Text(
                'Choose how to start your session',
                style: TrueStepTypography.body.copyWith(
                  color: TrueStepColors.textSecondary,
                ),
              ),
              const SizedBox(height: TrueStepSpacing.lg),

              // Action grid
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.link,
                      label: 'Paste URL',
                      color: TrueStepColors.accentBlue,
                      onTap: () => onActionSelected(QuickAction.pasteUrl),
                    ),
                  ),
                  const SizedBox(width: TrueStepSpacing.md),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.edit_note,
                      label: 'Describe Task',
                      color: TrueStepColors.accentPurple,
                      onTap: () => onActionSelected(QuickAction.describeTask),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TrueStepSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.mic,
                      label: 'Voice Input',
                      color: TrueStepColors.sentinelGreen,
                      onTap: () => onActionSelected(QuickAction.voiceInput),
                    ),
                  ),
                  const SizedBox(width: TrueStepSpacing.md),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.qr_code_scanner,
                      label: 'Scan QR',
                      color: TrueStepColors.analysisYellow,
                      onTap: () => onActionSelected(QuickAction.scanQr),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TrueStepSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual action button in the grid
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TrueStepSpacing.lg),
        decoration: BoxDecoration(
          color: TrueStepColors.glassSurface,
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          border: Border.all(
            color: TrueStepColors.glassBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: TrueStepSpacing.sm),

            // Label
            Text(
              label,
              style: TrueStepTypography.body.copyWith(
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
