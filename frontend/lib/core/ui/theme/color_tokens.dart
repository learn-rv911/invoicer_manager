import 'package:flutter/material.dart';

/// Light mode color palette
class AppColorsLight {
  // Brand Colors
  static const primary = Color(0xFF2563EB); // Blue
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1E40AF);

  // Semantic Colors
  static const success = Color(0xFF16A34A); // Green
  static const successLight = Color(0xFF22C55E);
  static const successDark = Color(0xFF15803D);

  static const warning = Color(0xFFF59E0B); // Amber
  static const warningLight = Color(0xFFFBBF24);
  static const warningDark = Color(0xFFD97706);

  static const danger = Color(0xFFDC2626); // Red
  static const dangerLight = Color(0xFFEF4444);
  static const dangerDark = Color(0xFFB91C1C);

  // Gray Scale (Tailwind-inspired)
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);

  // Text Colors
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);

  // Background & Surface
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceHover = Color(0xFFF9FAFB);
  static const surfaceSelected = Color(0xFFF1F5F9);

  // Borders & Dividers
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
  static const divider = Color(0xFFE5E7EB);

  // Overlay & Shadow
  static const overlay = Color(0x1A000000); // 10% black
  static const shadowColor = Color(0x14000000); // 8% black
}

/// Dark mode color palette
class AppColorsDark {
  // Brand Colors (slightly adjusted for dark mode)
  static const primary = Color(0xFF3B82F6); // Lighter blue for dark bg
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF2563EB);

  // Semantic Colors
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFF4ADE80);
  static const successDark = Color(0xFF16A34A);

  static const warning = Color(0xFFFBBF24);
  static const warningLight = Color(0xFFFDE047);
  static const warningDark = Color(0xFFF59E0B);

  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFF87171);
  static const dangerDark = Color(0xFFDC2626);

  // Gray Scale (inverted for dark mode)
  static const gray50 = Color(0xFF111827);
  static const gray100 = Color(0xFF1F2937);
  static const gray200 = Color(0xFF374151);
  static const gray300 = Color(0xFF4B5563);
  static const gray400 = Color(0xFF6B7280);
  static const gray500 = Color(0xFF9CA3AF);
  static const gray600 = Color(0xFFD1D5DB);
  static const gray700 = Color(0xFFE5E7EB);
  static const gray800 = Color(0xFFF3F4F6);
  static const gray900 = Color(0xFFF9FAFB);

  // Text Colors
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFFCBD5E1);
  static const textTertiary = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFF64748B);

  // Background & Surface
  static const background = Color(0xFF0B0F14);
  static const surface = Color(0xFF111827);
  static const surfaceHover = Color(0xFF1F2937);
  static const surfaceSelected = Color(0xFF374151);

  // Borders & Dividers
  static const border = Color(0xFF1F2937);
  static const borderLight = Color(0xFF374151);
  static const divider = Color(0xFF1F2937);

  // Overlay & Shadow
  static const overlay = Color(0x33FFFFFF); // 20% white
  static const shadowColor = Color(0x33000000); // 20% black
}

