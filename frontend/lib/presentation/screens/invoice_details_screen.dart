import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/client_provider.dart';
import '../../application/company_provider.dart';
import '../../application/invoice_provider.dart';
import '../../application/project_provider.dart';
import '../../data/dtos/invoice_create.dart';
import '../../data/dtos/invoice_update.dart';
import '../../data/models/client.dart';
import '../../data/models/company.dart';
import '../../data/models/invoice.dart';
import '../../data/models/project.dart';
import 'invoices_screen.dart';

class InvoiceDetailsScreen extends ConsumerStatefulWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoice,
  });

  @override
  ConsumerState<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends ConsumerState<InvoiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectProvider.notifier).loadProjects();
      ref.read(companyProvider.notifier).loadCompanies();
      ref.read(clientProvider.notifier).loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final project = _getProjectForInvoice(invoice);
    final client = project != null ? _getClientForProject(project) : null;
    final company = project != null ? _getCompanyForProject(project) : null;
    final statusColor = _getInvoiceStatusColor(invoice.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditInvoiceDialog(context, invoice);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, invoice);
                  break;
                case 'mark_paid':
                  _markAsPaid(invoice);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit Invoice'),
                  ],
                ),
              ),
              if (!invoice.isPaid)
                const PopupMenuItem(
                  value: 'mark_paid',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Mark as Paid', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Delete Invoice', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Header Card
            _buildInvoiceHeaderCard(invoice, statusColor),
            const SizedBox(height: 16),

            // Billing Information
            _buildBillingInfoCard(project, client, company),
            const SizedBox(height: 16),

            // Invoice Details
            _buildInvoiceDetailsCard(invoice),
            const SizedBox(height: 16),

            // Amount Breakdown
            _buildAmountBreakdownCard(invoice),
            const SizedBox(height: 16),

            // Payment Status
            _buildPaymentStatusCard(invoice, statusColor),
            const SizedBox(height: 16),

            // Notes
            if (invoice.notes != null && invoice.notes!.isNotEmpty)
              _buildNotesCard(invoice),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeaderCard(Invoice invoice, Color statusColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: statusColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusDisplayName(invoice.status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (invoice.description != null && invoice.description!.isNotEmpty) ...[
              Text(
                invoice.description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Invoice ID: ${invoice.id}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingInfoCard(Project? project, Client? client, Company? company) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Billing Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.business,
              label: 'Company',
              value: company?.name ?? 'Unknown',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person,
              label: 'Client',
              value: client?.name ?? 'Unknown',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.work,
              label: 'Project',
              value: project?.name ?? 'Unknown',
            ),
            if (client?.address != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Client Address',
                value: client!.address!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailsCard(Invoice invoice) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Created Date',
              value: _formatDate(invoice.createdAt),
            ),
            if (invoice.dueDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.event,
                label: 'Due Date',
                value: _formatDate(invoice.dueDate!),
                valueColor: invoice.isOverdue ? Colors.red : null,
              ),
            ],
            if (invoice.paidDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.check_circle,
                label: 'Paid Date',
                value: _formatDate(invoice.paidDate!),
                valueColor: Colors.green,
              ),
            ],
            if (invoice.isOverdue) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This invoice is overdue',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBreakdownCard(Invoice invoice) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amount Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow(
              label: 'Subtotal',
              amount: invoice.amount,
              isSubtotal: true,
            ),
            if (invoice.taxAmount != null && invoice.taxAmount! > 0) ...[
              const SizedBox(height: 8),
              _buildAmountRow(
                label: 'Tax',
                amount: invoice.taxAmount!,
                isSubtotal: true,
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildAmountRow(
              label: 'Total',
              amount: invoice.totalAmount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard(Invoice invoice, Color statusColor) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusDisplayName(invoice.status),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusDescription(invoice.status),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!invoice.isPaid && !invoice.isCancelled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markAsPaid(invoice),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Paid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Invoice invoice) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                invoice.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow({
    required String label,
    required double amount,
    bool isSubtotal = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Project? _getProjectForInvoice(Invoice invoice) {
    final projectState = ref.read(projectProvider);
    try {
      return projectState.projects.firstWhere(
        (project) => project.id == invoice.projectId,
      );
    } catch (e) {
      return null;
    }
  }

  Client? _getClientForProject(Project project) {
    final clientState = ref.read(clientProvider);
    try {
      return clientState.clients.firstWhere(
        (client) => client.id == project.clientId,
      );
    } catch (e) {
      return null;
    }
  }

  Company? _getCompanyForProject(Project project) {
    final companyState = ref.read(companyProvider);
    try {
      return companyState.companies.firstWhere(
        (company) => company.id == project.companyId,
      );
    } catch (e) {
      return null;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'sent':
        return 'Sent';
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Invoice has been created but not sent yet';
      case 'sent':
        return 'Invoice has been sent to the client';
      case 'paid':
        return 'Payment has been received';
      case 'overdue':
        return 'Payment is past due date';
      case 'cancelled':
        return 'Invoice has been cancelled';
      default:
        return '';
    }
  }

  Color _getInvoiceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'draft':
        return Colors.grey;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  void _markAsPaid(Invoice invoice) async {
    final invoiceUpdate = InvoiceUpdate(
      status: 'paid',
      paidDate: DateTime.now(),
    );
    
    final result = await ref
        .read(invoiceProvider.notifier)
        .updateInvoice(invoice.id, invoiceUpdate);
    
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice marked as paid")),
      );
      // Refresh the screen by popping and pushing again
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InvoiceDetailsScreen(invoice: result),
        ),
      );
    }
  }

  void _showEditInvoiceDialog(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => InvoiceFormDialog(
        invoice: invoice,
        onSave: (invoiceCreate) async {
          final invoiceUpdate = InvoiceUpdate(
            invoiceNumber: invoiceCreate.invoiceNumber,
            projectId: invoiceCreate.projectId,
            amount: invoiceCreate.amount,
            taxAmount: invoiceCreate.taxAmount,
            totalAmount: invoiceCreate.totalAmount,
            status: invoiceCreate.status,
            dueDate: invoiceCreate.dueDate,
            description: invoiceCreate.description,
            notes: invoiceCreate.notes,
          );
          final result = await ref
              .read(invoiceProvider.notifier)
              .updateInvoice(invoice.id, invoiceUpdate);
          if (result != null && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invoice updated successfully")),
            );
            // Refresh the screen
            setState(() {});
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Invoice"),
        content: Text("Are you sure you want to delete invoice '${invoice.invoiceNumber}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(invoiceProvider.notifier)
                  .deleteInvoice(invoice.id);
              if (success && mounted) {
                Navigator.of(context).pop(); // Go back to invoices list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invoice deleted successfully")),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

