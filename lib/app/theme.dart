import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/typography.dart';

/// TrueStep App Theme
/// Dark mode default with glassmorphism design
class TrueStepTheme {
  TrueStepTheme._();

  /// Main dark theme for the app
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: TrueStepColors.accentBlue,
        secondary: TrueStepColors.accentPurple,
        surface: TrueStepColors.bgSurface,
        error: TrueStepColors.interventionRed,
        onPrimary: TrueStepColors.textPrimary,
        onSecondary: TrueStepColors.textPrimary,
        onSurface: TrueStepColors.textPrimary,
        onError: TrueStepColors.textPrimary,
      ),

      // Scaffold background
      scaffoldBackgroundColor: TrueStepColors.bgPrimary,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TrueStepTypography.title,
        iconTheme: IconThemeData(
          color: TrueStepColors.textPrimary,
          size: 24,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: TrueStepColors.glassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusLg),
          side: const BorderSide(
            color: TrueStepColors.glassBorder,
            width: 1,
          ),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TrueStepColors.buttonPrimary,
          foregroundColor: TrueStepColors.textPrimary,
          minimumSize: const Size(double.infinity, TrueStepSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: TrueStepSpacing.buttonPaddingH,
            vertical: TrueStepSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          ),
          textStyle: TrueStepTypography.buttonLarge,
          elevation: 0,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TrueStepColors.accentBlue,
          minimumSize: const Size(double.infinity, TrueStepSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: TrueStepSpacing.buttonPaddingH,
            vertical: TrueStepSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          ),
          side: const BorderSide(
            color: TrueStepColors.accentBlue,
            width: 1.5,
          ),
          textStyle: TrueStepTypography.buttonLarge,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TrueStepColors.accentBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: TrueStepSpacing.md,
            vertical: TrueStepSpacing.sm,
          ),
          textStyle: TrueStepTypography.button,
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: TrueStepColors.textPrimary,
          minimumSize: const Size(
            TrueStepSpacing.iconButtonSize,
            TrueStepSpacing.iconButtonSize,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TrueStepColors.glassSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TrueStepSpacing.md,
          vertical: TrueStepSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          borderSide: const BorderSide(color: TrueStepColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          borderSide: const BorderSide(color: TrueStepColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          borderSide: const BorderSide(
            color: TrueStepColors.accentBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          borderSide: const BorderSide(color: TrueStepColors.interventionRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          borderSide: const BorderSide(
            color: TrueStepColors.interventionRed,
            width: 2,
          ),
        ),
        labelStyle: TrueStepTypography.body,
        hintStyle: TrueStepTypography.body.copyWith(
          color: TrueStepColors.textTertiary,
        ),
        errorStyle: TrueStepTypography.caption.copyWith(
          color: TrueStepColors.interventionRed,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TrueStepColors.bgSurface,
        selectedItemColor: TrueStepColors.accentBlue,
        unselectedItemColor: TrueStepColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: TrueStepColors.accentBlue,
        foregroundColor: TrueStepColors.textPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusLg),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TrueStepColors.bgSurface,
        contentTextStyle: TrueStepTypography.body.copyWith(
          color: TrueStepColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: TrueStepColors.bgSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusLg),
        ),
        titleTextStyle: TrueStepTypography.title,
        contentTextStyle: TrueStepTypography.body,
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TrueStepColors.bgSurface,
        modalBackgroundColor: TrueStepColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TrueStepSpacing.radiusXl),
          ),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: TrueStepColors.glassBorder,
        thickness: 1,
        space: TrueStepSpacing.md,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TrueStepTypography.display,
        displayMedium: TrueStepTypography.headline,
        displaySmall: TrueStepTypography.title,
        headlineLarge: TrueStepTypography.headline,
        headlineMedium: TrueStepTypography.title,
        headlineSmall: TrueStepTypography.titleSmall,
        titleLarge: TrueStepTypography.title,
        titleMedium: TrueStepTypography.titleSmall,
        titleSmall: TrueStepTypography.bodyMedium,
        bodyLarge: TrueStepTypography.bodyLarge,
        bodyMedium: TrueStepTypography.body,
        bodySmall: TrueStepTypography.caption,
        labelLarge: TrueStepTypography.button,
        labelMedium: TrueStepTypography.bodyMedium,
        labelSmall: TrueStepTypography.overline,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TrueStepColors.accentBlue,
        circularTrackColor: TrueStepColors.glassBorder,
        linearTrackColor: TrueStepColors.glassBorder,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: TrueStepColors.glassSurface,
        selectedColor: TrueStepColors.accentBlue,
        disabledColor: TrueStepColors.bgSurface,
        labelStyle: TrueStepTypography.caption,
        padding: const EdgeInsets.symmetric(
          horizontal: TrueStepSpacing.sm,
          vertical: TrueStepSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueStepSpacing.radiusPill),
          side: const BorderSide(color: TrueStepColors.glassBorder),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrueStepColors.sentinelGreen;
          }
          return TrueStepColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrueStepColors.sentinelGreen.withValues(alpha: 0.5);
          }
          return TrueStepColors.glassBorder;
        }),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: TrueStepColors.accentBlue,
        inactiveTrackColor: TrueStepColors.glassBorder,
        thumbColor: TrueStepColors.accentBlue,
        overlayColor: TrueStepColors.accentBlue.withValues(alpha: 0.2),
      ),
    );
  }
}
