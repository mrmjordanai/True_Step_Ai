import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../services/permission_service.dart';
import '../../../shared/widgets/primary_button.dart';

/// Screen for requesting camera, microphone, and notification permissions
///
/// Shows a list of required permissions with their status and allows
/// users to grant them individually or all at once.
class PermissionsScreen extends ConsumerStatefulWidget {
  /// Callback when user taps Continue
  final VoidCallback onContinue;

  /// Optional callback when user taps Skip (if allowed)
  final VoidCallback? onSkip;

  const PermissionsScreen({
    super.key,
    required this.onContinue,
    this.onSkip,
  });

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _cameraGranted = false;
  bool _microphoneGranted = false;
  bool _notificationGranted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissionService = ref.read(permissionServiceProvider);

    final camera = await permissionService.hasCameraPermission();
    final microphone = await permissionService.hasMicrophonePermission();
    final notification = await permissionService.hasNotificationPermission();

    if (mounted) {
      setState(() {
        _cameraGranted = camera;
        _microphoneGranted = microphone;
        _notificationGranted = notification;
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _isLoading = true);

    final permissionService = ref.read(permissionServiceProvider);

    final camera = await permissionService.requestCameraPermission();
    final microphone = await permissionService.requestMicrophonePermission();
    final notification = await permissionService.requestNotificationPermission();

    if (mounted) {
      setState(() {
        _cameraGranted = camera;
        _microphoneGranted = microphone;
        _notificationGranted = notification;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.requestCameraPermission();
    if (mounted) {
      setState(() => _cameraGranted = granted);
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.requestMicrophonePermission();
    if (mounted) {
      setState(() => _microphoneGranted = granted);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.requestNotificationPermission();
    if (mounted) {
      setState(() => _notificationGranted = granted);
    }
  }

  /// Shows a warning modal about limitations when skipping permissions
  Future<void> _showLimitationsWarning() async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LimitationsWarningModal(
        cameraGranted: _cameraGranted,
        microphoneGranted: _microphoneGranted,
        notificationGranted: _notificationGranted,
      ),
    );

    if (shouldContinue == true && widget.onSkip != null) {
      widget.onSkip!();
    }
  }

  /// Handles the skip action - shows warning if permissions not granted
  void _handleSkip() {
    final allGranted = _cameraGranted && _microphoneGranted && _notificationGranted;

    if (allGranted) {
      // All permissions granted, no warning needed
      widget.onSkip?.call();
    } else {
      // Show limitations warning modal
      _showLimitationsWarning();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueStepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(TrueStepSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: TrueStepSpacing.xl),

                // Title
                Text(
                  'Enable Permissions',
                  style: TrueStepTypography.headline,
                ),
                const SizedBox(height: TrueStepSpacing.sm),

                // Subtitle
                Text(
                  'TrueStep needs access to watch and guide you',
                  style: TrueStepTypography.body.copyWith(
                    color: TrueStepColors.textSecondary,
                  ),
                ),
                const SizedBox(height: TrueStepSpacing.xl),

                // Permission items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _PermissionItem(
                          icon: Icons.camera_alt,
                          title: 'Camera',
                          description: 'Watch your work and verify each step',
                          isGranted: _cameraGranted,
                          onTap: _requestCameraPermission,
                        ),
                        const SizedBox(height: TrueStepSpacing.md),
                        _PermissionItem(
                          icon: Icons.mic,
                          title: 'Microphone',
                          description: 'Hear your voice commands',
                          isGranted: _microphoneGranted,
                          onTap: _requestMicrophonePermission,
                        ),
                        const SizedBox(height: TrueStepSpacing.md),
                        _PermissionItem(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          description: 'Alert you about session updates',
                          isGranted: _notificationGranted,
                          onTap: _requestNotificationPermission,
                        ),
                      ],
                    ),
                  ),
                ),

                // Enable All button
                PrimaryButton(
                  label: 'Enable All',
                  onPressed: _isLoading ? null : _requestAllPermissions,
                  isLoading: _isLoading,
                  variant: ButtonVariant.secondary,
                ),
                const SizedBox(height: TrueStepSpacing.md),

                // Continue button
                PrimaryButton(
                  label: 'Continue',
                  onPressed: widget.onContinue,
                ),

                // Skip link
                if (widget.onSkip != null) ...[
                  const SizedBox(height: TrueStepSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: _handleSkip,
                      child: Text(
                        'Skip for now',
                        style: TrueStepTypography.body.copyWith(
                          color: TrueStepColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual permission item widget
class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(TrueStepSpacing.md),
        decoration: BoxDecoration(
          color: TrueStepColors.glassSurface,
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          border: Border.all(
            color: isGranted
                ? TrueStepColors.sentinelGreen.withValues(alpha: 0.3)
                : TrueStepColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isGranted
                    ? TrueStepColors.sentinelGreen.withValues(alpha: 0.2)
                    : TrueStepColors.accentBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isGranted
                    ? TrueStepColors.sentinelGreen
                    : TrueStepColors.accentBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: TrueStepSpacing.md),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TrueStepTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TrueStepTypography.caption.copyWith(
                      color: TrueStepColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Status icon
            Icon(
              isGranted ? Icons.check_circle : Icons.circle_outlined,
              color: isGranted
                  ? TrueStepColors.sentinelGreen
                  : TrueStepColors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal dialog warning about limitations when skipping permissions
class _LimitationsWarningModal extends StatelessWidget {
  final bool cameraGranted;
  final bool microphoneGranted;
  final bool notificationGranted;

  const _LimitationsWarningModal({
    required this.cameraGranted,
    required this.microphoneGranted,
    required this.notificationGranted,
  });

  List<String> get _limitations {
    final limitations = <String>[];

    if (!cameraGranted) {
      limitations.add('Visual verification will not work - TrueStep cannot watch and verify your progress');
    }
    if (!microphoneGranted) {
      limitations.add('Voice commands will be disabled - you will need to use manual controls');
    }
    if (!notificationGranted) {
      limitations.add('You will not receive session updates or reminders');
    }

    return limitations;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: TrueStepColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TrueStepSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning icon and title
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: TrueStepColors.analysisYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: TrueStepColors.analysisYellow,
                    size: 28,
                  ),
                ),
                const SizedBox(width: TrueStepSpacing.md),
                Expanded(
                  child: Text(
                    'Limited Experience',
                    style: TrueStepTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TrueStepSpacing.lg),

            // Description
            Text(
              'Without these permissions, TrueStep will have limited functionality:',
              style: TrueStepTypography.body.copyWith(
                color: TrueStepColors.textSecondary,
              ),
            ),
            const SizedBox(height: TrueStepSpacing.md),

            // Limitations list
            ..._limitations.map((limitation) => Padding(
                  padding: const EdgeInsets.only(bottom: TrueStepSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.remove_circle_outline,
                        color: TrueStepColors.interventionRed,
                        size: 18,
                      ),
                      const SizedBox(width: TrueStepSpacing.sm),
                      Expanded(
                        child: Text(
                          limitation,
                          style: TrueStepTypography.caption.copyWith(
                            color: TrueStepColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: TrueStepSpacing.lg),

            // Note about enabling later
            Container(
              padding: const EdgeInsets.all(TrueStepSpacing.md),
              decoration: BoxDecoration(
                color: TrueStepColors.glassSurface,
                borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
                border: Border.all(color: TrueStepColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: TrueStepColors.accentBlue,
                    size: 20,
                  ),
                  const SizedBox(width: TrueStepSpacing.sm),
                  Expanded(
                    child: Text(
                      'You can enable permissions later in Settings',
                      style: TrueStepTypography.caption.copyWith(
                        color: TrueStepColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TrueStepSpacing.lg),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Go Back',
                      style: TrueStepTypography.buttonLarge.copyWith(
                        color: TrueStepColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TrueStepSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TrueStepColors.analysisYellow,
                      foregroundColor: TrueStepColors.bgPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Continue Anyway',
                      style: TrueStepTypography.buttonLarge.copyWith(
                        color: TrueStepColors.bgPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
