import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';

/// Prominent glass pill input bar for the home screen
///
/// Accepts URL, text description, or voice input.
/// Placeholder: "Paste URL, describe task, or say 'Hey TrueStep'..."
class OmniBar extends StatelessWidget {
  /// Callback when the bar is tapped
  final VoidCallback? onTap;

  /// Callback when the microphone icon is tapped
  final VoidCallback? onMicTap;

  const OmniBar({
    super.key,
    this.onTap,
    this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TrueStepSpacing.md,
          vertical: TrueStepSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: TrueStepColors.glassSurface,
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusXl),
          border: Border.all(
            color: TrueStepColors.glassBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: TrueStepColors.accentBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Search icon
            Icon(
              Icons.search,
              color: TrueStepColors.textTertiary,
              size: 24,
            ),
            const SizedBox(width: TrueStepSpacing.sm),

            // Placeholder text
            Expanded(
              child: Text(
                "Paste URL, describe task, or say 'Hey TrueStep'...",
                style: TrueStepTypography.body.copyWith(
                  color: TrueStepColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: TrueStepSpacing.sm),

            // Microphone button
            GestureDetector(
              onTap: onMicTap ?? onTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TrueStepColors.accentBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.mic,
                  color: TrueStepColors.accentBlue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
