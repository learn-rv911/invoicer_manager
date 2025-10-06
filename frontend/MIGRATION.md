# Design System Migration Guide

## Overview

The Invoice Manager app now uses a centralized Design System that provides a single source of truth for all UI tokens, themes, and reusable components. This guide explains how to use the design system and migrate existing code.

---

## Getting Started

### Import the Design System

Import the design system barrel export in your files:

```dart
import 'package:invoice/core/ui/design_system.dart';
```

This gives you access to:
- Color tokens (`AppColors`, `AppColorsLight`, `AppColorsDark`)
- Text tokens (`AppTextTokens`)
- Spacing tokens (`AppSpacing`)
- Theme extensions (`BadgeTheme`, `ChartTheme`)
- Reusable components (`AppButton`, `AppBadge`, `AppCard`, etc.)

---

## Color Usage

### ❌ DON'T: Use inline colors

```dart
// BAD - Don't do this
Container(
  color: Color(0xFF2563EB),
  child: Text(
    'Hello',
    style: TextStyle(color: Color(0xFF64748B)),
  ),
)
```

### ✅ DO: Use context.colors extension

```dart
// GOOD - Use design system colors
Container(
  color: context.colors.primary,
  child: Text(
    'Hello',
    style: AppTextTokens.bodyMedium.copyWith(
      color: context.colors.textSecondary,
    ),
  ),
)
```

### Common Color Tokens

```dart
// Brand Colors
context.colors.primary         // #2563EB
context.colors.success         // #16A34A
context.colors.warning         // #F59E0B
context.colors.danger          // #DC2626

// Text Colors
context.colors.textPrimary     // Main text
context.colors.textSecondary   // Secondary text
context.colors.textTertiary    // Tertiary text

// Backgrounds & Surfaces
context.colors.background      // Page background
context.colors.surface         // Card/panel backgrounds
context.colors.surfaceHover    // Hover states

// Borders & Dividers
context.colors.border          // Standard borders
context.colors.divider         // Divider lines
```

---

## Typography

### ❌ DON'T: Use inline TextStyle

```dart
// BAD - Don't do this
Text(
  'Dashboard',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  ),
)
```

### ✅ DO: Use AppTextTokens

```dart
// GOOD - Use design system typography
Text(
  'Dashboard',
  style: AppTextTokens.headlineLarge.copyWith(
    color: context.colors.textPrimary,
  ),
)
```

### Typography Tokens

```dart
// Headlines
AppTextTokens.headlineLarge    // 28px, bold - Page titles
AppTextTokens.headlineMedium   // 20px, semibold - Section headers
AppTextTokens.title            // 16px, semibold - Component titles

// Body Text
AppTextTokens.bodyLarge        // 16px - Large body text
AppTextTokens.bodyMedium       // 14px - Regular body text
AppTextTokens.bodySmall        // 12px - Small body text

// Labels
AppTextTokens.labelLarge       // 14px, medium - Buttons, form labels
AppTextTokens.labelMedium      // 13px, medium - Secondary labels
AppTextTokens.labelSmall       // 11px, medium - Captions, badges

// Numbers (with tabular figures for alignment)
AppTextTokens.numberLarge      // 28px, bold - KPI values
AppTextTokens.numberMedium     // 16px, semibold - Table numbers
AppTextTokens.numberSmall      // 14px, medium - Small numbers
```

---

## Spacing & Layout

### ❌ DON'T: Use magic numbers

```dart
// BAD - Don't do this
Padding(
  padding: EdgeInsets.all(16),
  child: Container(
    margin: EdgeInsets.symmetric(horizontal: 24),
    ...
  ),
)
```

### ✅ DO: Use AppSpacing tokens

```dart
// GOOD - Use design system spacing
Padding(
  padding: const EdgeInsets.all(AppSpacing.space16),
  child: Container(
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
    ...
  ),
)
```

### Spacing Scale

