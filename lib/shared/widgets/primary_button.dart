import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';

/// Button style variants for PrimaryButton
enum ButtonVariant {
  /// Primary filled button with accent blue background
  primary,

  /// Secondary outlined button
  secondary,

  /// Danger filled button with red background
  danger,

  /// Ghost/text button with transparent background
  ghost,
}

/// A styled button widget following the TrueStep design system.
///
/// Features:
/// - 56dp height for easy tapping
/// - 12dp border radius
/// - Loading state with spinner
/// - Disabled state with reduced opacity
/// - Multiple variants (primary, secondary, danger, ghost)
/// - Optional leading icon
///
/// Example:
/// ```dart
/// PrimaryButton(
///   label: 'Get Started',
///   onPressed: () => print('Pressed'),
///   variant: ButtonVariant.primary,
///   icon: Icons.arrow_forward,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  /// The text label for the button.
  final String label;

  /// Callback when button is pressed.
  /// When null, the button is disabled.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  /// When true, shows a spinner and disables interaction.
  final bool isLoading;

  /// The visual variant of the button.
  final ButtonVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the button should take full width.
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    // Disable interaction during loading
    final effectiveOnPressed = isLoading ? null : onPressed;

    // Build button content
    Widget content = _buildContent();

    // Wrap with size constraints
    if (fullWidth) {
      content = SizedBox(
        width: double.infinity,
        height: TrueStepSpacing.buttonHeight,
        child: content,
      );
    } else {
      content = SizedBox(
        height: TrueStepSpacing.buttonHeight,
        child: content,
      );
    }

    // Build appropriate button type based on variant
    switch (variant) {
      case ButtonVariant.primary:
        return _buildElevatedButton(
          content: content,
          onPressed: effectiveOnPressed,
          backgroundColor: TrueStepColors.buttonPrimary,
        );

      case ButtonVariant.danger:
        return _buildElevatedButton(
          content: content,
          onPressed: effectiveOnPressed,
          backgroundColor: TrueStepColors.buttonDanger,
        );

      case ButtonVariant.secondary:
        return _buildOutlinedButton(
          content: content,
          onPressed: effectiveOnPressed,
        );

      case ButtonVariant.ghost:
        return _buildTextButton(
          content: content,
          onPressed: effectiveOnPressed,
        );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(TrueStepColors.textPrimary),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: TrueStepSpacing.sm),
          Text(label, style: TrueStepTypography.buttonLarge),
        ],
      );
    }

    return Center(
      child: Text(label, style: TrueStepTypography.buttonLarge),
    );
  }

  Widget _buildElevatedButton({
    required Widget content,
    required VoidCallback? onPressed,
    required Color backgroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: TrueStepColors.textPrimary,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
        disabledForegroundColor: TrueStepColors.textPrimary.withValues(alpha: 0.5),
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        ),
      ),
      child: content,
    );
  }

  Widget _buildOutlinedButton({
    required Widget content,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: TrueStepColors.accentBlue,
        disabledForegroundColor: TrueStepColors.accentBlue.withValues(alpha: 0.5),
        padding: EdgeInsets.zero,
        side: BorderSide(
          color: onPressed != null
              ? TrueStepColors.accentBlue
              : TrueStepColors.accentBlue.withValues(alpha: 0.5),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        ),
      ),
      child: content,
    );
  }

  Widget _buildTextButton({
    required Widget content,
    required VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: TrueStepColors.accentBlue,
        disabledForegroundColor: TrueStepColors.accentBlue.withValues(alpha: 0.5),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        ),
      ),
      child: content,
    );
  }
}
