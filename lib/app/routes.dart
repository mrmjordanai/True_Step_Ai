import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/colors.dart';
import '../core/constants/typography.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/permissions_screen.dart';
import '../features/onboarding/screens/account_screen.dart';
import '../features/onboarding/screens/first_task_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';

// ============================================
// ROUTE PATHS
// ============================================

/// Route path constants for type-safe navigation
class AppRoutes {
  AppRoutes._();

  // Onboarding
  static const String welcome = '/welcome';
  static const String permissions = '/permissions';
  static const String accountSetup = '/account-setup';
  static const String firstTask = '/first-task';

  // Main
  static const String home = '/';
  static const String search = '/search';
  static const String profile = '/profile';

  // Session (with path parameters for deep linking)
  static const String sessionPreview = '/session/preview/:guideId';
  static const String sessionCalibration = '/session/calibration';
  static const String sessionToolAudit = '/session/tool-audit';
  static const String sessionActive = '/session/active';
  static const String sessionComplete = '/session/complete';

  // Community
  static const String community = '/community';
  static const String communityVideo = '/community/video/:videoId';
  static const String communityCreator = '/community/creator/:creatorId';

  // History (with path parameter for deep linking)
  static const String history = '/history';
  static const String historyDetail = '/history/:sessionId';

  // Claims
  static const String claimStart = '/claim/start';
  static const String claimDamage = '/claim/damage';
  static const String claimDescription = '/claim/description';
  static const String claimReview = '/claim/review';
  static const String claimStatus = '/claim/status';

  // Settings
  static const String settings = '/settings';
  static const String settingsData = '/settings/data';

  // Paywall
  static const String upgrade = '/upgrade';
  static const String subscription = '/subscription';

  // Helper methods for building paths with parameters
  static String sessionPreviewPath(String guideId) => '/session/preview/$guideId';
  static String historyDetailPath(String sessionId) => '/history/$sessionId';
  static String communityVideoPath(String videoId) => '/community/video/$videoId';
  static String communityCreatorPath(String creatorId) => '/community/creator/$creatorId';
}

// ============================================
// ROUTER PROVIDER
// ============================================

