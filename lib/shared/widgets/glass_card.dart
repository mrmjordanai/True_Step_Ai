import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';

/// A glassmorphism-styled card widget with blur effect and optional accent color.
///
/// The GlassCard implements the "Glass Sentinel" design philosophy with:
/// - BackdropFilter blur effect (default 20dp)
/// - Semi-transparent background (8% white)
/// - Subtle border (12% white or accent color)
/// - Rounded corners (16dp default)
///
/// Example:
/// ```dart
/// GlassCard(
///   child: Text('Content'),
///   accentColor: TrueStepColors.sentinelGreen,
///   onTap: () => print('Tapped'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  /// The widget to display inside the card.
  final Widget child;

  /// Optional accent color for the border.
  /// When provided, uses a 2px border with this color.
  /// When null, uses the default glass border (1px, 12% white).
  final Color? accentColor;

  /// Padding inside the card.
  /// Defaults to 16dp on all sides.
  final EdgeInsets padding;

  /// Border radius of the card.
  /// Defaults to 16dp (TrueStepSpacing.radiusLg).
  final double borderRadius;

  /// Blur sigma for the backdrop filter.
  /// Defaults to 20dp (TrueStepSpacing.glassBlur).
  final double blurSigma;

  /// Optional tap callback.
  /// When provided, the card becomes tappable with an ink splash effect.
  final VoidCallback? onTap;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const GlassCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(TrueStepSpacing.md),
    this.borderRadius = TrueStepSpacing.radiusLg,
    this.blurSigma = TrueStepSpacing.glassBlur,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadiusGeometry = BorderRadius.circular(borderRadius);

    // Determine border based on accent color
    final border = accentColor != null
        ? Border.all(color: accentColor!, width: 2)
        : Border.all(color: TrueStepColors.glassBorder, width: 1);

    Widget cardContent = ClipRRect(
      borderRadius: borderRadiusGeometry,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: TrueStepColors.glassOverlay,
            borderRadius: borderRadiusGeometry,
            border: border,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    // Wrap with InkWell if onTap is provided
    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadiusGeometry,
          splashColor: TrueStepColors.glassBorder,
          highlightColor: TrueStepColors.glassOverlay,
          child: cardContent,
        ),
      );
    }

    // Wrap with Semantics if label is provided
    if (semanticLabel != null) {
      cardContent = Semantics(
        label: semanticLabel,
        container: true,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
