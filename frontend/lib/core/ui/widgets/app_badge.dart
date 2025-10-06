import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/text_tokens.dart';
import '../theme/theme_extensions.dart';

enum BadgeStatus { paid, sent, draft, overdue, cancelled }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeStatus? status;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppBadge({
    super.key,
    required this.label,
    this.status,
    this.backgroundColor,
    this.foregroundColor,
  });

  const AppBadge.paid({super.key})
      : label = 'PAID',
        status = BadgeStatus.paid,
        backgroundColor = null,
        foregroundColor = null;

  const AppBadge.sent({super.key})
      : label = 'SENT',
        status = BadgeStatus.sent,
        backgroundColor = null,
        foregroundColor = null;

  const AppBadge.draft({super.key})
      : label = 'DRAFT',
        status = BadgeStatus.draft,
        backgroundColor = null,
        foregroundColor = null;

  const AppBadge.overdue({super.key})
      : label = 'OVERDUE',
        status = BadgeStatus.overdue,
        backgroundColor = null,
        foregroundColor = null;

  const AppBadge.cancelled({super.key})
      : label = 'CANCELLED',
        status = BadgeStatus.cancelled,
        backgroundColor = null,
        foregroundColor = null;

  factory AppBadge.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const AppBadge.paid();
      case 'sent':
        return const AppBadge.sent();
      case 'draft':
        return const AppBadge.draft();
      case 'overdue':
        return const AppBadge.overdue();
      case 'cancelled':
        return const AppBadge.cancelled();
      default:
        return AppBadge(label: status.toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeTheme = context.badgeTheme;
    
    Color bgColor = backgroundColor ?? _getBackgroundColor(badgeTheme);
    Color fgColor = foregroundColor ?? _getForegroundColor(badgeTheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextTokens.labelSmall.copyWith(
          color: fgColor,
          fontWeight: AppTextTokens.semiBold,
        ),
      ),
    );
  }

  Color _getBackgroundColor(BadgeTheme theme) {
    if (status == null) return theme.draftBackground;
    
    switch (status!) {
      case BadgeStatus.paid:
        return theme.paidBackground;
      case BadgeStatus.sent:
        return theme.sentBackground;
      case BadgeStatus.draft:
        return theme.draftBackground;
      case BadgeStatus.overdue:
        return theme.overdueBackground;
      case BadgeStatus.cancelled:
        return theme.cancelledBackground;
    }
  }

  Color _getForegroundColor(BadgeTheme theme) {
    if (status == null) return theme.draftForeground;
    
    switch (status!) {
      case BadgeStatus.paid:
        return theme.paidForeground;
      case BadgeStatus.sent:
        return theme.sentForeground;
      case BadgeStatus.draft:
        return theme.draftForeground;
      case BadgeStatus.overdue:
        return theme.overdueForeground;
      case BadgeStatus.cancelled:
        return theme.cancelledForeground;
    }
  }
}

