import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/client_provider.dart';
import '../../application/company_provider.dart';
import '../../application/invoice_provider.dart';
import '../../application/project_provider.dart';
import '../../data/dtos/client_update.dart';
import '../../data/dtos/project_create.dart';
import '../../data/models/client.dart';
import '../../data/models/company.dart';
import '../../data/models/invoice.dart';
import '../../data/models/project.dart';
import 'clients_screen.dart';
import 'project_details_screen.dart';

class ClientDetailsScreen extends ConsumerStatefulWidget {
  final Client client;

  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  @override
  ConsumerState<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends ConsumerState<ClientDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyProvider.notifier).loadCompanies();
      ref.read(projectProvider.notifier).loadProjects();
      ref.read(invoiceProvider.notifier).loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    final company = _getCompanyForClient(client);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Details"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditClientDialog(context, client);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, client);
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
                    Text('Edit Client'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Delete Client', style: TextStyle(color: Colors.red)),
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
            // Client Header Card
            _buildClientHeaderCard(client, company),
            const SizedBox(height: 16),

            // Client Information Card
            _buildClientInformationCard(client, company),
            const SizedBox(height: 16),

            // Projects Section
            _buildProjectsSection(),
            const SizedBox(height: 16),

            // Invoices Section
            _buildInvoicesSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("New Project"),
      ),
    );
  }

  Widget _buildClientHeaderCard(Client client, Company? company) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Client Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  client.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Client Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (company != null)
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          company.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.folder, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "${_getProjectCount()} Projects",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInformationCard(Client client, Company? company) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.business,
              label: 'Company',
              value: company?.name ?? 'Unknown',
            ),
            if (client.address != null && client.address!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Address',
                value: client.address!,
              ),
            ],
            if (client.gstPercent != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.percent,
                label: 'GST Percentage',
                value: '${client.gstPercent}%',
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Created At',
              value: _formatDateTime(client.createdAt ?? DateTime.now()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    final projectState = ref.watch(projectProvider);
    final clientProjects = projectState.projects
        .where((project) => project.clientId == widget.client.id)
        .toList();

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
                  'Projects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showCreateProjectDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Project'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (clientProjects.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No projects yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showCreateProjectDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Project'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...clientProjects.map((project) => _buildProjectCard(project)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(project: project),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status ?? 'pending').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.folder,
                  color: _getStatusColor(project.status ?? 'pending'),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusDisplayName(project.status ?? 'pending'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoicesSection() {
    final invoiceState = ref.watch(invoiceProvider);
    final projectState = ref.watch(projectProvider);
    
    // Get all projects for this client
    final clientProjectIds = projectState.projects
        .where((project) => project.clientId == widget.client.id)
        .map((project) => project.id)
        .toSet();
    
    // Get all invoices for those projects
    final clientInvoices = invoiceState.invoices
        .where((invoice) => clientProjectIds.contains(invoice.projectId))
        .toList();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Invoices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (clientInvoices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No invoices yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...clientInvoices.take(5).map((invoice) => _buildInvoiceCard(invoice)),
            if (clientInvoices.length > 5)
              TextButton(
                onPressed: () {
                  // Navigate to invoices screen with filter
                },
                child: const Text('View All Invoices'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final project = _getProjectForInvoice(invoice);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getInvoiceStatusColor(invoice.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt,
                color: _getInvoiceStatusColor(invoice.status),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project?.name ?? 'Unknown Project',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${invoice.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getInvoiceStatusColor(invoice.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getInvoiceStatusDisplayName(invoice.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getInvoiceStatusColor(invoice.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Company? _getCompanyForClient(Client client) {
    final companyState = ref.read(companyProvider);
    if (client.companyId == null) return null;
    try {
      return companyState.companies.firstWhere(
        (company) => company.id == client.companyId,
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

  int _getProjectCount() {
    final projectState = ref.read(projectProvider);
    return projectState.projects
        .where((project) => project.clientId == widget.client.id)
        .length;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'in_progress':
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'on_hold':
      case 'on hold':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
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

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'on_hold':
        return 'On Hold';
      default:
        return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  String _getInvoiceStatusDisplayName(String status) {
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        clientId: widget.client.id,
        onSave: (projectCreate) async {
          final result = await ref
              .read(projectProvider.notifier)
              .createProject(projectCreate);
          if (result != null && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Project created successfully")),
            );
            // Refresh the view
            setState(() {});
          }
        },
      ),
    );
  }

  void _showEditClientDialog(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onSave: (clientCreate) async {
          final clientUpdate = ClientUpdate(
            name: clientCreate.name,
            address: clientCreate.address,
            gstPercent: clientCreate.gstPercent,
          );
          final result = await ref
              .read(clientProvider.notifier)
              .updateClient(client.id, clientUpdate);
          if (result != null && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Client updated successfully")),
            );
            // Refresh the view
            setState(() {});
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Client"),
        content: const Text("Are you sure you want to delete this client? This will also affect all associated projects and invoices."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(clientProvider.notifier)
                  .deleteClient(client.id);
              if (success && mounted) {
                Navigator.of(context).pop(); // Go back to clients list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Client deleted successfully")),
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

// Reusable Project Form Dialog
class ProjectFormDialog extends ConsumerStatefulWidget {
  final Project? project;
  final int? clientId; // Pre-filled client ID when creating from client details
  final Function(ProjectCreate) onSave;

  const ProjectFormDialog({
    super.key,
    this.project,
    this.clientId,
    required this.onSave,
  });

  @override
  ConsumerState<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _statusController = TextEditingController();
  final _notesController = TextEditingController();
  int? _selectedCompanyId;
  int? _selectedClientId;

  final List<String> _statusOptions = [
    'in_progress',
    'completed',
    'pending',
    'on_hold',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill client if provided
    if (widget.clientId != null) {
      _selectedClientId = widget.clientId;
      // Auto-select company for this client
      final clientState = ref.read(clientProvider);
      try {
        final client = clientState.clients.firstWhere((c) => c.id == widget.clientId);
        _selectedCompanyId = client.companyId;
      } catch (e) {
        // Client not found
      }
    }
    
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _addressController.text = widget.project!.address ?? "";
      _statusController.text = widget.project!.status ?? "";
      _notesController.text = widget.project!.notes ?? "";
      _selectedCompanyId = widget.project!.companyId;
      _selectedClientId = widget.project!.clientId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _statusController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);
    final clientState = ref.watch(clientProvider);

    return AlertDialog(
      title: Text(widget.project == null ? "Add Project" : "Edit Project"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Project Name *",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Project name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCompanyId,
                decoration: const InputDecoration(
                  labelText: "Company *",
                  border: OutlineInputBorder(),
                ),
                items: companyState.companies.map((company) {
                  return DropdownMenuItem<int>(
                    value: company.id,
                    child: Text(company.name),
                  );
                }).toList(),
                onChanged: widget.clientId == null ? (value) {
                  setState(() {
                    _selectedCompanyId = value;
                    // Reset client selection when company changes
                    _selectedClientId = null;
                  });
                } : null, // Disabled if clientId is pre-filled
                validator: (value) {
                  if (value == null) {
                    return "Please select a company";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedClientId,
                decoration: InputDecoration(
                  labelText: "Client *",
                  border: const OutlineInputBorder(),
                  helperText: widget.clientId != null ? 'Pre-filled from client details' : null,
                ),
                items: _selectedCompanyId != null
                    ? clientState.clients
                        .where((client) => client.companyId == _selectedCompanyId)
                        .map((client) {
                          return DropdownMenuItem<int>(
                            value: client.id,
                            child: Text(client.name),
                          );
                        }).toList()
                    : [],
                onChanged: widget.clientId == null && _selectedCompanyId != null
                    ? (value) {
                        setState(() {
                          _selectedClientId = value;
                        });
                      }
                    : null, // Disabled if clientId is pre-filled
                validator: (value) {
                  if (value == null) {
                    return "Please select a client";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _statusController.text.isEmpty ? null : _statusController.text,
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(_getStatusDisplayName(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _statusController.text = value ?? "";
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _saveProject,
          child: Text(widget.project == null ? "Create" : "Update"),
        ),
      ],
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
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

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final projectCreate = ProjectCreate(
        name: _nameController.text.trim(),
        companyId: _selectedCompanyId!,
        clientId: _selectedClientId!,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        status: _statusController.text.isEmpty ? "pending" : _statusController.text,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      widget.onSave(projectCreate);
    }
  }
}