```dart
AppSpacing.space4    // 4px
AppSpacing.space8    // 8px
AppSpacing.space12   // 12px
AppSpacing.space16   // 16px (default padding)
AppSpacing.space20   // 20px (card padding)
AppSpacing.space24   // 24px
AppSpacing.space32   // 32px
AppSpacing.space40   // 40px
AppSpacing.space48   // 48px
AppSpacing.space64   // 64px
```

### Border Radius

```dart
AppSpacing.radiusSmall     // 8px
AppSpacing.radiusMedium    // 12px (default)
AppSpacing.radiusLarge     // 16px
AppSpacing.radiusXLarge    // 20px
AppSpacing.radiusFull      // 9999px (pill shape)
```

---

## Reusable Components

### Buttons

```dart
// Primary button
AppButton.primary(
  label: 'Save',
  onPressed: () {},
  leadingIcon: Icon(Icons.save_rounded),
)

// Secondary button
AppButton.secondary(
  label: 'Cancel',
  onPressed: () {},
)

// Ghost button (text button)
AppButton.ghost(
  label: 'Learn More',
  onPressed: () {},
)

// Destructive button
AppButton.destructive(
  label: 'Delete',
  onPressed: () {},
)

// With loading state
AppButton.primary(
  label: 'Saving...',
  onPressed: null,
  isLoading: true,
)
```

### Status Badges

```dart
// From status string
AppBadge.fromStatus('paid')  // Auto-colors based on status

// Predefined badges
AppBadge.paid()
AppBadge.sent()
AppBadge.draft()
AppBadge.overdue()
AppBadge.cancelled()

// Custom badge
AppBadge(
  label: 'NEW',
  backgroundColor: context.colors.primary.withOpacity(0.1),
  foregroundColor: context.colors.primary,
)
```

### Cards

```dart
// Elevated card (with shadow)
AppCard.elevated(
  child: Text('Content'),
)

// Flat card (no shadow)
AppCard.flat(
  child: Text('Content'),
)

// Outlined card
AppCard.outlined(
  child: Text('Content'),
)

// With custom padding
AppCard(
  padding: EdgeInsets.all(AppSpacing.space16),
  child: Text('Content'),
)

// Clickable card
AppCard.elevated(
  onTap: () => print('Tapped'),
  child: Text('Content'),
)
```

### KPI Stat Tiles

```dart
AppStatTile(
  label: 'Total Revenue',
  value: '₹1,23,456',
  icon: Icons.payments_rounded,
  color: context.colors.success,
  subtitle: '42 invoices',
  delta: '+12%',
  isPositiveDelta: true,
)
```

### Section Headers

```dart
AppSectionHeader(
  title: 'Recent Invoices',
  subtitle: 'Last 30 days',
  icon: Icons.receipt_long_rounded,
  trailing: TextButton(
    onPressed: () {},
    child: Text('View All'),
  ),
)
```

---

## Theme Extensions

### Badge Theme (for status badges)

```dart
// Access badge colors
final badgeTheme = context.badgeTheme;

Container(
  color: badgeTheme.paidBackground,
  child: Text(
    'PAID',
    style: TextStyle(color: badgeTheme.paidForeground),
  ),
)
```

### Chart Theme (for dashboard charts)

```dart
// Access chart colors
final chartTheme = context.chartTheme;

PieChart(
  PieChartData(
    sections: [
      PieChartSectionData(
        color: chartTheme.seriesColors[0],
        value: 100,
      ),
    ],
  ),
)
```

---

## Common Patterns

### Filter Bar

```dart
Row(
  children: [
    AppButton.secondary(
      label: 'Last 30 days',
      leadingIcon: Icon(Icons.calendar_today_rounded, size: 16),
      onPressed: () {},
    ),
    SizedBox(width: AppSpacing.space12),
    AppButton.secondary(
      label: 'All Companies',
      leadingIcon: Icon(Icons.business_rounded, size: 16),
      onPressed: () {},
    ),
  ],
)
```

### Data Table

