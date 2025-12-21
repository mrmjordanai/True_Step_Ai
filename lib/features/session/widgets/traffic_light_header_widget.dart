import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../models/session_state.dart';

/// Traffic Light Header widget for Active Session
///
/// Displays the current Sentinel state with color-coded visual feedback:
/// - GREEN: Watching (ready for verification)
/// - YELLOW: Verifying (AI processing)
/// - RED: Intervention required
class TrafficLightHeaderWidget extends StatelessWidget {
  final SentinelState sentinelState;
  final String stepProgress;
  final int elapsedSeconds;
  final VoidCallback onPause;
  final VoidCallback onClose;

  const TrafficLightHeaderWidget({
    super.key,
    required this.sentinelState,
    required this.stepProgress,
    required this.elapsedSeconds,
    required this.onPause,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TrueStepSpacing.md,
        vertical: TrueStepSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withOpacity(0.15),
        border: Border(
          bottom: BorderSide(
            color: _getBackgroundColor().withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Close Button
          IconButton(
            icon: const Icon(Icons.close, color: TrueStepColors.textPrimary),
            onPressed: onClose,
          ),

          // Sentinel State Indicator
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStateIndicator(),
                const SizedBox(width: TrueStepSpacing.sm),
                Text(
                  _getStateLabel(),
                  style: TrueStepTypography.bodyMedium.copyWith(
                    color: _getBackgroundColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Step Progress & Timer
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Step $stepProgress',
                style: TrueStepTypography.caption.copyWith(
                  color: TrueStepColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(elapsedSeconds),
                style: TrueStepTypography.bodyMedium.copyWith(
                  color: TrueStepColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Pause Button
          IconButton(
            icon: const Icon(Icons.pause, color: TrueStepColors.textPrimary),
            onPressed: onPause,
          ),
        ],
      ),
    );
  }

  Widget _buildStateIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBackgroundColor(),
        boxShadow: [
          BoxShadow(
            color: _getBackgroundColor().withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (sentinelState) {
      case SentinelState.watching:
        return TrueStepColors.sentinelGreen;
      case SentinelState.verifying:
        return TrueStepColors.analysisYellow;
      case SentinelState.intervention:
        return TrueStepColors.interventionRed;
    }
  }

  String _getStateLabel() {
    switch (sentinelState) {
      case SentinelState.watching:
        return 'Watching';
      case SentinelState.verifying:
        return 'Verifying...';
      case SentinelState.intervention:
        return 'Attention Required';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
