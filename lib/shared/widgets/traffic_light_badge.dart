import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';

/// Badge size variants for TrafficLightBadge
enum BadgeSize {
  /// Small badge - 24dp height
  small,

  /// Medium badge - 32dp height (default)
  medium,

  /// Large badge - 48dp height
  large,
}

/// A badge widget displaying traffic light state with icon and optional label.
///
/// Features:
/// - Color-coded based on traffic light state (green/yellow/red)
/// - State-specific icons for colorblind accessibility
/// - Optional glow effect for emphasis
/// - Three size variants
///
/// Example:
/// ```dart
/// TrafficLightBadge(
///   state: TrafficLightState.green,
///   label: 'Watching',
///   size: BadgeSize.medium,
///   showGlow: true,
/// )
/// ```
class TrafficLightBadge extends StatelessWidget {
  /// The traffic light state determining color and icon.
  final TrafficLightState state;

  /// Optional text label displayed next to the icon.
  final String? label;

  /// The size of the badge.
  final BadgeSize size;

  /// Whether to show a glow effect around the badge.
  final bool showGlow;

  /// Whether to show the state icon.
  final bool showIcon;

  const TrafficLightBadge({
    super.key,
    required this.state,
    this.label,
    this.size = BadgeSize.medium,
    this.showGlow = true,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = TrueStepColors.getTrafficLightColor(state);
    final glowColor = TrueStepColors.getTrafficLightGlow(state);
    final dimensions = _getDimensions();

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            _getIcon(),
            color: color,
            size: dimensions.iconSize,
          ),
          if (label != null) SizedBox(width: dimensions.spacing),
        ],
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              color: color,
              fontSize: dimensions.fontSize,
              fontWeight: TrueStepTypography.semiBold,
            ),
          ),
      ],
    );

    // Wrap with container for sizing and optional glow
    return Container(
      height: dimensions.height,
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(dimensions.height / 2),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: glowColor,
                  blurRadius: TrueStepSpacing.glowSpread,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Center(child: content),
    );
  }

  IconData _getIcon() {
    switch (state) {
      case TrafficLightState.green:
        return Icons.visibility;
      case TrafficLightState.yellow:
        return Icons.graphic_eq;
      case TrafficLightState.red:
        return Icons.pan_tool;
    }
  }

  _BadgeDimensions _getDimensions() {
    switch (size) {
      case BadgeSize.small:
        return const _BadgeDimensions(
          height: 24.0,
          iconSize: 14.0,
          fontSize: 12.0,
          spacing: 4.0,
          horizontalPadding: 8.0,
        );
      case BadgeSize.medium:
        return const _BadgeDimensions(
          height: 32.0,
          iconSize: 18.0,
          fontSize: 14.0,
          spacing: 6.0,
          horizontalPadding: 12.0,
        );
      case BadgeSize.large:
        return const _BadgeDimensions(
          height: 48.0,
          iconSize: 24.0,
          fontSize: 16.0,
          spacing: 8.0,
          horizontalPadding: 16.0,
        );
    }
  }
}

/// Internal class for badge dimension calculations
class _BadgeDimensions {
  final double height;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final double horizontalPadding;

  const _BadgeDimensions({
    required this.height,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
    required this.horizontalPadding,
  });
}
