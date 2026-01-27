/// Masagi App Theme
/// Based on Gold/Orange (#F49D2A) + Deep Navy (#334257) branding
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/colors.dart';
import '../core/constants/app_constants.dart';

class MasagiTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: MasagiColors.primaryGold,
        onPrimary: MasagiColors.textOnGold,
        primaryContainer: MasagiColors.gold100,
        onPrimaryContainer: MasagiColors.gold900,
        secondary: MasagiColors.primaryNavy,
        onSecondary: MasagiColors.textOnPrimary,
        secondaryContainer: MasagiColors.navy100,
        onSecondaryContainer: MasagiColors.navy900,
        surface: MasagiColors.surface,
        onSurface: MasagiColors.textPrimary,
        surfaceContainerHighest: MasagiColors.surfaceVariant,
        error: MasagiColors.error,
        onError: Colors.white,
        errorContainer: MasagiColors.errorLight,
      ),

      // Scaffold
      scaffoldBackgroundColor: MasagiColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: MasagiColors.surface,
        foregroundColor: MasagiColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MasagiColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: MasagiColors.textPrimary, size: 24),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MasagiColors.surface,
        selectedItemColor: MasagiColors.primaryGold,
        unselectedItemColor: MasagiColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MasagiColors.primaryGold,
          foregroundColor: MasagiColors.textOnGold,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MasagiColors.primaryGold,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: MasagiColors.primaryGold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MasagiColors.primaryGold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MasagiColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(
            color: MasagiColors.primaryGold,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: MasagiColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: MasagiColors.error, width: 2),
        ),
        hintStyle: const TextStyle(
          color: MasagiColors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: MasagiColors.textSecondary,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(color: MasagiColors.error, fontSize: 12),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: MasagiColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          side: const BorderSide(color: MasagiColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: MasagiColors.surfaceVariant,
        selectedColor: MasagiColors.gold100,
        disabledColor: MasagiColors.divider,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: MasagiColors.textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          color: MasagiColors.primaryGold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: MasagiColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MasagiColors.primaryGold,
        foregroundColor: MasagiColors.textOnGold,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MasagiColors.navy700,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: MasagiColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MasagiColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: MasagiColors.textSecondary,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MasagiColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: MasagiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXLarge),
          ),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MasagiColors.primaryGold,
        linearTrackColor: MasagiColors.gold100,
        circularTrackColor: MasagiColors.gold100,
      ),

      // Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: MasagiColors.primaryGold,
        unselectedLabelColor: MasagiColors.textTertiary,
        indicatorColor: MasagiColors.primaryGold,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: MasagiColors.textSecondary,
        size: 24,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: MasagiColors.textPrimary,
        ),
        subtitleTextStyle: const TextStyle(
          fontSize: 14,
          color: MasagiColors.textSecondary,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: MasagiColors.textPrimary,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: MasagiColors.textPrimary,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: MasagiColors.textPrimary,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: MasagiColors.textPrimary,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: MasagiColors.textPrimary,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MasagiColors.textPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MasagiColors.textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MasagiColors.textPrimary,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: MasagiColors.textPrimary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: MasagiColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: MasagiColors.textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: MasagiColors.textSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MasagiColors.textPrimary,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MasagiColors.textSecondary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: MasagiColors.textTertiary,
          height: 1.4,
        ),
      ),
    );
  }
}
