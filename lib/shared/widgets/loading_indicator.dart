import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';

/// A traffic light themed loading indicator.
///
/// Displays a circular progress indicator with colors matching
/// the current traffic light state:
/// - Green: Watching/success state
/// - Yellow: Processing/analyzing state
/// - Red: Intervention/danger state
///
/// Example:
/// ```dart
/// LoadingIndicator(
///   state: TrafficLightState.yellow,
///   message: 'Analyzing...',
///   size: 48,
/// )
/// ```
class LoadingIndicator extends StatelessWidget {
  /// The size of the loading indicator.
  /// Defaults to 48dp.
  final double size;

  /// The traffic light state determining the color.
  /// Defaults to green.
  final TrafficLightState state;

  /// Optional message text displayed below the indicator.
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = 48.0,
    this.state = TrafficLightState.green,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = TrueStepColors.getTrafficLightColor(state);

    Widget indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size / 12,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: color.withValues(alpha: 0.2),
      ),
    );

    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: TrueStepSpacing.md),
          Text(
            message!,
            style: TrueStepTypography.body.copyWith(
              color: TrueStepColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }
}
