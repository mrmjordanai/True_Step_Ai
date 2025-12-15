import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../widgets/omni_bar.dart';

/// Home screen - "The Briefing"
///
/// Main hub with:
/// - Greeting header with notification bell
/// - Omni-Bar for URL/text/voice input
/// - Recent Sessions carousel
/// - Featured Guides section
/// - Quick Actions grid
class HomeScreen extends ConsumerWidget {
  /// Callback when Omni-Bar is tapped (deprecated, use onOmniBarSubmit)
  final VoidCallback? onOmniBarTap;

  /// Callback when text is submitted via Omni-Bar (URL or task description)
  final void Function(String input)? onOmniBarSubmit;

  /// Callback when voice input is requested via Omni-Bar
  final VoidCallback? onVoiceTap;

  /// Callback when notification bell is tapped
  final VoidCallback? onNotificationTap;

  /// Callback when a quick action is tapped
  final void Function(String action)? onQuickAction;

  const HomeScreen({
    super.key,
    this.onOmniBarTap,
    this.onOmniBarSubmit,
    this.onVoiceTap,
    this.onNotificationTap,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueStepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TrueStepSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: TrueStepSpacing.lg),

                // Omni-Bar
                OmniBar(
                  onTap: onOmniBarTap,
                  onSubmit: onOmniBarSubmit,
                  onMicTap: onVoiceTap,
                ),
                const SizedBox(height: TrueStepSpacing.xl),

                // Recent Sessions
                _buildRecentSessions(),
                const SizedBox(height: TrueStepSpacing.xl),

                // Featured Guides
                _buildFeaturedGuides(),
                const SizedBox(height: TrueStepSpacing.xl),

                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: TrueStepSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting and badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello there!',
              style: TrueStepTypography.headline,
            ),
            const SizedBox(height: TrueStepSpacing.xs),
            // Subscription badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TrueStepSpacing.sm,
                vertical: TrueStepSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: TrueStepColors.glassSurface,
                borderRadius: BorderRadius.circular(TrueStepSpacing.radiusSm),
                border: Border.all(
                  color: TrueStepColors.glassBorder,
                ),
              ),
              child: Text(
                'Free',
                style: TrueStepTypography.caption.copyWith(
                  color: TrueStepColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        // Notification bell
        IconButton(
          onPressed: onNotificationTap,
          icon: const Icon(
            Icons.notifications_outlined,
            color: TrueStepColors.textPrimary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: TrueStepTypography.title,
        ),
        const SizedBox(height: TrueStepSpacing.md),

        // Empty state for now
        GlassCard(
          padding: const EdgeInsets.all(TrueStepSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: TrueStepColors.textTertiary,
              ),
              const SizedBox(height: TrueStepSpacing.md),
              Text(
                'No recent sessions',
                style: TrueStepTypography.bodyLarge.copyWith(
                  color: TrueStepColors.textSecondary,
                ),
              ),
              const SizedBox(height: TrueStepSpacing.xs),
              Text(
                'Start your first guided session!',
                style: TrueStepTypography.caption.copyWith(
                  color: TrueStepColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedGuides() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Guides',
              style: TrueStepTypography.title,
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TrueStepTypography.body.copyWith(
                  color: TrueStepColors.accentBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TrueStepSpacing.md),

        // Featured guides horizontal scroll
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildGuideCard(
                title: 'Perfect Scrambled Eggs',
                category: 'Cooking',
                duration: '10 min',
                icon: Icons.egg,
                color: TrueStepColors.analysisYellow,
              ),
              const SizedBox(width: TrueStepSpacing.md),
              _buildGuideCard(
                title: 'iPhone Battery Replace',
                category: 'DIY',
                duration: '45 min',
                icon: Icons.phone_iphone,
                color: TrueStepColors.accentBlue,
              ),
              const SizedBox(width: TrueStepSpacing.md),
              _buildGuideCard(
                title: 'Fix a Leaky Faucet',
                category: 'DIY',
                duration: '30 min',
                icon: Icons.plumbing,
                color: TrueStepColors.accentPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard({
    required String title,
    required String category,
    required String duration,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(TrueStepSpacing.md),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: TrueStepSpacing.sm),

            // Title
            Text(
              title,
              style: TrueStepTypography.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Category and duration
            Row(
              children: [
                Flexible(
                  child: Text(
                    category,
                    style: TrueStepTypography.caption.copyWith(
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: TrueStepSpacing.xs),
                Text(
                  duration,
                  style: TrueStepTypography.caption.copyWith(
                    color: TrueStepColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TrueStepTypography.title,
        ),
        const SizedBox(height: TrueStepSpacing.md),

        // Quick action buttons
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Scan',
                color: TrueStepColors.sentinelGreen,
                onTap: () => onQuickAction?.call('scan'),
              ),
            ),
            const SizedBox(width: TrueStepSpacing.md),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.link,
                label: 'Paste URL',
                color: TrueStepColors.accentBlue,
                onTap: () => onQuickAction?.call('paste_url'),
              ),
            ),
            const SizedBox(width: TrueStepSpacing.md),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.mic,
                label: 'Voice',
                color: TrueStepColors.accentPurple,
                onTap: () => onQuickAction?.call('voice'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          vertical: TrueStepSpacing.md,
          horizontal: TrueStepSpacing.sm,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: TrueStepSpacing.sm),
            Text(
              label,
              style: TrueStepTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