```dart
AppCard(
  child: DataTable(
    columns: [
      DataColumn(label: Text('Invoice #')),
      DataColumn(label: Text('Amount')),
      DataColumn(label: Text('Status')),
    ],
    rows: [
      DataRow(cells: [
        DataCell(Text('INV-001')),
        DataCell(Text('₹1,000')),
        DataCell(AppBadge.fromStatus('paid')),
      ]),
    ],
  ),
)
```

### Form Input

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Invoice Number',
    prefixIcon: Icon(Icons.receipt_rounded),
    helperText: 'Enter a unique identifier',
  ),
)
```

---

## Migration Checklist

When migrating an existing screen:

1. ✅ Import `design_system.dart` at the top
2. ✅ Replace all `Color(0x...)` with `context.colors.xyz`
3. ✅ Replace all inline `TextStyle` with `AppTextTokens.xyz`
4. ✅ Replace all magic number paddings/margins with `AppSpacing.xyz`
5. ✅ Replace custom buttons with `AppButton.xyz`
6. ✅ Replace status chips with `AppBadge.fromStatus()`
7. ✅ Wrap content in `AppCard` instead of `Container` with manual styling
8. ✅ Use `AppSectionHeader` for section titles
9. ✅ Use `AppStatTile` for KPI cards
10. ✅ Remove any references to old `theme_constants.dart`

---

## Do's and Don'ts Summary

### ❌ DON'T

- Use `Color(0x...)` inline
- Use `TextStyle(...)` inline
- Define custom colors/text styles in screens
- Use magic numbers for spacing
- Create custom buttons/badges manually
- Use `Container` with `BoxDecoration` for cards

### ✅ DO

- Use `context.colors.xyz` for all colors
- Use `AppTextTokens.xyz` for all text styles
- Use `AppSpacing.xyz` for all spacing/radii
- Use `AppButton.xyz` for all buttons
- Use `AppBadge.xyz` for status badges
- Use `AppCard.xyz` for containers
- Use design system components (`AppStatTile`, `AppSectionHeader`, etc.)

---

## Adding New Components

If you need a new reusable component:

1. Create it in `frontend/lib/core/ui/widgets/`
2. Use design system tokens (no inline styles)
3. Export it from `design_system.dart`
4. Document usage in this file

Example:

```dart
// frontend/lib/core/ui/widgets/app_alert.dart
import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/text_tokens.dart';
import '../theme/color_tokens.dart';

class AppAlert extends StatelessWidget {
  final String message;
  final AlertType type;

  const AppAlert({
    super.key,
    required this.message,
    this.type = AlertType.info,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(colors),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Text(
        message,
        style: AppTextTokens.bodyMedium.copyWith(
          color: _getForegroundColor(colors),
        ),
      ),
    );
  }
  
  Color _getBackgroundColor(AppColors colors) {
    switch (type) {
      case AlertType.success:
        return colors.success.withOpacity(0.1);
      case AlertType.warning:
        return colors.warning.withOpacity(0.1);
      case AlertType.error:
        return colors.danger.withOpacity(0.1);
      case AlertType.info:
        return colors.primary.withOpacity(0.1);
    }
  }
  
  Color _getForegroundColor(AppColors colors) {
    switch (type) {
      case AlertType.success:
        return colors.success;
      case AlertType.warning:
        return colors.warning;
      case AlertType.error:
        return colors.danger;
      case AlertType.info:
        return colors.primary;
    }
  }
}

enum AlertType { success, warning, error, info }
```

---

## Dark Mode Support

The design system automatically supports dark mode. Colors, text styles, and components adapt based on the system theme preference.

To test dark mode:
1. Run the app
2. Change your system theme preference
3. The app will automatically switch

All design system tokens are theme-aware, so you don't need to do anything special in your screens.

---

## Questions?

If you have questions about using the design system or need help migrating a screen, refer to:
- `frontend/lib/core/ui/theme/` for token definitions
- `frontend/lib/core/ui/widgets/` for component implementations
- Existing refactored screens for examples

---

**Last Updated**: 2025-01-06
**Design System Version**: 1.0.0

