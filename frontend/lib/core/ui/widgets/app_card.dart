import 'package:flutter/material.dart';
import '../theme/spacing.dart';

enum AppCardVariant { elevated, flat, outlined }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.onTap,
  });

  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  }) : variant = AppCardVariant.elevated;

  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  }) : variant = AppCardVariant.flat;

  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  }) : variant = AppCardVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.space20);

    Widget cardContent = Padding(
      padding: effectivePadding,
      child: child,
    );

    switch (variant) {
      case AppCardVariant.elevated:
        return Card(
          elevation: AppSpacing.elevation1,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  child: cardContent,
                )
              : cardContent,
        );
      case AppCardVariant.flat:
        return Card(
          elevation: 0,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  child: cardContent,
                )
              : cardContent,
        );
      case AppCardVariant.outlined:
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            side: BorderSide(
              color: theme.colorScheme.outline,
              width: AppSpacing.borderThin,
            ),
          ),
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  child: cardContent,
                )
              : cardContent,
        );
    }
  }
}

