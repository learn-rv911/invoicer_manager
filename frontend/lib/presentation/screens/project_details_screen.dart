import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/client_provider.dart';
import '../../application/company_provider.dart';
import '../../application/invoice_provider.dart';
import '../../application/project_provider.dart';
import '../../data/dtos/project_create.dart';
import '../../data/dtos/project_update.dart';
import '../../data/models/client.dart';
import '../../data/models/company.dart';
import '../../data/models/invoice.dart';
import '../../data/models/project.dart';
import 'projects_screen.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyProvider.notifier).loadCompanies();
      ref.read(clientProvider.notifier).loadClients();
      ref.read(invoiceProvider.notifier).loadInvoicesByProject(widget.project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final client = _getClientForProject(project);
    final company = _getCompanyForProject(project);
    final statusColor = _getStatusColor(project.status ?? "Unknown");
    final invoiceState = ref.watch(invoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditProjectDialog(context, project);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, project);
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
                    Text('Edit Project'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Delete Project', style: TextStyle(color: Colors.red)),
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
            // Project Header Card
            _buildProjectHeaderCard(project, statusColor),
            const SizedBox(height: 16),

            // Project Information Card
            _buildProjectInfoCard(project, client, company),
            const SizedBox(height: 16),

            // Status and Timeline Card
            _buildStatusTimelineCard(project, statusColor),
            const SizedBox(height: 16),

            // Notes Card
            if (project.notes != null && project.notes!.isNotEmpty)
              _buildNotesCard(project),
            if (project.notes != null && project.notes!.isNotEmpty)
              const SizedBox(height: 16),

            // Financial Summary Card
            _buildFinancialSummaryCard(invoiceState.invoices),
            const SizedBox(height: 16),

            // Recent Activity Card (Placeholder)
            _buildRecentActivityCard(),
            const SizedBox(height: 16),

            // Invoices Section
            _buildInvoicesSection(invoiceState),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeaderCard(Project project, Color statusColor) {
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
                // Project Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      project.name.isNotEmpty ? project.name[0].toUpperCase() : 'P',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
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
                          _getStatusDisplayName(project.status ?? "Unknown"),
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
            Text(
              'Project ID: ${project.id}',
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

  Widget _buildProjectInfoCard(Project project, Client? client, Company? company) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Information',
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
              value: company?.name ?? 'Unknown Company',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person,
              label: 'Client',
              value: client?.name ?? 'Unknown Client',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Address',
              value: project.address ?? 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Created',
              value: project.createdAt != null
                  ? _formatDate(project.createdAt!)
                  : 'Unknown',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimelineCard(Project project, Color statusColor) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Timeline',
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
                        _getStatusDisplayName(project.status ?? "Unknown"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Status',
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _getStatusProgress(project.status ?? "Unknown"),
                child: Container(
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_getStatusProgress(project.status ?? "Unknown") * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Project project) {
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
                project.notes!,
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

  Widget _buildFinancialSummaryCard(List<Invoice> invoices) {
    final totalInvoiced = invoices.fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
    final totalPaid = invoices
        .where((invoice) => invoice.isPaid)
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
    final totalOutstanding = totalInvoiced - totalPaid;
    final totalOverdue = invoices
        .where((invoice) => invoice.isOverdue)
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialItem(
                    label: 'Total Invoiced',
                    amount: '\$${totalInvoiced.toStringAsFixed(2)}',
                    color: Colors.black87,
                    icon: Icons.receipt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFinancialItem(
                    label: 'Amount Received',
                    amount: '\$${totalPaid.toStringAsFixed(2)}',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialItem(
                    label: 'Outstanding',
                    amount: '\$${totalOutstanding.toStringAsFixed(2)}',
                    color: Colors.red,
                    icon: Icons.pending,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFinancialItem(
                    label: 'Overdue',
                    amount: '\$${totalOverdue.toStringAsFixed(2)}',
                    color: Colors.orange,
                    icon: Icons.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.add,
              title: 'Project Created',
              subtitle: 'Project was created',
              time: widget.project.createdAt != null
                  ? _formatDateTime(widget.project.createdAt!)
                  : 'Unknown',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.edit,
              title: 'Project Updated',
              subtitle: 'Project details were modified',
              time: 'Recently',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.info,
              title: 'Status Changed',
              subtitle: 'Status updated to ${_getStatusDisplayName(widget.project.status ?? "Unknown")}',
              time: 'Recently',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesSection(InvoiceState invoiceState) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to create invoice screen
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Invoice'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (invoiceState.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (invoiceState.error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading invoices',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ref.read(invoiceProvider.notifier).loadInvoicesByProject(widget.project.id);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (invoiceState.invoices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No invoices found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first invoice for this project',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoiceState.invoices.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final invoice = invoiceState.invoices[index];
                  return _buildInvoiceCard(invoice);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final statusColor = _getInvoiceStatusColor(invoice.status);
    final isOverdue = invoice.isOverdue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (invoice.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        invoice.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getInvoiceStatusDisplayName(invoice.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInvoiceInfoItem(
                  label: 'Amount',
                  value: '\$${invoice.totalAmount.toStringAsFixed(2)}',
                  color: Colors.black87,
                ),
              ),
              if (invoice.dueDate != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInvoiceInfoItem(
                    label: 'Due Date',
                    value: _formatDate(invoice.dueDate!),
                    color: isOverdue ? Colors.red : Colors.grey[600]!,
                  ),
                ),
              ],
            ],
          ),
          if (invoice.paidDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Paid on ${_formatDate(invoice.paidDate!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                invoice.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceInfoItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
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

  String _getInvoiceStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'sent':
        return 'Sent';
      case 'draft':
        return 'Draft';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
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

  Widget _buildFinancialItem({
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
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
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'on_hold':
        return 'On Hold';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'in progress':
      case 'active':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'on_hold':
      case 'on hold':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _getStatusProgress(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0.1;
      case 'in_progress':
      case 'in progress':
        return 0.5;
      case 'on_hold':
      case 'on hold':
        return 0.3;
      case 'completed':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.0;
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
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        project: project,
        onSave: (projectCreate) async {
          try {
            final projectUpdate = ProjectUpdate(
              name: projectCreate.name,
              address: projectCreate.address,
              status: projectCreate.status,
              notes: projectCreate.notes,
            );
            final result = await ref
                .read(projectProvider.notifier)
                .updateProject(project.id, projectUpdate);
            if (result != null && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Project updated successfully")),
              );
              // Refresh the current screen
              setState(() {});
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to update project")),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error updating project: $e")),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Project"),
        content: Text("Are you sure you want to delete '${project.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(projectProvider.notifier)
                  .deleteProject(project.id);
              if (success && mounted) {
                Navigator.of(context).pop(); // Go back to projects list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Project deleted successfully")),
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
