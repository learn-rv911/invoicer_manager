import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme_constants.dart';
import '../../../utils/formatters.dart';
import '../../../application/client_provider.dart';
import '../../../application/project_provider.dart';

class RecentInvoicesList extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> invoices;

  const RecentInvoicesList({super.key, required this.invoices});

  @override
  ConsumerState<RecentInvoicesList> createState() =>
      _RecentInvoicesListState();
}

class _RecentInvoicesListState extends ConsumerState<RecentInvoicesList> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.invoices.isEmpty) {
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
                Icon(Icons.receipt_long_rounded,
                    size: 24, color: AppTheme.primary),
                const SizedBox(width: AppTheme.spacing12),
                Text(
                  'Recent Invoices',
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
                  onPressed: () => context.go('/invoices'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.invoices.length > 5 ? 5 : widget.invoices.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, thickness: 1),
            itemBuilder: (context, index) =>
                _buildInvoiceItem(widget.invoices[index], index),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(Map<String, dynamic> invoice, int index) {
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);

    final clientId = invoice['client_id'] as int?;
    final projectId = invoice['project_id'] as int?;

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

    final status = invoice['status']?.toString() ?? 'draft';
    final statusColor = AppTheme.getStatusColor(status);
    final statusBg = AppTheme.getStatusBackground(status);
    final statusIcon = AppTheme.getStatusIcon(status);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: AppTheme.animationFast,
        color: _hoveredIndex == index
            ? AppTheme.primary.withOpacity(0.02)
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
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          invoice['invoice_number']?.toString() ?? 'N/A',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: AppTheme.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$clientName • $projectName',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmtDate(invoice['issue_date']?.toString() ?? ''),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
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
                    fmtMoney((invoice['total'] ?? 0) as num),
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.textPrimary,
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
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                          ),
                          tooltip: 'Edit',
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
                Icons.receipt_long_rounded,
                size: 64,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'No invoices found',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Create your first invoice to get started',
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

