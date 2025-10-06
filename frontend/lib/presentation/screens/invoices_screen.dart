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
import 'invoice_details_screen.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  bool _loadedOnce = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatusFilter;
  int? _selectedClientFilter;
  int? _selectedProjectFilter;
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  final List<String> _statusFilters = [
    'All',
    'draft',
    'sent',
    'paid',
    'overdue',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loadedOnce) {
        ref.read(invoiceProvider.notifier).loadInvoices();
        ref.read(companyProvider.notifier).loadCompanies();
        ref.read(clientProvider.notifier).loadClients();
        ref.read(projectProvider.notifier).loadProjects();
        _loadedOnce = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceProvider);

    return invoiceState.loading && invoiceState.invoices.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _buildBody(invoiceState);
  }

  Widget _buildBody(InvoiceState state) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              "Error: ${state.error}",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(invoiceProvider.notifier).loadInvoices(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final filteredInvoices = _getFilteredInvoices(state.invoices);
    final paginatedInvoices = _getPaginatedInvoices(filteredInvoices);

    if (state.invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No invoices found",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first invoice to get started",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateInvoiceDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Create Invoice"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(invoiceProvider.notifier).loadInvoices(),
      child: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                      _currentPage = 1;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search invoices by number or description...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _currentPage = 1;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                // Filters - Responsive Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Mobile: Stack filters vertically
                      return Column(
                        children: [
                          _buildStatusFilter(),
                          const SizedBox(height: 12),
                          _buildClientFilter(),
                          const SizedBox(height: 12),
                          _buildProjectFilter(),
                        ],
                      );
                    } else {
                      // Desktop: Row layout
                      return Row(
                        children: [
                          Expanded(child: _buildStatusFilter()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildClientFilter()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildProjectFilter()),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Invoices List
          Expanded(
            child: filteredInvoices.isEmpty
                ? _buildNoResultsFound()
                : _buildInvoicesList(paginatedInvoices),
          ),
          // Pagination
          if (filteredInvoices.length > _itemsPerPage)
            _buildPagination(filteredInvoices.length),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedStatusFilter,
      decoration: InputDecoration(
        labelText: "Status",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      items: _statusFilters.map((status) {
        return DropdownMenuItem(
          value: status == 'All' ? null : status,
          child: Text(_getStatusDisplayName(status)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatusFilter = value;
          _currentPage = 1;
        });
      },
    );
  }

  Widget _buildClientFilter() {
    final clientState = ref.watch(clientProvider);
    
    return DropdownButtonFormField<int>(
      value: _selectedClientFilter,
      decoration: InputDecoration(
        labelText: "Client",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      items: [
        const DropdownMenuItem<int>(
          value: null,
          child: Text('All Clients'),
        ),
        ...clientState.clients.map((client) {
          return DropdownMenuItem<int>(
            value: client.id,
            child: Text(client.name),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedClientFilter = value;
          // Reset project filter when client changes
          _selectedProjectFilter = null;
          _currentPage = 1;
        });
      },
    );
  }

  Widget _buildProjectFilter() {
    final projectState = ref.watch(projectProvider);
    
    // Filter projects based on selected client
    final filteredProjects = _selectedClientFilter != null
        ? projectState.projects.where((project) => project.clientId == _selectedClientFilter).toList()
        : projectState.projects;
    
    return DropdownButtonFormField<int>(
      value: _selectedProjectFilter,
      decoration: InputDecoration(
        labelText: "Project",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      items: [
        const DropdownMenuItem<int>(
          value: null,
          child: Text('All Projects'),
        ),
        ...filteredProjects.map((project) {
          return DropdownMenuItem<int>(
            value: project.id,
            child: Text(project.name),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedProjectFilter = value;
          _currentPage = 1;
        });
      },
    );
  }

  List<Invoice> _getFilteredInvoices(List<Invoice> invoices) {
    var filtered = invoices;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((invoice) {
        final invoiceNumber = invoice.invoiceNumber.toLowerCase();
        final description = invoice.description?.toLowerCase() ?? '';
        final notes = invoice.notes?.toLowerCase() ?? '';
        
        // Also search in client and project names
        final project = _getProjectForInvoice(invoice);
        final client = project != null ? _getClientForProject(project) : null;
        final clientName = client?.name.toLowerCase() ?? '';
        final projectName = project?.name.toLowerCase() ?? '';
        
        return invoiceNumber.contains(_searchQuery) ||
            description.contains(_searchQuery) ||
            notes.contains(_searchQuery) ||
            clientName.contains(_searchQuery) ||
            projectName.contains(_searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatusFilter != null) {
      filtered = filtered.where((invoice) {
        return invoice.status.toLowerCase() == _selectedStatusFilter!.toLowerCase();
      }).toList();
    }

    // Apply client filter
    if (_selectedClientFilter != null) {
      filtered = filtered.where((invoice) {
        final project = _getProjectForInvoice(invoice);
        return project?.clientId == _selectedClientFilter;
      }).toList();
    }

    // Apply project filter
    if (_selectedProjectFilter != null) {
      filtered = filtered.where((invoice) {
        return invoice.projectId == _selectedProjectFilter;
      }).toList();
    }

    return filtered;
  }

  List<Invoice> _getPaginatedInvoices(List<Invoice> invoices) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, invoices.length);
    return invoices.sublist(startIndex, endIndex);
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No invoices found",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList(List<Invoice> invoices) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _buildInvoiceCard(invoice);
      },
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final project = _getProjectForInvoice(invoice);
    final client = project != null ? _getClientForProject(project) : null;
    final statusColor = _getInvoiceStatusColor(invoice.status);
    final isOverdue = invoice.isOverdue;
    
    // Calculate display amount (use totalAmount, or fallback to amount + tax)
    final displayAmount = invoice.totalAmount > 0 
        ? invoice.totalAmount 
        : invoice.amount + (invoice.taxAmount ?? 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InvoiceDetailsScreen(invoice: invoice),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: isOverdue
                ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Invoice Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Invoice Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusDisplayName(invoice.status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (client != null) ...[
                      Text(
                        client.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (invoice.description != null)
                      Text(
                        invoice.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Amount: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "₹${displayAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(invoice.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Menu
              GestureDetector(
                onTap: () {
                  _showActionMenu(context, invoice);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final startItem = (_currentPage - 1) * _itemsPerPage + 1;
    final endItem = (_currentPage * _itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing $startItem to $endItem of $totalItems results",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? _previousPage : null,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: _currentPage > 1 ? Colors.white : Colors.grey[100],
                  foregroundColor: _currentPage > 1 ? Colors.blue : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 8),
              for (int i = 1; i <= totalPages && i <= 5; i++) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: i == _currentPage ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: i == _currentPage ? Colors.blue : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      i.toString(),
                      style: TextStyle(
                        color: i == _currentPage ? Colors.white : Colors.black87,
                        fontWeight: i == _currentPage ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (totalPages > 5) ...[
                const Text("...", style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 4),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: totalPages == _currentPage ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: totalPages == _currentPage ? Colors.blue : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      totalPages.toString(),
                      style: TextStyle(
                        color: totalPages == _currentPage ? Colors.white : Colors.black87,
                        fontWeight: totalPages == _currentPage ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              IconButton(
                onPressed: _currentPage < totalPages ? _nextPage : null,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: _currentPage < totalPages ? Colors.white : Colors.grey[100],
                  foregroundColor: _currentPage < totalPages ? Colors.blue : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _nextPage() {
    final invoiceState = ref.read(invoiceProvider);
    final filteredInvoices = _getFilteredInvoices(invoiceState.invoices);
    final totalPages = (filteredInvoices.length / _itemsPerPage).ceil();
    if (_currentPage < totalPages) {
      setState(() {
        _currentPage++;
      });
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
      case 'all':
        return 'All Status';
      default:
        return status;
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

  void _showActionMenu(BuildContext context, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InvoiceDetailsScreen(invoice: invoice),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditInvoiceDialog(context, invoice);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, invoice);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => InvoiceFormDialog(
        onSave: (invoiceCreate) async {
          final result = await ref
              .read(invoiceProvider.notifier)
              .createInvoice(invoiceCreate);
          if (result != null && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invoice created successfully")),
            );
          }
        },
      ),
    );
  }

  void _showEditInvoiceDialog(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => InvoiceFormDialog(
        invoice: invoice,
        onSave: (invoiceCreate) async {
          final invoiceUpdate = InvoiceUpdate(
            invoiceNumber: invoiceCreate.invoiceNumber,
            clientId: invoiceCreate.clientId,
            projectId: invoiceCreate.projectId,
            issueDate: invoiceCreate.issueDate,
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

// Invoice Form Dialog
class InvoiceFormDialog extends ConsumerStatefulWidget {
  final Invoice? invoice;
  final Function(InvoiceCreate) onSave;

  const InvoiceFormDialog({
    super.key,
    this.invoice,
    required this.onSave,
  });

  @override
  ConsumerState<InvoiceFormDialog> createState() => _InvoiceFormDialogState();
}

class _InvoiceFormDialogState extends ConsumerState<InvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _taxAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  int? _selectedCompanyId;
  int? _selectedClientId;
  int? _selectedProjectId;
  String _selectedStatus = 'draft';
  DateTime _selectedInvoiceDate = DateTime.now();
  DateTime? _selectedDueDate;

  final List<String> _statusOptions = [
    'draft',
    'sent',
    'paid',
    'overdue',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _invoiceNumberController.text = widget.invoice!.invoiceNumber;
      _selectedProjectId = widget.invoice!.projectId;
      // Get company and client from the project
      final project = _getProjectById(widget.invoice!.projectId);
      if (project != null) {
        _selectedCompanyId = project.companyId;
        _selectedClientId = project.clientId;
      }
      _amountController.text = widget.invoice!.amount.toString();
      _taxAmountController.text = widget.invoice!.taxAmount?.toString() ?? '';
      _selectedStatus = widget.invoice!.status;
      _selectedInvoiceDate = widget.invoice!.createdAt;
      _selectedDueDate = widget.invoice!.dueDate;
      _descriptionController.text = widget.invoice!.description ?? '';
      _notesController.text = widget.invoice!.notes ?? '';
    } else {
      // For new invoice, set due date to 30 days from now
      _selectedDueDate = _selectedInvoiceDate.add(const Duration(days: 30));
      // Generate initial invoice number (will be updated when company is selected)
      _generateInitialInvoiceNumber();
    }
    
    // Add listener to amount field to auto-calculate tax
    _amountController.addListener(_calculateTax);
  }

  void _calculateTax() {
    if (_selectedCompanyId != null && _amountController.text.isNotEmpty) {
      final totalAmount = double.tryParse(_amountController.text);
      if (totalAmount != null) {
        final company = _getCompanyById(_selectedCompanyId!);
        if (company != null && company.gstPercent != null && company.gstPercent! > 0) {
          // Amount entered includes GST, so we need to extract the tax
          // Formula: Tax = Total × (GST% / (100 + GST%))
          final taxAmount = totalAmount * company.gstPercent! / (100 + company.gstPercent!);
          _taxAmountController.text = taxAmount.toStringAsFixed(2);
        } else {
          // No GST, clear tax field
          _taxAmountController.text = '';
        }
      }
    }
  }

  void _generateInitialInvoiceNumber() {
    // Generate a default invoice number for new invoices
    final currentYear = DateTime.now().year;
    final invoiceNumber = 'INV-$currentYear-001';
    _invoiceNumberController.text = invoiceNumber;
  }

  void _generateInvoiceNumber(int companyId) {
    // Only generate if invoice number is empty (for new invoices)
    if (widget.invoice != null) return;
    
    final invoiceState = ref.read(invoiceProvider);
    final currentYear = DateTime.now().year;
    
    // Find all invoices for this company
    final companyInvoices = invoiceState.invoices.where((invoice) {
      // Get project for this invoice
      final project = _getProjectById(invoice.projectId);
      return project?.companyId == companyId;
    }).toList();
    
    // Find the highest invoice number for this company and year
    int maxNumber = 0;
    final pattern = RegExp(r'INV-(\d{4})-(\d+)');
    
    for (final invoice in companyInvoices) {
      final match = pattern.firstMatch(invoice.invoiceNumber);
      if (match != null) {
        final invoiceYear = int.tryParse(match.group(1) ?? '');
        final invoiceNumber = int.tryParse(match.group(2) ?? '');
        
        if (invoiceYear == currentYear && invoiceNumber != null) {
          maxNumber = maxNumber > invoiceNumber ? maxNumber : invoiceNumber;
        }
      }
    }
    
    // Generate next invoice number
    final nextNumber = maxNumber + 1;
    final invoiceNumber = 'INV-$currentYear-${nextNumber.toString().padLeft(3, '0')}';
    
    // Update the invoice number field
    _invoiceNumberController.text = invoiceNumber;
  }

  Project? _getProjectById(int projectId) {
    final projectState = ref.read(projectProvider);
    try {
      return projectState.projects.firstWhere(
        (project) => project.id == projectId,
      );
    } catch (e) {
      return null;
    }
  }

  Company? _getCompanyById(int companyId) {
    final companyState = ref.read(companyProvider);
    try {
      return companyState.companies.firstWhere(
        (company) => company.id == companyId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_calculateTax);
    _invoiceNumberController.dispose();
    _amountController.dispose();
    _taxAmountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);

    return AlertDialog(
      title: Text(widget.invoice == null ? "Create Invoice" : "Edit Invoice"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _invoiceNumberController,
                readOnly: widget.invoice == null, // Auto-generated for new invoices
                decoration: InputDecoration(
                  labelText: "Invoice Number *",
                  border: const OutlineInputBorder(),
                  helperText: widget.invoice == null 
                      ? "Auto-generated based on company selection" 
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Invoice number is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Invoice Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedInvoiceDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedInvoiceDate = date;
                      // Auto-update due date to 30 days from invoice date
                      _selectedDueDate = date.add(const Duration(days: 30));
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Invoice Date *",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _formatDate(_selectedInvoiceDate),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Company Dropdown
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
                onChanged: (value) {
                  setState(() {
                    _selectedCompanyId = value;
                    // Reset client and project when company changes
                    _selectedClientId = null;
                    _selectedProjectId = null;
                    // Generate invoice number for the selected company
                    if (value != null) {
                      _generateInvoiceNumber(value);
                    }
                    // Recalculate tax when company changes
                    _calculateTax();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select a company";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Client Dropdown
              DropdownButtonFormField<int>(
                value: _selectedClientId,
                decoration: const InputDecoration(
                  labelText: "Client *",
                  border: OutlineInputBorder(),
                ),
                items: _selectedCompanyId != null
                    ? clientState.clients
                        .where((client) => client.companyId == _selectedCompanyId)
                        .map((client) {
                          return DropdownMenuItem<int>(
                            value: client.id,
                            child: Text(client.name),
                          );
                        })
                        .toList()
                    : [],
                onChanged: _selectedCompanyId != null
                    ? (value) {
                        setState(() {
                          _selectedClientId = value;
                          // Reset project when client changes
                          _selectedProjectId = null;
                        });
                      }
                    : null,
                validator: (value) {
                  if (value == null) {
                    return "Please select a client";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Project Dropdown
              DropdownButtonFormField<int>(
                value: _selectedProjectId,
                decoration: const InputDecoration(
                  labelText: "Project *",
                  border: OutlineInputBorder(),
                ),
                items: _selectedClientId != null
                    ? projectState.projects
                        .where((project) => 
                            project.clientId == _selectedClientId &&
                            project.companyId == _selectedCompanyId)
                        .map((project) {
                          return DropdownMenuItem<int>(
                            value: project.id,
                            child: Text(project.name),
                          );
                        })
                        .toList()
                    : [],
                onChanged: _selectedClientId != null
                    ? (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                      }
                    : null,
                validator: (value) {
                  if (value == null) {
                    return "Please select a project";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Total Amount (including GST) *",
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                  helperText: 'Enter total amount including tax',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Amount is required";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxAmountController,
                decoration: const InputDecoration(
                  labelText: "Tax Amount (Auto-calculated)",
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                  helperText: 'Automatically calculated based on company GST',
                ),
                keyboardType: TextInputType.number,
                readOnly: true, // Make it read-only since it's auto-calculated
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: "Status *",
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
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDueDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Due Date",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDueDate != null
                        ? _formatDate(_selectedDueDate!)
                        : 'Select due date',
                    style: TextStyle(
                      color: _selectedDueDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
          onPressed: _saveInvoice,
          child: Text(widget.invoice == null ? "Create" : "Update"),
        ),
      ],
    );
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.parse(_amountController.text.trim());
      final taxAmount = _taxAmountController.text.trim().isNotEmpty
          ? double.parse(_taxAmountController.text.trim())
          : null;
      // Subtract tax from total to get base amount
      final baseAmount = totalAmount - (taxAmount ?? 0);

      final invoiceCreate = InvoiceCreate(
        invoiceNumber: _invoiceNumberController.text.trim(),
        clientId: _selectedClientId!,
        projectId: _selectedProjectId!,
        issueDate: _selectedInvoiceDate,
        amount: baseAmount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        status: _selectedStatus,
        dueDate: _selectedDueDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      widget.onSave(invoiceCreate);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
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
}
