import 'package:flutter/material.dart';

/// TrueStep Design System - Color Palette
/// Based on "The Glass Sentinel" design philosophy
///
/// Traffic Light System:
/// - Green: Watching, verified, success
/// - Yellow: Processing, analyzing, uncertain
/// - Red: Danger, stop, intervention
class TrueStepColors {
  TrueStepColors._();

  // ============================================
  // BACKGROUND COLORS
  // ============================================

  /// Primary background - Deep void (#0A0A0A)
  static const Color bgPrimary = Color(0xFF0A0A0A);

  /// Secondary background (#121212)
  static const Color bgSecondary = Color(0xFF121212);

  /// Surface background (#1E1E1E)
  static const Color bgSurface = Color(0xFF1E1E1E);

  // ============================================
  // GLASS MORPHISM COLORS
  // ============================================

  /// Glass overlay - 8% white opacity
  static const Color glassOverlay = Color(0x14FFFFFF);

  /// Glass border - 12% white opacity
  static const Color glassBorder = Color(0x1FFFFFFF);

  /// Glass surface for cards and containers
  static const Color glassSurface = Color(0x14FFFFFF);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text - Pure white
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - Muted (#B3B3B3)
  static const Color textSecondary = Color(0xFFB3B3B3);

  /// Tertiary text - Subtle (#666666)
  static const Color textTertiary = Color(0xFF666666);

  /// Disabled text
  static const Color textDisabled = Color(0xFF4D4D4D);

  // ============================================
  // TRAFFIC LIGHT COLORS - Core System
  // ============================================

  /// Sentinel Green - Watching, verified, success (#00E676)
  static const Color sentinelGreen = Color(0xFF00E676);

  /// Analysis Yellow - Processing, uncertain (#FFC400)
  static const Color analysisYellow = Color(0xFFFFC400);

  /// Intervention Red - Danger, stop (#FF3D00)
  static const Color interventionRed = Color(0xFFFF3D00);

  // ============================================
  // TRAFFIC LIGHT GLOW COLORS
  // ============================================

  /// Green glow for shadows and highlights
  static const Color sentinelGreenGlow = Color(0x4D00E676);

  /// Yellow glow for shadows and highlights
  static const Color analysisYellowGlow = Color(0x4DFFC400);

  /// Red glow for shadows and highlights
  static const Color interventionRedGlow = Color(0x66FF3D00);

  // ============================================
  // ACCENT COLORS
  // ============================================

  /// Primary accent blue (#2979FF)
  static const Color accentBlue = Color(0xFF2979FF);

  /// Secondary accent purple (#7C4DFF)
  static const Color accentPurple = Color(0xFF7C4DFF);

  /// Accent cyan for highlights
  static const Color accentCyan = Color(0xFF00E5FF);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success color (alias for sentinel green)
  static const Color success = sentinelGreen;

  /// Warning color (alias for analysis yellow)
  static const Color warning = analysisYellow;

  /// Error color (alias for intervention red)
  static const Color error = interventionRed;

  /// Info color
  static const Color info = accentBlue;

  // ============================================
  // BUTTON COLORS
  // ============================================

  /// Primary button background
  static const Color buttonPrimary = accentBlue;

  /// Secondary button background (transparent)
  static const Color buttonSecondary = Colors.transparent;

  /// Danger button background
  static const Color buttonDanger = interventionRed;

  // ============================================
  // GRADIENT DEFINITIONS
  // ============================================

  /// Main background gradient
  static const RadialGradient backgroundGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.5,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF0A0A0A),
    ],
  );

  /// Green state gradient
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00E676),
      Color(0xFF00C853),
    ],
  );

  /// Yellow state gradient
  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFC400),
      Color(0xFFFFAB00),
    ],
  );

  /// Red state gradient
  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF3D00),
      Color(0xFFDD2C00),
    ],
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get traffic light color by state
  static Color getTrafficLightColor(TrafficLightState state) {
    switch (state) {
      case TrafficLightState.green:
        return sentinelGreen;
      case TrafficLightState.yellow:
        return analysisYellow;
      case TrafficLightState.red:
        return interventionRed;
    }
  }

  /// Get traffic light glow color by state
  static Color getTrafficLightGlow(TrafficLightState state) {
    switch (state) {
      case TrafficLightState.green:
        return sentinelGreenGlow;
      case TrafficLightState.yellow:
        return analysisYellowGlow;
      case TrafficLightState.red:
        return interventionRedGlow;
    }
  }
}

/// Traffic light states for the sentinel system
enum TrafficLightState {
  /// Green - Watching, verified, success
  green,

  /// Yellow - Processing, analyzing
  yellow,

  /// Red - Intervention required, danger
  red,
}
