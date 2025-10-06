import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'text_tokens.dart';
import 'spacing.dart';

/// Component theme configurations for light and dark modes
class ComponentThemes {
  /// Input decoration theme
  static InputDecorationTheme inputDecorationTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? colors.gray100 : colors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: BorderSide(color: colors.primary, width: AppSpacing.borderMedium),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: BorderSide(color: colors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: BorderSide(color: colors.danger, width: AppSpacing.borderMedium),
      ),
      labelStyle: AppTextTokens.bodyMedium.copyWith(color: colors.textSecondary),
      hintStyle: AppTextTokens.bodyMedium.copyWith(color: colors.textTertiary),
      errorStyle: AppTextTokens.bodySmall.copyWith(color: colors.danger),
    );
  }

  /// Elevated button theme
  static ElevatedButtonThemeData elevatedButtonTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: AppSpacing.elevation0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space20,
          vertical: AppSpacing.space12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        textStyle: AppTextTokens.labelLarge,
      ),
    );
  }

  /// Outlined button theme
  static OutlinedButtonThemeData outlinedButtonTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space20,
          vertical: AppSpacing.space12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        textStyle: AppTextTokens.labelLarge,
      ),
    );
  }

  /// Text button theme
  static TextButtonThemeData textButtonTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        textStyle: AppTextTokens.labelLarge,
      ),
    );
  }

  /// Card theme
  static CardTheme cardTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return CardTheme(
      color: colors.surface,
      elevation: AppSpacing.elevation1,
      shadowColor: colors.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      margin: EdgeInsets.zero,
    );
  }

  /// Chip theme
  static ChipThemeData chipTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return ChipThemeData(
      backgroundColor: colors.gray100,
      deleteIconColor: colors.textSecondary,
      disabledColor: colors.gray100.withOpacity(0.5),
      selectedColor: colors.primary.withOpacity(0.1),
      secondarySelectedColor: colors.primary.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
      labelStyle: AppTextTokens.labelMedium.copyWith(color: colors.textPrimary),
      secondaryLabelStyle: AppTextTokens.labelMedium.copyWith(color: colors.primary),
      brightness: isDark ? Brightness.dark : Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
    );
  }

  /// Divider theme
  static DividerThemeData dividerTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return DividerThemeData(
      color: colors.divider,
      thickness: AppSpacing.borderThin,
      space: AppSpacing.borderThin,
    );
  }

  /// Tooltip theme
  static TooltipThemeData tooltipTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: isDark ? colors.gray900 : colors.gray800,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      textStyle: AppTextTokens.bodySmall.copyWith(
        color: isDark ? colors.gray50 : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
    );
  }

  /// Data table theme
  static DataTableThemeData dataTableTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return DataTableThemeData(
      headingRowColor: MaterialStateProperty.all(colors.gray50),
      dataRowColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return colors.surfaceSelected;
        }
        if (states.contains(MaterialState.hovered)) {
          return colors.surfaceHover;
        }
        return null;
      }),
      headingTextStyle: AppTextTokens.labelMedium.copyWith(
        color: colors.textSecondary,
        fontWeight: AppTextTokens.semiBold,
      ),
      dataTextStyle: AppTextTokens.bodyMedium.copyWith(color: colors.textPrimary),
      dividerThickness: AppSpacing.borderThin,
      horizontalMargin: AppSpacing.space16,
      columnSpacing: AppSpacing.space24,
    );
  }

  /// Dropdown menu theme
  static DropdownMenuThemeData dropdownMenuTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return DropdownMenuThemeData(
      textStyle: AppTextTokens.bodyMedium.copyWith(color: colors.textPrimary),
      inputDecorationTheme: inputDecorationTheme(isDark),
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all(colors.surface),
        elevation: MaterialStateProperty.all(AppSpacing.elevation2),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
      ),
    );
  }

  /// App bar theme
  static AppBarTheme appBarTheme(bool isDark) {
    final colors = isDark ? AppColorsDark : AppColorsLight;
    
    return AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      elevation: AppSpacing.elevation0,
      centerTitle: false,
      titleTextStyle: AppTextTokens.headlineMedium.copyWith(
        color: colors.textPrimary,
      ),
      iconTheme: IconThemeData(color: colors.textPrimary),
    );
  }
}

