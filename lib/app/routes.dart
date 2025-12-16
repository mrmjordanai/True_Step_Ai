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
import '../features/home/widgets/quick_action_modal.dart';
import '../features/search/screens/search_screen.dart';
import '../features/session/screens/guide_preview_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/providers/ingestion_provider.dart';
import '../services/ingestion_service.dart';
import '../core/models/guide.dart';

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
                builder: (context, state) => const _HomeScreenWrapper(),
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
          // Guide is passed via extra parameter from ingestion flow
          final guide = state.extra as Guide?;
          if (guide != null) {
            return GuidePreviewScreen(
              guide: guide,
              onStartSession: () {
                // TODO: Navigate to calibration screen (Phase 1.6)
                context.push(AppRoutes.sessionCalibration);
              },
              onBack: () => context.pop(),
            );
          }
          // Fallback if no guide was passed (e.g., deep link without data)
          final guideId = state.pathParameters['guideId'] ?? 'unknown';
          return _PlaceholderScreen(
            title: 'Guide Not Found',
            subtitle: 'Guide ID: $guideId',
            isError: true,
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
          showQuickActionModal(
            context,
            onActionSelected: (action) {
              // Handle the selected action
              switch (action) {
                case QuickAction.pasteUrl:
                  // TODO: Open URL paste dialog or navigate to search
                  break;
                case QuickAction.describeTask:
                  // TODO: Navigate to home and focus OmniBar
                  break;
                case QuickAction.voiceInput:
                  // TODO: Activate voice input
                  break;
                case QuickAction.scanQr:
                  // TODO: Open QR scanner
                  break;
              }
            },
          );
        },
        notificationCount: 0, // TODO: Get from provider
      ),
    );
  }
}

// ============================================
// HOME SCREEN WRAPPER (with ingestion handling)
// ============================================

/// Wrapper for HomeScreen that handles ingestion flow
class _HomeScreenWrapper extends ConsumerStatefulWidget {
  const _HomeScreenWrapper();

  @override
  ConsumerState<_HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends ConsumerState<_HomeScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize the ingestion service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ingestionServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to ingestion state changes
    ref.listen<IngestionState>(ingestionNotifierProvider, (previous, next) {
      if (next.status == IngestionStatus.success && next.guide != null) {
        // Navigate to guide preview on success
        final guide = next.guide!;
        context.push(
          AppRoutes.sessionPreviewPath(guide.guideId),
          extra: guide,
        );
        // Reset ingestion state
        ref.read(ingestionNotifierProvider.notifier).reset();
      } else if (next.status == IngestionStatus.error && next.error != null) {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.message),
            backgroundColor: TrueStepColors.interventionRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear error
        ref.read(ingestionNotifierProvider.notifier).clearError();
      }
    });

    final ingestionState = ref.watch(ingestionNotifierProvider);

    return Stack(
      children: [
        HomeScreen(
          onNotificationTap: () {
            // TODO: Navigate to notifications
          },
          onOmniBarSubmit: (input) {
            // Trigger ingestion
            ref.read(ingestionNotifierProvider.notifier).ingest(input);
          },
          onVoiceTap: () {
            // TODO: Activate voice input
          },
          onQuickAction: (action) {
            // TODO: Handle quick actions
          },
        ),
        // Show loading overlay when ingesting
        if (ingestionState.isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: TrueStepColors.sentinelGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing...',
                    style: TextStyle(
                      color: TrueStepColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
