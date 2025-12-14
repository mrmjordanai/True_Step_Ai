import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

/// A page indicator widget for carousels and page views
///
/// Displays a row of dots where the active dot is wider and highlighted.
/// Supports custom colors, sizes, and tap callbacks.
class PageIndicator extends StatelessWidget {
  /// Number of pages to display dots for
  final int pageCount;

  /// Currently active page index (0-based)
  final int currentPage;

  /// Callback when a dot is tapped (optional)
  final void Function(int index)? onDotTap;

  /// Color for the active dot
  final Color activeColor;

  /// Color for inactive dots
  final Color inactiveColor;

  /// Size of inactive dots (active dot is 3x wider)
  final double dotSize;

  /// Spacing between dots
  final double spacing;

  /// Animation duration for transitions
  final Duration animationDuration;

  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.onDotTap,
    this.activeColor = TrueStepColors.accentBlue,
    this.inactiveColor = TrueStepColors.textTertiary,
    this.dotSize = 8.0,
    this.spacing = 8.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return GestureDetector(
          onTap: onDotTap != null ? () => onDotTap!(index) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: AnimatedContainer(
              duration: animationDuration,
              curve: Curves.easeInOut,
              constraints: BoxConstraints(
                maxWidth: isActive ? dotSize * 3 : dotSize,
                maxHeight: dotSize,
              ),
              width: isActive ? dotSize * 3 : dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(dotSize / 2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
