import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/text_tokens.dart';
import '../theme/color_tokens.dart';

class AppStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;
  final String? delta;
  final bool isPositiveDelta;

  const AppStatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
    this.delta,
    this.isPositiveDelta = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = color ?? colors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space8),
                    decoration: BoxDecoration(
                      color: effectiveColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: Icon(icon, color: effectiveColor, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTextTokens.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                if (delta != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space8,
                      vertical: AppSpacing.space4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveDelta
                          ? colors.success.withOpacity(0.1)
                          : colors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositiveDelta
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 14,
                          color: isPositiveDelta ? colors.success : colors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          delta!,
                          style: AppTextTokens.labelSmall.copyWith(
                            color: isPositiveDelta ? colors.success : colors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              value,
              style: AppTextTokens.numberLarge.copyWith(color: effectiveColor),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.space4),
              Text(
                subtitle!,
                style: AppTextTokens.bodySmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

