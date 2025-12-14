import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

/// Custom bottom navigation bar with 5 tabs
///
/// Tabs: Search, Community, Quick+ (FAB), History, Profile
/// Features:
/// - Central Quick+ button with elevated FAB style
/// - Active state with glow effect
/// - Badge indicators for notifications
class BottomNavBar extends StatelessWidget {
  /// Currently selected tab index (0-4, excluding Quick+ at index 2)
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  /// Callback when Quick+ button is tapped
  final VoidCallback? onQuickActionTap;

  /// Number of notifications to show on badge
  final int notificationCount;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onQuickActionTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TrueStepColors.bgSecondary,
        border: Border(
          top: BorderSide(
            color: TrueStepColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Search
              _NavItem(
                icon: Icons.search,
                label: 'Search',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),

              // Community
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Community',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              // Quick+ (Center FAB)
              _QuickActionButton(
                onTap: onQuickActionTap,
              ),

              // History
              _NavItem(
                icon: Icons.history,
                label: 'History',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
                badgeCount: notificationCount,
              ),

              // Profile
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = TrueStepColors.accentBlue;
    final inactiveColor = TrueStepColors.textTertiary;
    final displayIcon = isActive ? (activeIcon ?? icon) : icon;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with optional badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Glow effect for active state
                if (isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                Icon(
                  displayIcon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 24,
                ),
                // Badge
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: _Badge(count: badgeCount),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TrueStepTypography.caption.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick+ center button (FAB style)
class _QuickActionButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _QuickActionButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TrueStepColors.accentBlue,
              TrueStepColors.accentPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TrueStepColors.accentBlue.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: TrueStepColors.textPrimary,
          size: 28,
        ),
      ),
    );
  }
}

/// Notification badge
class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final displayText = count > 9 ? '9+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: TrueStepColors.interventionRed,
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        displayText,
        style: TrueStepTypography.caption.copyWith(
          color: TrueStepColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
