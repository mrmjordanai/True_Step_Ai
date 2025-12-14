/// TrueStep Design System - Spacing
/// Based on 8dp base unit system
class TrueStepSpacing {
  TrueStepSpacing._();

  // ============================================
  // BASE SPACING UNITS
  // ============================================

  /// Extra small spacing - 4dp
  static const double xs = 4.0;

  /// Small spacing - 8dp (base unit)
  static const double sm = 8.0;

  /// Medium spacing - 16dp
  static const double md = 16.0;

  /// Large spacing - 24dp
  static const double lg = 24.0;

  /// Extra large spacing - 32dp
  static const double xl = 32.0;

  /// Extra extra large spacing - 48dp
  static const double xxl = 48.0;

  // ============================================
  // COMPONENT-SPECIFIC SPACING
  // ============================================

  /// Default page padding
  static const double pagePadding = md;

  /// Card internal padding
  static const double cardPadding = md;

  /// List item spacing
  static const double listItemSpacing = sm;

  /// Section spacing (between major sections)
  static const double sectionSpacing = xl;

  /// Button internal padding horizontal
  static const double buttonPaddingH = lg;

  /// Button internal padding vertical
  static const double buttonPaddingV = md;

  // ============================================
  // BORDER RADIUS
  // ============================================

  /// Small border radius - 8dp
  static const double radiusSm = 8.0;

  /// Medium border radius - 12dp (default for buttons/cards)
  static const double radiusMd = 12.0;

  /// Large border radius - 16dp (for larger cards)
  static const double radiusLg = 16.0;

  /// Extra large border radius - 24dp
  static const double radiusXl = 24.0;

  /// Pill border radius - 28dp (for pill-shaped buttons)
  static const double radiusPill = 28.0;

  /// Full circle radius
  static const double radiusFull = 9999.0;

  // ============================================
  // TOUCH TARGETS (Accessibility)
  // ============================================

  /// Minimum touch target size - 48dp (WCAG requirement)
  static const double minTouchTarget = 48.0;

  /// Standard button height - 56dp
  static const double buttonHeight = 56.0;

  /// Pill button height - 40dp
  static const double pillButtonHeight = 40.0;

  /// Icon button size - 48dp
  static const double iconButtonSize = 48.0;

  /// Minimum spacing between touch targets - 8dp
  static const double touchTargetSpacing = 8.0;

  // ============================================
  // GLASS MORPHISM
  // ============================================

  /// Glass blur sigma - 20dp
  static const double glassBlur = 20.0;

  /// Glass blur sigma for lighter effect - 16dp
  static const double glassBlurLight = 16.0;

  /// Glass blur sigma for heavier effect - 30dp
  static const double glassBlurHeavy = 30.0;

  // ============================================
  // ANIMATION DURATIONS (milliseconds)
  // ============================================

  /// Micro animation - 100ms (feedback)
  static const int animationMicro = 100;

  /// State change animation - 200ms
  static const int animationState = 200;

  /// Enter/exit animation - 300ms
  static const int animationEnterExit = 300;

  /// Complex animation - 400-600ms
  static const int animationComplex = 500;

  /// Celebration animation - 1000ms
  static const int animationCelebration = 1000;

  // ============================================
  // ELEVATION / SHADOWS
  // ============================================

  /// Low elevation - 2dp
  static const double elevationLow = 2.0;

  /// Medium elevation - 4dp
  static const double elevationMd = 4.0;

  /// High elevation - 8dp
  static const double elevationHigh = 8.0;

  /// Glow spread radius - 30dp
  static const double glowSpread = 30.0;
}