/// Theme extension for custom colors
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color success;
  final Color successLight;
  final Color successDark;
  final Color warning;
  final Color warningLight;
  final Color warningDark;
  final Color danger;
  final Color dangerLight;
  final Color dangerDark;
  final Color gray50;
  final Color gray100;
  final Color gray200;
  final Color gray300;
  final Color gray400;
  final Color gray500;
  final Color gray600;
  final Color gray700;
  final Color gray800;
  final Color gray900;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color background;
  final Color surface;
  final Color surfaceHover;
  final Color surfaceSelected;
  final Color border;
  final Color borderLight;
  final Color divider;
  final Color overlay;
  final Color shadowColor;

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.success,
    required this.successLight,
    required this.successDark,
    required this.warning,
    required this.warningLight,
    required this.warningDark,
    required this.danger,
    required this.dangerLight,
    required this.dangerDark,
    required this.gray50,
    required this.gray100,
    required this.gray200,
    required this.gray300,
    required this.gray400,
    required this.gray500,
    required this.gray600,
    required this.gray700,
    required this.gray800,
    required this.gray900,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.background,
    required this.surface,
    required this.surfaceHover,
    required this.surfaceSelected,
    required this.border,
    required this.borderLight,
    required this.divider,
    required this.overlay,
    required this.shadowColor,
  });

  static AppColors light() => const AppColors(
        primary: AppColorsLight.primary,
        primaryLight: AppColorsLight.primaryLight,
        primaryDark: AppColorsLight.primaryDark,
        success: AppColorsLight.success,
        successLight: AppColorsLight.successLight,
        successDark: AppColorsLight.successDark,
        warning: AppColorsLight.warning,
        warningLight: AppColorsLight.warningLight,
        warningDark: AppColorsLight.warningDark,
        danger: AppColorsLight.danger,
        dangerLight: AppColorsLight.dangerLight,
        dangerDark: AppColorsLight.dangerDark,
        gray50: AppColorsLight.gray50,
        gray100: AppColorsLight.gray100,
        gray200: AppColorsLight.gray200,
        gray300: AppColorsLight.gray300,
        gray400: AppColorsLight.gray400,
        gray500: AppColorsLight.gray500,
        gray600: AppColorsLight.gray600,
        gray700: AppColorsLight.gray700,
        gray800: AppColorsLight.gray800,
        gray900: AppColorsLight.gray900,
        textPrimary: AppColorsLight.textPrimary,
        textSecondary: AppColorsLight.textSecondary,
        textTertiary: AppColorsLight.textTertiary,
        textDisabled: AppColorsLight.textDisabled,
        background: AppColorsLight.background,
        surface: AppColorsLight.surface,
        surfaceHover: AppColorsLight.surfaceHover,
        surfaceSelected: AppColorsLight.surfaceSelected,
        border: AppColorsLight.border,
        borderLight: AppColorsLight.borderLight,
        divider: AppColorsLight.divider,
        overlay: AppColorsLight.overlay,
        shadowColor: AppColorsLight.shadowColor,
      );

  static AppColors dark() => const AppColors(
        primary: AppColorsDark.primary,
        primaryLight: AppColorsDark.primaryLight,
        primaryDark: AppColorsDark.primaryDark,
        success: AppColorsDark.success,
        successLight: AppColorsDark.successLight,
        successDark: AppColorsDark.successDark,
        warning: AppColorsDark.warning,
        warningLight: AppColorsDark.warningLight,
        warningDark: AppColorsDark.warningDark,
        danger: AppColorsDark.danger,
        dangerLight: AppColorsDark.dangerLight,
        dangerDark: AppColorsDark.dangerDark,
        gray50: AppColorsDark.gray50,
        gray100: AppColorsDark.gray100,
        gray200: AppColorsDark.gray200,
        gray300: AppColorsDark.gray300,
        gray400: AppColorsDark.gray400,
        gray500: AppColorsDark.gray500,
        gray600: AppColorsDark.gray600,
        gray700: AppColorsDark.gray700,
        gray800: AppColorsDark.gray800,
        gray900: AppColorsDark.gray900,
        textPrimary: AppColorsDark.textPrimary,
        textSecondary: AppColorsDark.textSecondary,
        textTertiary: AppColorsDark.textTertiary,
        textDisabled: AppColorsDark.textDisabled,
        background: AppColorsDark.background,
        surface: AppColorsDark.surface,
        surfaceHover: AppColorsDark.surfaceHover,
        surfaceSelected: AppColorsDark.surfaceSelected,
        border: AppColorsDark.border,
        borderLight: AppColorsDark.borderLight,
        divider: AppColorsDark.divider,
        overlay: AppColorsDark.overlay,
        shadowColor: AppColorsDark.shadowColor,
      );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? success,
    Color? successLight,
    Color? successDark,
    Color? warning,
    Color? warningLight,
    Color? warningDark,
    Color? danger,
    Color? dangerLight,
    Color? dangerDark,
    Color? gray50,
    Color? gray100,
    Color? gray200,
    Color? gray300,
    Color? gray400,
    Color? gray500,
    Color? gray600,
    Color? gray700,
    Color? gray800,
    Color? gray900,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? background,
    Color? surface,
    Color? surfaceHover,
    Color? surfaceSelected,
    Color? border,
    Color? borderLight,
    Color? divider,
    Color? overlay,
    Color? shadowColor,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      successDark: successDark ?? this.successDark,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      warningDark: warningDark ?? this.warningDark,
      danger: danger ?? this.danger,
      dangerLight: dangerLight ?? this.dangerLight,
      dangerDark: dangerDark ?? this.dangerDark,
      gray50: gray50 ?? this.gray50,
      gray100: gray100 ?? this.gray100,
      gray200: gray200 ?? this.gray200,
      gray300: gray300 ?? this.gray300,
      gray400: gray400 ?? this.gray400,
      gray500: gray500 ?? this.gray500,
      gray600: gray600 ?? this.gray600,
      gray700: gray700 ?? this.gray700,
      gray800: gray800 ?? this.gray800,
      gray900: gray900 ?? this.gray900,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceSelected: surfaceSelected ?? this.surfaceSelected,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      divider: divider ?? this.divider,
      overlay: overlay ?? this.overlay,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      successDark: Color.lerp(successDark, other.successDark, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      warningDark: Color.lerp(warningDark, other.warningDark, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerLight: Color.lerp(dangerLight, other.dangerLight, t)!,
      dangerDark: Color.lerp(dangerDark, other.dangerDark, t)!,
      gray50: Color.lerp(gray50, other.gray50, t)!,
      gray100: Color.lerp(gray100, other.gray100, t)!,
      gray200: Color.lerp(gray200, other.gray200, t)!,
      gray300: Color.lerp(gray300, other.gray300, t)!,
      gray400: Color.lerp(gray400, other.gray400, t)!,
      gray500: Color.lerp(gray500, other.gray500, t)!,
      gray600: Color.lerp(gray600, other.gray600, t)!,
      gray700: Color.lerp(gray700, other.gray700, t)!,
      gray800: Color.lerp(gray800, other.gray800, t)!,
      gray900: Color.lerp(gray900, other.gray900, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceSelected: Color.lerp(surfaceSelected, other.surfaceSelected, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

/// Convenience extension to access custom colors from BuildContext
extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

