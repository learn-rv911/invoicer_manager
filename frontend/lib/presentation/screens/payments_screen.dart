import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/client_provider.dart';
import '../../application/company_provider.dart';
import '../../application/invoice_provider.dart';
import '../../application/payment_provider.dart';
import '../../application/project_provider.dart';
import '../../data/dtos/payment_create.dart';
import '../../data/dtos/payment_update.dart';
import '../../data/models/client.dart';
import '../../data/models/company.dart';
import '../../data/models/invoice.dart';
import '../../data/models/payment.dart';
import '../../data/models/project.dart';
import 'payment_details_screen.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  bool _loadedOnce = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedPaymentMethodFilter;
  int? _selectedClientFilter;
  int? _selectedProjectFilter;
  int? _selectedInvoiceFilter;
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  final List<String> _paymentMethodFilters = [
    'All',
    'cash',
    'cheque',
    'bank_transfer',
    'upi',
    'card',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loadedOnce) {
        ref.read(paymentProvider.notifier).loadPayments();
        ref.read(invoiceProvider.notifier).loadInvoices();
        ref.read(projectProvider.notifier).loadProjects();
        ref.read(clientProvider.notifier).loadClients();
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
    final paymentState = ref.watch(paymentProvider);

    return paymentState.loading
        ? const Center(child: CircularProgressIndicator())
        : _buildBody(paymentState);
  }

  Widget _buildBody(PaymentState state) {
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
              onPressed: () => ref.read(paymentProvider.notifier).loadPayments(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final filteredPayments = _getFilteredPayments(state.payments);
    final paginatedPayments = _getPaginatedPayments(filteredPayments);

    if (state.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No payments found",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first payment to get started",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreatePaymentDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Create Payment"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(paymentProvider.notifier).loadPayments(),
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
                    hintText: "Search payments by reference number or notes...",
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
                          _buildPaymentMethodFilter(),
                          const SizedBox(height: 12),
                          _buildClientFilter(),
                          const SizedBox(height: 12),
                          _buildProjectFilter(),
                          const SizedBox(height: 12),
                          _buildInvoiceFilter(),
                        ],
                      );
                    } else {
                      // Desktop: Row layout
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildPaymentMethodFilter()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildClientFilter()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildProjectFilter()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInvoiceFilter(),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Payments List
          Expanded(
            child: filteredPayments.isEmpty
                ? _buildNoResultsFound()
                : _buildPaymentsList(paginatedPayments),
          ),
          // Pagination
          if (filteredPayments.length > _itemsPerPage)
            _buildPagination(filteredPayments.length),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMethodFilter,
      decoration: InputDecoration(
        labelText: "Payment Method",
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
      items: _paymentMethodFilters.map((method) {
        return DropdownMenuItem(
          value: method == 'All' ? null : method,
          child: Text(_getPaymentMethodDisplayName(method)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethodFilter = value;
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
          // Reset project and invoice filters when client changes
          _selectedProjectFilter = null;
          _selectedInvoiceFilter = null;
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
          // Reset invoice filter when project changes
          _selectedInvoiceFilter = null;
          _currentPage = 1;
        });
      },
    );
  }

  Widget _buildInvoiceFilter() {
    final invoiceState = ref.watch(invoiceProvider);
    
    // Filter invoices based on selected project
    var filteredInvoices = invoiceState.invoices;
    
    if (_selectedProjectFilter != null) {
      filteredInvoices = filteredInvoices
          .where((invoice) => invoice.projectId == _selectedProjectFilter)
          .toList();
    } else if (_selectedClientFilter != null) {
      // If no project selected but client selected, show all invoices for that client's projects
      final projectState = ref.read(projectProvider);
      final clientProjects = projectState.projects
          .where((project) => project.clientId == _selectedClientFilter)
          .map((project) => project.id)
          .toSet();
      filteredInvoices = filteredInvoices
          .where((invoice) => clientProjects.contains(invoice.projectId))
          .toList();
    }
    
    return DropdownButtonFormField<int>(
      value: _selectedInvoiceFilter,
      decoration: InputDecoration(
        labelText: "Invoice",
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
          child: Text('All Invoices'),
        ),
        ...filteredInvoices.map((invoice) {
          return DropdownMenuItem<int>(
            value: invoice.id,
            child: Text(invoice.invoiceNumber),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedInvoiceFilter = value;
          _currentPage = 1;
        });
      },
    );
  }

  List<Payment> _getFilteredPayments(List<Payment> payments) {
    var filtered = payments;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((payment) {
        final referenceNumber = payment.referenceNumber?.toLowerCase() ?? '';
        final notes = payment.notes?.toLowerCase() ?? '';
        final invoice = _getInvoiceForPayment(payment);
        final invoiceNumber = invoice?.invoiceNumber.toLowerCase() ?? '';
        
        return referenceNumber.contains(_searchQuery) ||
            notes.contains(_searchQuery) ||
            invoiceNumber.contains(_searchQuery);
      }).toList();
    }

    // Apply payment method filter
    if (_selectedPaymentMethodFilter != null) {
      filtered = filtered.where((payment) {
        return payment.paymentMethod.toLowerCase() == _selectedPaymentMethodFilter!.toLowerCase();
      }).toList();
    }

    // Apply client filter
    if (_selectedClientFilter != null) {
      filtered = filtered.where((payment) {
        final invoice = _getInvoiceForPayment(payment);
        if (invoice == null) return false;
        final project = _getProjectForInvoice(invoice);
        return project?.clientId == _selectedClientFilter;
      }).toList();
    }

    // Apply project filter
    if (_selectedProjectFilter != null) {
      filtered = filtered.where((payment) {
        final invoice = _getInvoiceForPayment(payment);
        return invoice?.projectId == _selectedProjectFilter;
      }).toList();
    }

    // Apply invoice filter
    if (_selectedInvoiceFilter != null) {
      filtered = filtered.where((payment) {
        return payment.invoiceId == _selectedInvoiceFilter;
      }).toList();
    }

    return filtered;
  }

  List<Payment> _getPaginatedPayments(List<Payment> payments) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, payments.length);
    return payments.sublist(startIndex, endIndex);
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No payments found",
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

  Widget _buildPaymentsList(List<Payment> payments) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final invoice = _getInvoiceForPayment(payment);
    final project = invoice != null ? _getProjectForInvoice(invoice) : null;
    final client = project != null ? _getClientForProject(project) : null;

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
              builder: (context) => PaymentDetailsScreen(payment: payment),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Payment Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Payment Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "₹${payment.amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            payment.paymentMethodDisplayName,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (invoice != null) ...[
                      Text(
                        "Invoice: ${invoice.invoiceNumber}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (client != null) ...[
                      Text(
                        client.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(payment.paymentDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (payment.referenceNumber != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.receipt,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            payment.referenceNumber!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Menu
              GestureDetector(
                onTap: () {
                  _showActionMenu(context, payment);
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
              Text(
                "$_currentPage / $totalPages",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
    final paymentState = ref.read(paymentProvider);
    final filteredPayments = _getFilteredPayments(paymentState.payments);
    final totalPages = (filteredPayments.length / _itemsPerPage).ceil();
    if (_currentPage < totalPages) {
      setState(() {
        _currentPage++;
      });
    }
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

  String _getPaymentMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'all':
        return 'All Methods';
      case 'cash':
        return 'Cash';
      case 'cheque':
        return 'Cheque';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'upi':
        return 'UPI';
      case 'card':
        return 'Card';
      case 'other':
        return 'Other';
      default:
        return method;
    }
  }

  void _showActionMenu(BuildContext context, Payment payment) {
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
                    builder: (context) => PaymentDetailsScreen(payment: payment),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditPaymentDialog(context, payment);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, payment);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PaymentFormDialog(
        onSave: (paymentCreate) async {
          final result = await ref
              .read(paymentProvider.notifier)
              .createPayment(paymentCreate);
          if (result != null && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment created successfully")),
            );
          }
        },
      ),
    );
  }

  void _showEditPaymentDialog(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => PaymentFormDialog(
        payment: payment,
        onSave: (paymentCreate) async {
          final paymentUpdate = PaymentUpdate(
            invoiceId: paymentCreate.invoiceId,
            projectId: paymentCreate.projectId,
            paymentNumber: null,
            amount: paymentCreate.amount,
            paymentDate: paymentCreate.paymentDate,
            paymentMethod: paymentCreate.paymentMethod,
            referenceNumber: paymentCreate.referenceNumber,
            bankName: paymentCreate.bankName,
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

// Payment Form Dialog
class PaymentFormDialog extends ConsumerStatefulWidget {
  final Payment? payment;
  final Function(PaymentCreate) onSave;

  const PaymentFormDialog({
    super.key,
    this.payment,
    required this.onSave,
  });

  @override
  ConsumerState<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends ConsumerState<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _notesController = TextEditingController();
  int? _selectedCompanyId;
  int? _selectedClientId;
  int? _selectedProjectId;
  int? _selectedInvoiceId;
  String _selectedPaymentMethod = 'cash';
  DateTime _selectedPaymentDate = DateTime.now();

  final List<String> _paymentMethods = [
    'cash',
    'cheque',
    'bank_transfer',
    'upi',
    'card',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyProvider.notifier).loadCompanies();
      ref.read(clientProvider.notifier).loadClients();
      ref.read(projectProvider.notifier).loadProjects();
      ref.read(invoiceProvider.notifier).loadInvoices();
    });
    
    if (widget.payment != null) {
      _selectedInvoiceId = widget.payment!.invoiceId;
      _amountController.text = widget.payment!.amount.toString();
      _selectedPaymentMethod = widget.payment!.paymentMethod;
      _selectedPaymentDate = widget.payment!.paymentDate;
      _referenceNumberController.text = widget.payment!.referenceNumber ?? '';
      _bankNameController.text = widget.payment!.bankName ?? '';
      _notesController.text = widget.payment!.notes ?? '';
      
      // Get company, client, project from the payment's invoice
      if (_selectedInvoiceId != null) {
        final invoice = _getInvoiceById(_selectedInvoiceId!);
        if (invoice != null) {
          final project = _getProjectById(invoice.projectId);
          if (project != null) {
            _selectedProjectId = project.id;
            _selectedClientId = project.clientId;
            _selectedCompanyId = project.companyId;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceNumberController.dispose();
    _bankNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Invoice? _getInvoiceById(int invoiceId) {
    final invoiceState = ref.read(invoiceProvider);
    try {
      return invoiceState.invoices.firstWhere((invoice) => invoice.id == invoiceId);
    } catch (e) {
      return null;
    }
  }

  Project? _getProjectById(int projectId) {
    final projectState = ref.read(projectProvider);
    try {
      return projectState.projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  Client? _getClientById(int clientId) {
    final clientState = ref.read(clientProvider);
    try {
      return clientState.clients.firstWhere((client) => client.id == clientId);
    } catch (e) {
      return null;
    }
  }

  Company? _getCompanyById(int companyId) {
    final companyState = ref.read(companyProvider);
    try {
      return companyState.companies.firstWhere((company) => company.id == companyId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);
    final invoiceState = ref.watch(invoiceProvider);

    return AlertDialog(
      title: Text(widget.payment == null ? "Create Payment" : "Edit Payment"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    // Reset client, project, and invoice when company changes
                    _selectedClientId = null;
                    _selectedProjectId = null;
                    _selectedInvoiceId = null;
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
                      }).toList()
                    : [],
                onChanged: _selectedCompanyId != null
                    ? (value) {
                        setState(() {
                          _selectedClientId = value;
                          // Reset project and invoice when client changes
                          _selectedProjectId = null;
                          _selectedInvoiceId = null;
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
                        .where((project) => project.clientId == _selectedClientId)
                        .map((project) {
                        return DropdownMenuItem<int>(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }).toList()
                    : [],
                onChanged: _selectedClientId != null
                    ? (value) {
                        setState(() {
                          _selectedProjectId = value;
                          // Reset invoice when project changes
                          _selectedInvoiceId = null;
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
              // Invoice Dropdown (Optional)
              DropdownButtonFormField<int>(
                value: _selectedInvoiceId,
                decoration: const InputDecoration(
                  labelText: "Invoice (Optional)",
                  border: OutlineInputBorder(),
                  helperText: "Select an invoice if this payment is for a specific invoice",
                ),
                items: _selectedProjectId != null
                    ? invoiceState.invoices
                        .where((invoice) => invoice.projectId == _selectedProjectId)
                        .map((invoice) {
                        return DropdownMenuItem<int>(
                          value: invoice.id,
                          child: Text(invoice.invoiceNumber),
                        );
                      }).toList()
                    : [],
                onChanged: _selectedProjectId != null
                    ? (value) {
                        setState(() {
                          _selectedInvoiceId = value;
                        });
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Amount *",
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
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
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedPaymentDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedPaymentDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Payment Date *",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _formatDate(_selectedPaymentDate),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: "Payment Method *",
                  border: OutlineInputBorder(),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(_getPaymentMethodDisplayName(method)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceNumberController,
                decoration: const InputDecoration(
                  labelText: "Transaction Number",
                  border: OutlineInputBorder(),
                  helperText: 'Bank transaction or reference number',
                ),
              ),
              // Show bank name field only for cheque
              if (_selectedPaymentMethod == 'cheque') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: "Bank Name *",
                    border: OutlineInputBorder(),
                    helperText: 'Name of the bank for cheque',
                  ),
                  validator: (value) {
                    if (_selectedPaymentMethod == 'cheque' && 
                        (value == null || value.trim().isEmpty)) {
                      return "Bank name is required for cheque payment";
                    }
                    return null;
                  },
                ),
              ],
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
          onPressed: _savePayment,
          child: Text(widget.payment == null ? "Create" : "Update"),
        ),
      ],
    );
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());
      
      // Use selected project ID directly, or get from invoice if invoice is selected
      int projectId = _selectedProjectId!;
      int? invoiceId = _selectedInvoiceId;
      
      // If no invoice is selected, we can still create a payment with just project
      // The backend should handle this case

      final paymentCreate = PaymentCreate(
        invoiceId: invoiceId ?? 0, // Use 0 or a default value if no invoice selected
        projectId: projectId,
        paymentNumber: null,
        amount: amount,
        paymentDate: _selectedPaymentDate,
        paymentMethod: _selectedPaymentMethod,
        referenceNumber: _referenceNumberController.text.trim().isEmpty
            ? null
            : _referenceNumberController.text.trim(),
        bankName: _bankNameController.text.trim().isEmpty
            ? null
            : _bankNameController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      widget.onSave(paymentCreate);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  String _getPaymentMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'cheque':
        return 'Cheque';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'upi':
        return 'UPI';
      case 'card':
        return 'Card';
      case 'other':
        return 'Other';
      default:
        return method;
    }
  }
}
