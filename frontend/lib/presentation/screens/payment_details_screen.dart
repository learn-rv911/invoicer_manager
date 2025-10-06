import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/client_provider.dart';
import '../../application/invoice_provider.dart';
import '../../application/payment_provider.dart';
import '../../application/project_provider.dart';
import '../../data/dtos/payment_create.dart';
import '../../data/dtos/payment_update.dart';
import '../../data/models/client.dart';
import '../../data/models/invoice.dart';
import '../../data/models/payment.dart';
import '../../data/models/project.dart';
import 'payments_screen.dart';

class PaymentDetailsScreen extends ConsumerStatefulWidget {
  final Payment payment;

  const PaymentDetailsScreen({
    super.key,
    required this.payment,
  });

  @override
  ConsumerState<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends ConsumerState<PaymentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invoiceProvider.notifier).loadInvoices();
      ref.read(projectProvider.notifier).loadProjects();
      ref.read(clientProvider.notifier).loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final invoice = _getInvoiceForPayment(payment);
    final project = invoice != null ? _getProjectForInvoice(invoice) : null;
    final client = project != null ? _getClientForProject(project) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Details"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditPaymentDialog(context, payment);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, payment);
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
                    Text('Edit Payment'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Delete Payment', style: TextStyle(color: Colors.red)),
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
            // Payment Header Card
            _buildPaymentHeaderCard(payment),
            const SizedBox(height: 16),

            // Invoice Information
            _buildInvoiceInfoCard(invoice, client),
            const SizedBox(height: 16),

            // Payment Details
            _buildPaymentDetailsCard(payment),
            const SizedBox(height: 16),

            // Notes
            if (payment.notes != null && payment.notes!.isNotEmpty)
              _buildNotesCard(payment),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHeaderCard(Payment payment) {
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
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Payment Received",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${payment.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    payment.paymentMethodDisplayName,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment ID: ${payment.id}',
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

  Widget _buildInvoiceInfoCard(Invoice? invoice, Client? client) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.receipt_long,
              label: 'Invoice Number',
              value: invoice?.invoiceNumber ?? 'Unknown',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person,
              label: 'Client',
              value: client?.name ?? 'Unknown',
            ),
            if (invoice != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.currency_rupee,
                label: 'Invoice Total',
                value: "₹${invoice.totalAmount.toStringAsFixed(2)}",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard(Payment payment) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (payment.paymentNumber != null && payment.paymentNumber!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.numbers,
                label: 'Payment Number',
                value: payment.paymentNumber!,
              ),
              const SizedBox(height: 12),
            ],
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Payment Date',
              value: _formatDate(payment.paymentDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.payment,
              label: 'Payment Method',
              value: payment.paymentMethodDisplayName,
            ),
            if (payment.referenceNumber != null && payment.referenceNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.confirmation_number,
                label: 'Transaction Number',
                value: payment.referenceNumber!,
              ),
            ],
            if (payment.bankName != null && payment.bankName!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.account_balance,
                label: 'Bank Name',
                value: payment.bankName!,
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Created At',
              value: _formatDateTime(payment.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Payment payment) {
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
                payment.notes!,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Invoice? _getInvoiceForPayment(Payment payment) {
    final invoiceState = ref.read(invoiceProvider);
    try {
      return invoiceState.invoices.firstWhere(
        (invoice) => invoice.id == payment.invoiceId,
      );
    } catch (e) {
      return null;
    }
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  String _formatDateTime(DateTime date) {
    return "${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _showEditPaymentDialog(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => PaymentFormDialog(
        payment: payment,
        onSave: (paymentCreate) async {
          final paymentUpdate = PaymentUpdate(
            invoiceId: paymentCreate.invoiceId,
            amount: paymentCreate.amount,
            paymentDate: paymentCreate.paymentDate,
            paymentMethod: paymentCreate.paymentMethod,
            referenceNumber: paymentCreate.referenceNumber,
            notes: paymentCreate.notes,
          );
          final result = await ref
              .read(paymentProvider.notifier)
              .updatePayment(payment.id, paymentUpdate);
          if (result != null && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment updated successfully")),
            );
            // Refresh the screen
            setState(() {});
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Payment"),
        content: const Text("Are you sure you want to delete this payment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(paymentProvider.notifier)
                  .deletePayment(payment.id);
              if (success && mounted) {
                Navigator.of(context).pop(); // Go back to payments list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment deleted successfully")),
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

