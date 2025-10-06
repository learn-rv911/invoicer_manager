import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme_constants.dart';
import '../../../utils/formatters.dart';
import '../../../application/client_provider.dart';
import '../../../application/project_provider.dart';

class RecentPaymentsList extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> payments;

  const RecentPaymentsList({super.key, required this.payments});

  @override
  ConsumerState<RecentPaymentsList> createState() =>
      _RecentPaymentsListState();
}

class _RecentPaymentsListState extends ConsumerState<RecentPaymentsList> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.payments.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.elevationLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Row(
              children: [
                Icon(Icons.payments_rounded,
                    size: 24, color: AppTheme.success),
                const SizedBox(width: AppTheme.spacing12),
                Text(
                  'Recent Payments',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                  onPressed: () => context.go('/payments'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.payments.length > 5 ? 5 : widget.payments.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, thickness: 1),
            itemBuilder: (context, index) =>
                _buildPaymentItem(widget.payments[index], index),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment, int index) {
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);

    final clientId = payment['client_id'] as int?;
    final projectId = payment['project_id'] as int?;

    String clientName = 'Unknown';
    if (clientId != null) {
      try {
        final client =
            clientState.clients.firstWhere((c) => c.id == clientId);
        clientName = client.name;
      } catch (e) {
        clientName = 'Client #$clientId';
      }
    }

    String projectName = 'Unknown';
    if (projectId != null) {
      try {
        final project =
            projectState.projects.firstWhere((p) => p.id == projectId);
        projectName = project.name;
      } catch (e) {
        projectName = 'Project #$projectId';
      }
    }

    final method = payment['method']?.toString() ?? 'cash';
    final methodColor = _getPaymentMethodColor(method);
    final methodIcon = _getPaymentMethodIcon(method);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: AppTheme.animationFast,
        color: _hoveredIndex == index
            ? AppTheme.success.withOpacity(0.02)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
            vertical: AppTheme.spacing16,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: methodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(methodIcon, color: methodColor, size: 20),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fmtDate(payment['payment_date']?.toString() ?? ''),
                      style: AppTheme.labelLarge.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$clientName • $projectName',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: methodColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        method.toUpperCase(),
                        style: AppTheme.labelSmall.copyWith(
                          color: methodColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmtMoney((payment['amount'] ?? 0) as num),
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (_hoveredIndex == index) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                          ),
                          tooltip: 'View',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return AppTheme.success;
      case 'cheque':
        return AppTheme.primary;
      case 'bank_transfer':
        return const Color(0xFF8B5CF6);
      case 'upi':
        return AppTheme.warning;
      case 'card':
        return AppTheme.danger;
      case 'other':
        return AppTheme.neutral;
      default:
        return AppTheme.neutral;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'cheque':
        return Icons.account_balance_rounded;
      case 'bank_transfer':
        return Icons.account_balance_wallet_rounded;
      case 'upi':
        return Icons.phone_android_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'other':
        return Icons.payment_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.elevationLow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.payments_rounded,
                size: 64,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'No payments found',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Record your first payment to get started',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