/// GoRouter provider for navigation
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // ========== MAIN NAVIGATION SHELL ==========
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Home (index 0)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => HomeScreen(
                  onNotificationTap: () {
                    // TODO: Navigate to notifications
                  },
                  onOmniBarTap: () {
                    // TODO: Open omni-bar input
                  },
                  onQuickAction: (action) {
                    // TODO: Handle quick actions
                  },
                ),
              ),
            ],
          ),
          // Search (index 1)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (context, state) => SearchScreen(
                  onVoiceTap: () {
                    // TODO: Activate voice search
                  },
                  onSearch: (query) {
                    // TODO: Perform search
                  },
                  onCategorySelected: (category) {
                    // TODO: Filter by category
                  },
                  onGuideTap: (guideId) {
                    context.go(AppRoutes.sessionPreviewPath(guideId));
                  },
                ),
              ),
            ],
          ),
          // Community (index 2)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.community,
                name: 'community',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'Community',
                  subtitle: 'Shared sessions',
                ),
              ),
            ],
          ),
          // History (index 3)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: 'history',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'History',
                  subtitle: 'Past sessions',
                ),
              ),
            ],
          ),
          // Profile (index 4)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'Profile',
                  subtitle: 'Your account',
                ),
              ),
            ],
          ),
        ],
      ),

      // ========== ONBOARDING ==========
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => WelcomeScreen(
          onGetStarted: () => context.go(AppRoutes.permissions),
          onSignIn: () => context.go(AppRoutes.accountSetup),
        ),
      ),
      GoRoute(
        path: AppRoutes.permissions,
        name: 'permissions',
        builder: (context, state) => PermissionsScreen(
          onContinue: () => context.go(AppRoutes.accountSetup),
          onSkip: () => context.go(AppRoutes.accountSetup),
        ),
      ),
      GoRoute(
        path: AppRoutes.accountSetup,
        name: 'accountSetup',
        builder: (context, state) => AccountScreen(
          onContinue: () => context.go(AppRoutes.firstTask),
        ),
      ),
      GoRoute(
        path: AppRoutes.firstTask,
        name: 'firstTask',
        builder: (context, state) => FirstTaskScreen(
          onComplete: () => context.go(AppRoutes.home),
        ),
      ),

      // ========== SESSION ==========
      GoRoute(
        path: AppRoutes.sessionPreview,
        name: 'sessionPreview',
        builder: (context, state) {
          final guideId = state.pathParameters['guideId'] ?? 'unknown';
          return _PlaceholderScreen(
            title: 'Session Preview',
            subtitle: 'Guide: $guideId',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sessionCalibration,
        name: 'sessionCalibration',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Calibration',
          subtitle: 'Camera setup',
        ),
      ),
      GoRoute(
        path: AppRoutes.sessionToolAudit,
        name: 'sessionToolAudit',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Tool Audit',
          subtitle: 'Verify your tools',
        ),
      ),
      GoRoute(
        path: AppRoutes.sessionActive,
        name: 'sessionActive',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Active Session',
          subtitle: 'In progress',
        ),
      ),
      GoRoute(
        path: AppRoutes.sessionComplete,
        name: 'sessionComplete',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Complete!',
          subtitle: 'Well done',
        ),
      ),

      // ========== COMMUNITY SUB-ROUTES ==========
      GoRoute(
        path: AppRoutes.communityVideo,
        name: 'communityVideo',
        builder: (context, state) {
          final videoId = state.pathParameters['videoId'] ?? 'unknown';
          return _PlaceholderScreen(
            title: 'Community Video',
            subtitle: 'Video: $videoId',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.communityCreator,
        name: 'communityCreator',
        builder: (context, state) {
          final creatorId = state.pathParameters['creatorId'] ?? 'unknown';
          return _PlaceholderScreen(
            title: 'Creator Profile',
            subtitle: 'Creator: $creatorId',
          );
        },
      ),

      // ========== HISTORY SUB-ROUTES ==========
      GoRoute(
        path: AppRoutes.historyDetail,
        name: 'historyDetail',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? 'unknown';
          return _PlaceholderScreen(
            title: 'Session Detail',
            subtitle: 'Session: $sessionId',
          );
        },
      ),

      // ========== SETTINGS ==========
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Settings',
          subtitle: 'App configuration',
        ),
      ),

      // ========== PAYWALL ==========
      GoRoute(
        path: AppRoutes.upgrade,
        name: 'upgrade',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Upgrade',
          subtitle: 'TrueStep Pro',
        ),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => _PlaceholderScreen(
      title: 'Page Not Found',
      subtitle: state.uri.toString(),
      isError: true,
    ),
  );
});

// ============================================
// PLACEHOLDER SCREEN
// ============================================

/// Temporary placeholder screen for routes
/// Will be replaced with actual screens in Phase 1+
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    this.isError = false,
  });

  final String title;
  final String subtitle;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueStepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isError
                          ? TrueStepColors.interventionRed.withValues(alpha: 0.2)
                          : TrueStepColors.sentinelGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isError
                            ? TrueStepColors.interventionRed.withValues(alpha: 0.5)
                            : TrueStepColors.sentinelGreen.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isError ? Icons.error_outline : Icons.check_circle_outline,
                      size: 40,
                      color: isError
                          ? TrueStepColors.interventionRed
                          : TrueStepColors.sentinelGreen,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    title,
                    style: TrueStepTypography.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    subtitle,
                    style: TrueStepTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Phase indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TrueStepColors.glassSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: TrueStepColors.glassBorder,
                      ),
                    ),
                    child: Text(
                      'Phase 0 Complete',
                      style: TrueStepTypography.caption.copyWith(
                        color: TrueStepColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// MAIN NAVIGATION SHELL
// ============================================

/// Shell widget that wraps main screens with bottom navigation
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // Navigate to the corresponding branch
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        onQuickActionTap: () {
          // TODO: Show quick action modal/overlay
        },
        notificationCount: 0, // TODO: Get from provider
      ),
    );
  }
}
