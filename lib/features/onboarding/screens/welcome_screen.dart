import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/page_indicator.dart';

/// Welcome screen with 3-page carousel introducing TrueStep
///
/// Pages:
/// 1. "Your AI Repair Partner" - Introduction
/// 2. "Visual Verification" - Key feature
/// 3. "Mistake Insurance" - Value proposition
class WelcomeScreen extends ConsumerStatefulWidget {
  /// Callback when Get Started is tapped
  final VoidCallback? onGetStarted;

  /// Callback when Sign In is tapped
  final VoidCallback? onSignIn;

  /// Callback when Skip is tapped
  final VoidCallback? onSkip;

  const WelcomeScreen({
    super.key,
    this.onGetStarted,
    this.onSignIn,
    this.onSkip,
  });

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  static const _pages = [
    _WelcomePageData(
      title: 'Your AI Repair Partner',
      subtitle: 'Never miss a step again',
      icon: Icons.visibility,
      iconColor: TrueStepColors.sentinelGreen,
    ),
    _WelcomePageData(
      title: 'Visual Verification',
      subtitle: 'AI that actually watches',
      icon: Icons.traffic,
      iconColor: TrueStepColors.analysisYellow,
    ),
    _WelcomePageData(
      title: 'Mistake Insurance',
      subtitle: 'Protected when it matters',
      icon: Icons.shield,
      iconColor: TrueStepColors.accentBlue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Get saved page from provider
    final savedPage = ref.read(currentPageProvider);
    _currentPage = savedPage.clamp(0, _pages.length - 1);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // Save current page to provider
    ref.read(onboardingNotifierProvider.notifier).setCurrentPage(page);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
          child: Column(
            children: [
              // Skip button
              _buildSkipButton(),

              // PageView carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _WelcomePage(data: _pages[index]);
                  },
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TrueStepSpacing.md,
                ),
                child: PageIndicator(
                  pageCount: _pages.length,
                  currentPage: _currentPage,
                  onDotTap: _goToPage,
                ),
              ),

              // Bottom buttons
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(TrueStepSpacing.md),
        child: TextButton(
          onPressed: widget.onSkip,
          child: Semantics(
            label: 'Skip',
            excludeSemantics: true,
            child: Text(
              'Skip',
              style: TrueStepTypography.body.copyWith(
                color: TrueStepColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(TrueStepSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Get Started button
          PrimaryButton(
            label: 'Get Started',
            onPressed: widget.onGetStarted,
          ),
          const SizedBox(height: TrueStepSpacing.md),

          // Sign In link
          TextButton(
            onPressed: widget.onSignIn,
            child: Text(
              'Already have an account? Sign In',
              style: TrueStepTypography.body.copyWith(
                color: TrueStepColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for welcome page content
class _WelcomePageData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _WelcomePageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

/// Individual welcome page widget
class _WelcomePage extends StatelessWidget {
  final _WelcomePageData data;

  const _WelcomePage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TrueStepSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/illustration placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: data.iconColor.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.iconColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 56,
              color: data.iconColor,
            ),
          ),
          const SizedBox(height: TrueStepSpacing.xl),

          // Title
          Text(
            data.title,
            style: TrueStepTypography.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TrueStepSpacing.sm),

          // Subtitle
          Text(
            data.subtitle,
            style: TrueStepTypography.body.copyWith(
              color: TrueStepColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
