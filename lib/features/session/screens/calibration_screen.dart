import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/session_provider.dart';

/// Calibration screen for camera setup before a session
///
/// Allows users to:
/// - Preview camera feed
/// - Position a reference object for scale calibration
/// - Complete or skip calibration
class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  bool _isCalibrating = false;

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(session.guide.title),
            Expanded(
              child: Stack(
                children: [
                  _buildCameraPreview(),
                  _buildPositioningOverlay(),
                  _buildInstructionCard(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String guideTitle) {
    return Padding(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: TrueStepColors.textPrimary,
            ),
            onPressed: () => _showExitConfirmation(),
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
                  'Step 1 of 3: Calibration',
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

  Widget _buildCameraPreview() {
    // Placeholder for camera preview - will be replaced with actual CameraPreview widget
    return Container(
      key: const Key('camera_preview'),
      decoration: BoxDecoration(
        color: TrueStepColors.bgSecondary,
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
      ),
      margin: const EdgeInsets.all(TrueStepSpacing.md),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 64, color: TrueStepColors.textTertiary),
            SizedBox(height: TrueStepSpacing.sm),
            Text(
              'Camera Preview',
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

  Widget _buildPositioningOverlay() {
    return Positioned.fill(
      key: const Key('positioning_overlay'),
      child: IgnorePointer(
        child: Container(
          margin: const EdgeInsets.all(TrueStepSpacing.md),
          child: CustomPaint(painter: _CalibrationOverlayPainter()),
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Positioned(
      top: TrueStepSpacing.xl * 2,
      left: TrueStepSpacing.md,
      right: TrueStepSpacing.md,
      child: GlassCard(
        padding: const EdgeInsets.all(TrueStepSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              color: TrueStepColors.accentBlue,
              size: 28,
            ),
            const SizedBox(height: TrueStepSpacing.sm),
            Text(
              'Camera Calibration',
              style: TrueStepTypography.title.copyWith(
                color: TrueStepColors.textPrimary,
              ),
            ),
            const SizedBox(height: TrueStepSpacing.sm),
            Text(
              'Position a reference object (like a coin) in the center of the frame for better scale detection.',
              style: TrueStepTypography.bodyMedium.copyWith(
                color: TrueStepColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(TrueStepSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: _isCalibrating ? 'Calibrating...' : 'Complete Calibration',
            onPressed: _isCalibrating ? null : _completeCalibration,
            isLoading: _isCalibrating,
          ),
          const SizedBox(height: TrueStepSpacing.md),
          TextButton(
            onPressed: _showSkipWarning,
            child: Text(
              'Skip',
              style: TrueStepTypography.bodyMedium.copyWith(
                color: TrueStepColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeCalibration() async {
    setState(() => _isCalibrating = true);

    // Simulate calibration process
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    ref.read(sessionProvider.notifier).completeCalibration();

    setState(() => _isCalibrating = false);

    // Navigate to next screen (will be handled by router in integration)
    if (mounted) {
      _navigateToToolAudit();
    }
  }

  void _showSkipWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TrueStepColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        ),
        title: Text(
          'Skip Calibration?',
          style: TrueStepTypography.title.copyWith(
            color: TrueStepColors.textPrimary,
          ),
        ),
        content: Text(
          'Skipping calibration may reduce accuracy of visual verification. The AI will still work, but results may be less precise.',
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
            onPressed: () {
              Navigator.of(context).pop();
              _skipCalibration();
            },
            child: Text(
              'Skip Anyway',
              style: TextStyle(color: TrueStepColors.analysisYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _skipCalibration() {
    ref.read(sessionProvider.notifier).skipCalibration();
    _navigateToToolAudit();
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TrueStepColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        ),
        title: Text(
          'Exit Session?',
          style: TrueStepTypography.title.copyWith(
            color: TrueStepColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to exit? Your session progress will be lost.',
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
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(sessionProvider.notifier).cancelSession();
              Navigator.of(context).pop(); // Exit calibration screen
            },
            child: Text(
              'Exit',
              style: TextStyle(color: TrueStepColors.interventionRed),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToToolAudit() {
    // TODO: Implement navigation to Tool Audit screen
    // For now, this is a placeholder - will be wired via GoRouter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proceeding to Tool Audit...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

/// Custom painter for the calibration positioning overlay
class _CalibrationOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TrueStepColors.accentBlue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    const circleRadius = 60.0;

    // Draw center circle
    canvas.drawCircle(center, circleRadius, paint);

    // Draw crosshairs
    const crossLength = 20.0;
    canvas.drawLine(
      Offset(center.dx - circleRadius - crossLength, center.dy),
      Offset(center.dx - circleRadius + 10, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + circleRadius - 10, center.dy),
      Offset(center.dx + circleRadius + crossLength, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - circleRadius - crossLength),
      Offset(center.dx, center.dy - circleRadius + 10),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + circleRadius - 10),
      Offset(center.dx, center.dy + circleRadius + crossLength),
      paint,
    );

    // Draw corner brackets
    final cornerPaint = Paint()
      ..color = TrueStepColors.textSecondary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const margin = 40.0;
    const bracketLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin + bracketLength, margin),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin, margin + bracketLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin - bracketLength, margin),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + bracketLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + bracketLength, size.height - margin),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin, size.height - margin - bracketLength),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin - bracketLength, size.height - margin),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - bracketLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
