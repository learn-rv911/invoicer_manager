import 'package:flutter/material.dart';

/// Typography tokens for the app
class AppTextTokens {
  // Font Family
  static const String fontFamily = 'Inter'; // Can be changed to SF Pro, Roboto, etc.

  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Font Sizes
  static const double size10 = 10.0;
  static const double size11 = 11.0;
  static const double size12 = 12.0;
  static const double size13 = 13.0;
  static const double size14 = 14.0;
  static const double size16 = 16.0;
  static const double size18 = 18.0;
  static const double size20 = 20.0;
  static const double size24 = 24.0;
  static const double size28 = 28.0;
  static const double size32 = 32.0;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  /// Headline Large - Main page titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: size28,
    fontWeight: bold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  /// Headline Medium - Section headers
  static const TextStyle headlineMedium = TextStyle(
    fontSize: size20,
    fontWeight: semiBold,
    letterSpacing: letterSpacingTight,
    height: lineHeightNormal,
  );

  /// Title - Card/Component titles
  static const TextStyle title = TextStyle(
    fontSize: size16,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Body Large - Primary body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: size16,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Body Medium - Regular body text
  static const TextStyle bodyMedium = TextStyle(
    fontSize: size14,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Body Small - Small body text
  static const TextStyle bodySmall = TextStyle(
    fontSize: size12,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Label Large - Button text, form labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: size14,
    fontWeight: medium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Label Medium - Secondary labels
  static const TextStyle labelMedium = TextStyle(
    fontSize: size13,
    fontWeight: medium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Label Small - Captions, badges
  static const TextStyle labelSmall = TextStyle(
    fontSize: size11,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  /// Number Large - KPI values
  static const TextStyle numberLarge = TextStyle(
    fontSize: size28,
    fontWeight: bold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
    fontFeatures: [FontFeature.tabularFigures()], // Monospaced numbers
  );

  /// Number Medium - Table numbers
  static const TextStyle numberMedium = TextStyle(
    fontSize: size16,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Number Small - Small numeric values
  static const TextStyle numberSmall = TextStyle(
    fontSize: size14,
    fontWeight: medium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

