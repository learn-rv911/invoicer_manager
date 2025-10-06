import 'package:flutter/material.dart';

/// Badge theme extension for status badges
class BadgeTheme extends ThemeExtension<BadgeTheme> {
  final Color paidBackground;
  final Color paidForeground;
  final Color sentBackground;
  final Color sentForeground;
  final Color draftBackground;
  final Color draftForeground;
  final Color overdueBackground;
  final Color overdueForeground;
  final Color cancelledBackground;
  final Color cancelledForeground;

  const BadgeTheme({
    required this.paidBackground,
    required this.paidForeground,
    required this.sentBackground,
    required this.sentForeground,
    required this.draftBackground,
    required this.draftForeground,
    required this.overdueBackground,
    required this.overdueForeground,
    required this.cancelledBackground,
    required this.cancelledForeground,
  });

  static BadgeTheme light() => const BadgeTheme(
        paidBackground: Color(0xFFDCFCE7),
        paidForeground: Color(0xFF16A34A),
        sentBackground: Color(0xFFDCEDFF),
        sentForeground: Color(0xFF2563EB),
        draftBackground: Color(0xFFF1F5F9),
        draftForeground: Color(0xFF64748B),
        overdueBackground: Color(0xFFFEE2E2),
        overdueForeground: Color(0xFFDC2626),
        cancelledBackground: Color(0xFFFEF3C7),
        cancelledForeground: Color(0xFFF59E0B),
      );

  static BadgeTheme dark() => const BadgeTheme(
        paidBackground: Color(0xFF14532D),
        paidForeground: Color(0xFF4ADE80),
        sentBackground: Color(0xFF1E3A8A),
        sentForeground: Color(0xFF60A5FA),
        draftBackground: Color(0xFF1F2937),
        draftForeground: Color(0xFF94A3B8),
        overdueBackground: Color(0xFF7F1D1D),
        overdueForeground: Color(0xFFF87171),
        cancelledBackground: Color(0xFF78350F),
        cancelledForeground: Color(0xFFFDE047),
      );

  @override
  ThemeExtension<BadgeTheme> copyWith({
    Color? paidBackground,
    Color? paidForeground,
    Color? sentBackground,
    Color? sentForeground,
    Color? draftBackground,
    Color? draftForeground,
    Color? overdueBackground,
    Color? overdueForeground,
    Color? cancelledBackground,
    Color? cancelledForeground,
  }) {
    return BadgeTheme(
      paidBackground: paidBackground ?? this.paidBackground,
      paidForeground: paidForeground ?? this.paidForeground,
      sentBackground: sentBackground ?? this.sentBackground,
      sentForeground: sentForeground ?? this.sentForeground,
      draftBackground: draftBackground ?? this.draftBackground,
      draftForeground: draftForeground ?? this.draftForeground,
      overdueBackground: overdueBackground ?? this.overdueBackground,
      overdueForeground: overdueForeground ?? this.overdueForeground,
      cancelledBackground: cancelledBackground ?? this.cancelledBackground,
      cancelledForeground: cancelledForeground ?? this.cancelledForeground,
    );
  }

  @override
  ThemeExtension<BadgeTheme> lerp(ThemeExtension<BadgeTheme>? other, double t) {
    if (other is! BadgeTheme) return this;
    return BadgeTheme(
      paidBackground: Color.lerp(paidBackground, other.paidBackground, t)!,
      paidForeground: Color.lerp(paidForeground, other.paidForeground, t)!,
      sentBackground: Color.lerp(sentBackground, other.sentBackground, t)!,
      sentForeground: Color.lerp(sentForeground, other.sentForeground, t)!,
      draftBackground: Color.lerp(draftBackground, other.draftBackground, t)!,
      draftForeground: Color.lerp(draftForeground, other.draftForeground, t)!,
      overdueBackground: Color.lerp(overdueBackground, other.overdueBackground, t)!,
      overdueForeground: Color.lerp(overdueForeground, other.overdueForeground, t)!,
      cancelledBackground: Color.lerp(cancelledBackground, other.cancelledBackground, t)!,
      cancelledForeground: Color.lerp(cancelledForeground, other.cancelledForeground, t)!,
    );
  }
}

/// Chart theme extension for dashboard charts
class ChartTheme extends ThemeExtension<ChartTheme> {
  final List<Color> seriesColors;
  final Color gridLineColor;
  final Color tooltipBackground;
  final Color tooltipText;
  final Color axisTextColor;

  const ChartTheme({
    required this.seriesColors,
    required this.gridLineColor,
    required this.tooltipBackground,
    required this.tooltipText,
    required this.axisTextColor,
  });

  static ChartTheme light() => const ChartTheme(
        seriesColors: [
          Color(0xFF2563EB), // Primary
          Color(0xFF16A34A), // Success
          Color(0xFFF59E0B), // Warning
          Color(0xFFDC2626), // Danger
          Color(0xFF8B5CF6), // Purple
          Color(0xFF06B6D4), // Cyan
        ],
        gridLineColor: Color(0xFFE5E7EB),
        tooltipBackground: Color(0xFF1F2937),
        tooltipText: Color(0xFFF9FAFB),
        axisTextColor: Color(0xFF64748B),
      );

  static ChartTheme dark() => const ChartTheme(
        seriesColors: [
          Color(0xFF3B82F6), // Primary (lighter)
          Color(0xFF22C55E), // Success (lighter)
          Color(0xFFFBBF24), // Warning (lighter)
          Color(0xFFEF4444), // Danger (lighter)
          Color(0xFFA78BFA), // Purple (lighter)
          Color(0xFF22D3EE), // Cyan (lighter)
        ],
        gridLineColor: Color(0xFF374151),
        tooltipBackground: Color(0xFFF9FAFB),
        tooltipText: Color(0xFF111827),
        axisTextColor: Color(0xFF94A3B8),
      );

  @override
  ThemeExtension<ChartTheme> copyWith({
    List<Color>? seriesColors,
    Color? gridLineColor,
    Color? tooltipBackground,
    Color? tooltipText,
    Color? axisTextColor,
  }) {
    return ChartTheme(
      seriesColors: seriesColors ?? this.seriesColors,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      tooltipBackground: tooltipBackground ?? this.tooltipBackground,
      tooltipText: tooltipText ?? this.tooltipText,
      axisTextColor: axisTextColor ?? this.axisTextColor,
    );
  }

  @override
  ThemeExtension<ChartTheme> lerp(ThemeExtension<ChartTheme>? other, double t) {
    if (other is! ChartTheme) return this;
    return ChartTheme(
      seriesColors: seriesColors, // Don't lerp list
      gridLineColor: Color.lerp(gridLineColor, other.gridLineColor, t)!,
      tooltipBackground: Color.lerp(tooltipBackground, other.tooltipBackground, t)!,
      tooltipText: Color.lerp(tooltipText, other.tooltipText, t)!,
      axisTextColor: Color.lerp(axisTextColor, other.axisTextColor, t)!,
    );
  }
}

/// Convenience extensions
extension BadgeThemeExtension on BuildContext {
  BadgeTheme get badgeTheme => Theme.of(this).extension<BadgeTheme>()!;
}

extension ChartThemeExtension on BuildContext {
  ChartTheme get chartTheme => Theme.of(this).extension<ChartTheme>()!;
}

