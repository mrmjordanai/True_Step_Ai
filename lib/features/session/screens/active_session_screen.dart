import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/session_data.dart';
import '../models/session_state.dart';
import '../providers/session_provider.dart';
import '../widgets/traffic_light_header_widget.dart';

/// Active Session screen with Traffic Light verification UI
///
/// The core screen of TrueStep's Sentinel system:
/// - GREEN: Watching (ready for verification)
/// - YELLOW: Verifying (AI processing)
/// - RED: Intervention required
class ActiveSessionScreen extends ConsumerWidget {
  const ActiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    // Auto-navigate to completion when session is completed via verification
    ref.listen<SessionData?>(sessionProvider, (previous, next) {
      if (next != null &&
          next.phase == SessionPhase.completed &&
          previous?.phase != SessionPhase.completed) {
        final summary = SessionSummary.fromSession(next);
        context.go(AppRoutes.sessionComplete, extra: summary);
      }
    });

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

    final currentStep = session.currentStep;
    final isVerifying = session.sentinelState == SentinelState.verifying;

    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            TrafficLightHeaderWidget(
              key: const Key('traffic_light_header'),
              sentinelState: session.sentinelState,
              stepProgress:
                  '${session.currentStepIndex + 1} of ${session.guide.steps.length}',
              elapsedSeconds: session.elapsedSeconds,
              onPause: () => ref.read(sessionProvider.notifier).pauseSession(),
              onClose: () => _showExitConfirmation(context, ref),
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildCameraPreview(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildStepCard(currentStep),
                  ),
                ],
              ),
            ),
            _buildBottomControls(
              context,
              ref,
              session.sentinelState,
              isVerifying,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    // Placeholder for camera preview - will be replaced with actual CameraPreview widget
    return Container(
      key: const Key('camera_preview_area'),
      decoration: const BoxDecoration(color: TrueStepColors.bgSecondary),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 64, color: TrueStepColors.textTertiary),
            SizedBox(height: TrueStepSpacing.sm),
            Text(
              'Camera Feed',
              style: TextStyle(
                color: TrueStepColors.textTertiary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(dynamic currentStep) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TrueStepColors.bgPrimary.withOpacity(0.0),
            TrueStepColors.bgPrimary.withOpacity(0.9),
            TrueStepColors.bgPrimary,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        TrueStepSpacing.md,
        TrueStepSpacing.xl,
        TrueStepSpacing.md,
        TrueStepSpacing.sm,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(TrueStepSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TrueStepSpacing.sm,
                    vertical: TrueStepSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: TrueStepColors.accentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      TrueStepSpacing.radiusSm,
                    ),
                  ),
                  child: Text(
                    'Current Step',
                    style: TrueStepTypography.caption.copyWith(
                      color: TrueStepColors.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TrueStepSpacing.sm),
            Text(
              currentStep.title,
              style: TrueStepTypography.title.copyWith(
                color: TrueStepColors.textPrimary,
              ),
            ),
            const SizedBox(height: TrueStepSpacing.xs),
            Text(
              currentStep.instruction,
              style: TrueStepTypography.bodyLarge.copyWith(
                color: TrueStepColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    WidgetRef ref,
    SentinelState state,
    bool isVerifying,
  ) {
    return Container(
      padding: const EdgeInsets.all(TrueStepSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state == SentinelState.intervention)
            _buildInterventionBanner(ref)
          else
            PrimaryButton(
              key: const Key('verify_button'),
              label: isVerifying ? 'Verifying...' : 'Verify Step',
              onPressed: isVerifying
                  ? null
                  : () => ref
                        .read(sessionProvider.notifier)
                        .triggerVerification(),
              isLoading: isVerifying,
            ),
          const SizedBox(height: TrueStepSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSecondaryAction(
                icon: Icons.arrow_back,
                label: 'Previous',
                onTap: () => ref.read(sessionProvider.notifier).previousStep(),
              ),
              _buildSecondaryAction(
                icon: Icons.replay,
                label: 'Repeat',
                onTap: () =>
                    ref.read(sessionProvider.notifier).repeatInstruction(),
              ),
              _buildSecondaryAction(
                icon: Icons.skip_next,
                label: 'Skip',
                onTap: () => ref.read(sessionProvider.notifier).skipStep(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionBanner(WidgetRef ref) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(TrueStepSpacing.md),
          decoration: BoxDecoration(
            color: TrueStepColors.interventionRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
            border: Border.all(
              color: TrueStepColors.interventionRed.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: TrueStepColors.interventionRed,
                size: 24,
              ),
              const SizedBox(width: TrueStepSpacing.sm),
              Expanded(
                child: Text(
                  'Step verification needed',
                  style: TrueStepTypography.body.copyWith(
                    color: TrueStepColors.interventionRed,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TrueStepSpacing.md),
        PrimaryButton(
          key: const Key('verify_button'),
          label: 'Try Again',
          onPressed: () =>
              ref.read(sessionProvider.notifier).resolveIntervention(),
          variant: ButtonVariant.danger,
        ),
      ],
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(TrueStepSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: TrueStepColors.textSecondary, size: 24),
            const SizedBox(height: TrueStepSpacing.xs),
            Text(
              label,
              style: TrueStepTypography.caption.copyWith(
                color: TrueStepColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TrueStepColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        ),
        title: Text(
          'End Session?',
          style: TrueStepTypography.title.copyWith(
            color: TrueStepColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to end this session? Your progress will be saved.',
          style: TrueStepTypography.bodyMedium.copyWith(
            color: TrueStepColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: TrueStepColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final summary = await ref
                  .read(sessionProvider.notifier)
                  .completeSession();
              if (context.mounted) {
                context.go(AppRoutes.sessionComplete, extra: summary);
              }
            },
            child: Text(
              'End Session',
              style: TextStyle(color: TrueStepColors.interventionRed),
            ),
          ),
        ],
      ),
    );
  }
}
