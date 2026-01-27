/// Masagi Color Palette
/// Primary: Gold/Orange (#F49D2A) + Deep Navy (#334257)
library;

import 'package:flutter/material.dart';

abstract class MasagiColors {
  // Primary Colors
  static const Color primaryGold = Color(0xFFF49D2A);
  static const Color primaryNavy = Color(0xFF334257);
  static const Color primary = primaryGold;

  // Secondary Colors
  static const Color secondaryLight = Color(0xFFFFF3E0);
  static const Color secondaryDark = Color(0xFF1A2332);

  // Gold Shades
  static const Color gold50 = Color(0xFFFFF8E1);
  static const Color gold100 = Color(0xFFFFECB3);
  static const Color gold200 = Color(0xFFFFE082);
  static const Color gold300 = Color(0xFFFFD54F);
  static const Color gold400 = Color(0xFFFFCA28);
  static const Color gold500 = Color(0xFFF49D2A);
  static const Color gold600 = Color(0xFFE08A1E);
  static const Color gold700 = Color(0xFFC77A1A);
  static const Color gold800 = Color(0xFFAD6A16);
  static const Color gold900 = Color(0xFF8B5410);

  // Navy Shades
  static const Color navy50 = Color(0xFFE8EAF0);
  static const Color navy100 = Color(0xFFC5CAD6);
  static const Color navy200 = Color(0xFF9FA7BA);
  static const Color navy300 = Color(0xFF78849E);
  static const Color navy400 = Color(0xFF5B6989);
  static const Color navy500 = Color(0xFF334257);
  static const Color navy600 = Color(0xFF2E3C4F);
  static const Color navy700 = Color(0xFF273344);
  static const Color navy800 = Color(0xFF202B39);
  static const Color navy900 = Color(0xFF141D28);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnGold = Color(0xFF1A1A1A);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, gold600],
  );

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy500, navy700],
  );
}
