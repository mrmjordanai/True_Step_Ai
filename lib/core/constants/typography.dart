import 'package:flutter/material.dart';
import 'colors.dart';

/// TrueStep Design System - Typography
/// iOS: SF Pro Display/Text
/// Android: Roboto (system default)
class TrueStepTypography {
  TrueStepTypography._();

  // ============================================
  // FONT FAMILIES
  // ============================================

  /// Primary font family (system default handles SF Pro on iOS, Roboto on Android)
  static const String fontFamily = 'Roboto';

  // ============================================
  // FONT WEIGHTS
  // ============================================

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============================================
  // TEXT STYLES
  // ============================================

  /// Display - 32sp Bold, 40sp line height
  /// Used for: Hero text, large headlines
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    height: 1.25, // 40sp line height
    color: TrueStepColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Headline - 24sp Semibold, 32sp line height
  /// Used for: Section headers, screen titles
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.33, // 32sp line height
    color: TrueStepColors.textPrimary,
    letterSpacing: -0.25,
  );

  /// Title - 20sp Semibold, 28sp line height
  /// Used for: Card titles, subsection headers
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4, // 28sp line height
    color: TrueStepColors.textPrimary,
  );

  /// Title Small - 18sp Medium, 24sp line height
  /// Used for: Smaller titles, list headers
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: medium,
    height: 1.33, // 24sp line height
    color: TrueStepColors.textPrimary,
  );

  /// Body Large - 16sp Regular, 24sp line height
  /// Used for: Primary body text, instructions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5, // 24sp line height
    color: TrueStepColors.textPrimary,
  );

  /// Body - 14sp Regular, 20sp line height
  /// Used for: Secondary body text, descriptions
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.43, // 20sp line height
    color: TrueStepColors.textSecondary,
  );

  /// Body Medium - 14sp Medium, 20sp line height
  /// Used for: Emphasized body text, labels
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.43, // 20sp line height
    color: TrueStepColors.textPrimary,
  );

  /// Caption - 12sp Regular, 16sp line height
  /// Used for: Timestamps, metadata, helper text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.33, // 16sp line height
    color: TrueStepColors.textTertiary,
  );

  /// Overline - 10sp Medium, 14sp line height
  /// Used for: Labels, tags, category text
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    height: 1.4, // 14sp line height
    color: TrueStepColors.textTertiary,
    letterSpacing: 1.5,
  );

  /// Button - 14sp Semibold
  /// Used for: Button labels
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.43,
    color: TrueStepColors.textPrimary,
    letterSpacing: 0.5,
  );

  /// Button Large - 16sp Semibold
  /// Used for: Primary button labels
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
    color: TrueStepColors.textPrimary,
    letterSpacing: 0.25,
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Create a text style with a specific color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Create a text style for traffic light states
  static TextStyle trafficLightStyle(TrafficLightState state) {
    return bodyLarge.copyWith(
      color: TrueStepColors.getTrafficLightColor(state),
      fontWeight: semiBold,
    );
  }
}
