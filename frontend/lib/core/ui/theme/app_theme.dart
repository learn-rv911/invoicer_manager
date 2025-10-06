import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'text_tokens.dart';
import 'spacing.dart';
import 'component_themes.dart';
import 'theme_extensions.dart';

/// App theme configuration
class AppTheme {
  /// Light theme
  static ThemeData get lightTheme {
    final colors = AppColorsLight;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.gray600,
        onSecondary: Colors.white,
        error: colors.danger,
        onError: Colors.white,
        background: colors.background,
        onBackground: colors.textPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        outline: colors.border,
        shadow: colors.shadowColor,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: colors.background,
      
      // Typography
      textTheme: _buildTextTheme(false),
      
      // Component themes
      inputDecorationTheme: ComponentThemes.inputDecorationTheme(false),
      elevatedButtonTheme: ComponentThemes.elevatedButtonTheme(false),
      outlinedButtonTheme: ComponentThemes.outlinedButtonTheme(false),
      textButtonTheme: ComponentThemes.textButtonTheme(false),
      cardTheme: ComponentThemes.cardTheme(false),
      chipTheme: ComponentThemes.chipTheme(false),
      dividerTheme: ComponentThemes.dividerTheme(false),
      tooltipTheme: ComponentThemes.tooltipTheme(false),
      dataTableTheme: ComponentThemes.dataTableTheme(false),
      dropdownMenuTheme: ComponentThemes.dropdownMenuTheme(false),
      appBarTheme: ComponentThemes.appBarTheme(false),
      
      // Extensions
      extensions: [
        AppColors.light(),
        BadgeTheme.light(),
        ChartTheme.light(),
      ],
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    final colors = AppColorsDark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        onPrimary: colors.gray900,
        secondary: colors.gray400,
        onSecondary: colors.gray900,
        error: colors.danger,
        onError: colors.gray900,
        background: colors.background,
        onBackground: colors.textPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        outline: colors.border,
        shadow: colors.shadowColor,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: colors.background,
      
      // Typography
      textTheme: _buildTextTheme(true),
      
      // Component themes
      inputDecorationTheme: ComponentThemes.inputDecorationTheme(true),
      elevatedButtonTheme: ComponentThemes.elevatedButtonTheme(true),
      outlinedButtonTheme: ComponentThemes.outlinedButtonTheme(true),
      textButtonTheme: ComponentThemes.textButtonTheme(true),
      cardTheme: ComponentThemes.cardTheme(true),
      chipTheme: ComponentThemes.chipTheme(true),
      dividerTheme: ComponentThemes.dividerTheme(true),
      tooltipTheme: ComponentThemes.tooltipTheme(true),
      dataTableTheme: ComponentThemes.dataTableTheme(true),
      dropdownMenuTheme: ComponentThemes.dropdownMenuTheme(true),
      appBarTheme: ComponentThemes.appBarTheme(true),
      
      // Extensions
      extensions: [
        AppColors.dark(),
        BadgeTheme.dark(),
        ChartTheme.dark(),
      ],
    );
  }

  /// Build text theme for light or dark mode
  static TextTheme _buildTextTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return TextTheme(
      // Display styles
      displayLarge: AppTextTokens.headlineLarge.copyWith(color: colors.textPrimary),
      displayMedium: AppTextTokens.headlineMedium.copyWith(color: colors.textPrimary),
      displaySmall: AppTextTokens.title.copyWith(color: colors.textPrimary),
      
      // Headline styles
      headlineLarge: AppTextTokens.headlineLarge.copyWith(color: colors.textPrimary),
      headlineMedium: AppTextTokens.headlineMedium.copyWith(color: colors.textPrimary),
      headlineSmall: AppTextTokens.title.copyWith(color: colors.textPrimary),
      
      // Title styles
      titleLarge: AppTextTokens.title.copyWith(color: colors.textPrimary),
      titleMedium: AppTextTokens.labelLarge.copyWith(color: colors.textPrimary),
      titleSmall: AppTextTokens.labelMedium.copyWith(color: colors.textSecondary),
      
      // Body styles
      bodyLarge: AppTextTokens.bodyLarge.copyWith(color: colors.textPrimary),
      bodyMedium: AppTextTokens.bodyMedium.copyWith(color: colors.textPrimary),
      bodySmall: AppTextTokens.bodySmall.copyWith(color: colors.textSecondary),
      
      // Label styles
      labelLarge: AppTextTokens.labelLarge.copyWith(color: colors.textPrimary),
      labelMedium: AppTextTokens.labelMedium.copyWith(color: colors.textSecondary),
      labelSmall: AppTextTokens.labelSmall.copyWith(color: colors.textTertiary),
    );
  }
}

