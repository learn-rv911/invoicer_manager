import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:invoice/application/client_provider.dart';
import 'package:invoice/application/project_provider.dart';
import 'package:invoice/data/models/client.dart';
import 'package:invoice/data/models/project.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

import '../../application/company_provider.dart';
import '../../application/dashboard_provider.dart';
import '../../application/invoice_provider.dart';
import '../../application/payment_provider.dart';
import '../../data/dtos/invoice_create.dart';
import '../../data/dtos/payment_create.dart';
import '../../data/models/company.dart';
import '../../utils/formatters.dart';
import 'invoices_screen.dart';
import 'payments_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _loadedOnce = false;

  // dropdown local state
  final _durationItems = const {
    "Last 7 days": 7,
    "Last 30 days": 30,
    "Last 90 days": 90,
  };
  String _durationLabel = "Last 30 days";

  int? _selectedCompany;
  int? _selectedClient;
  int? _selectedProject;
  
  // Date range state
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loadedOnce) {
        ref.read(dashboardProvider.notifier).load();
        ref.read(companyProvider.notifier).loadCompanies();
        ref.read(clientProvider.notifier).loadClients();
        ref.read(projectProvider.notifier).loadProjects();
        _loadedOnce = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return state.loading && state.summary == null
        ? const Center(child: CircularProgressIndicator())
        : _body(context, state);
  }

  Widget _body(BuildContext context, DashboardState state) {
    final s = state.summary;
    if (s == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => ref.read(dashboardProvider.notifier).load(),
          child: const Text("Reload"),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILTER BAR
          _filterBar(context, state),

          const SizedBox(height: 16),

          // CHARTS SECTION
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [
                    _buildPaidVsOutstandingChart(s),
                    const SizedBox(height: 16),
                    _exportButton(context),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPaidVsOutstandingChart(s)),
                    const SizedBox(width: 16),
                    SizedBox(width: 200, child: _exportButton(context)),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 16),

          // KPI CARDS
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 600) {
                // Mobile: Stack cards vertically
                return Column(
                  children: [
                    _enhancedKpiCard(
                      "Total Invoiced",
                      fmtMoney(s.metrics.totalAmount),
                      Icons.receipt_long,
                      Colors.blue,
                      "This period",
                    ),
                    const SizedBox(height: 16),
                    _enhancedKpiCard(
                      "Total Received",
                      fmtMoney(s.metrics.totalPaid),
                      Icons.payments,
                      Colors.green,
                      "Paid amount",
                    ),
                    const SizedBox(height: 16),
                    _enhancedKpiCard(
                      "Outstanding",
                      fmtMoney(s.metrics.outstanding),
                      Icons.schedule,
                      Colors.orange,
                      "Pending payment",
                    ),
                    const SizedBox(height: 16),
                    _enhancedKpiCard(
                      "Collection Rate",
                      "${((s.metrics.totalPaid / (s.metrics.totalAmount > 0 ? s.metrics.totalAmount : 1)) * 100).toStringAsFixed(1)}%",
                      Icons.trending_up,
                      s.metrics.totalPaid / (s.metrics.totalAmount > 0 ? s.metrics.totalAmount : 1) > 0.8 ? Colors.green : Colors.red,
                      "Payment efficiency",
                    ),
                  ],
                );
              } else {
                // Desktop: Wrap layout
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                  _enhancedKpiCard(
                    "Total Invoiced",
                    fmtMoney(s.metrics.totalAmount),
                    Icons.receipt_long,
                    Colors.blue,
                    "This period",
                  ),
                  _enhancedKpiCard(
                    "Total Received",
                    fmtMoney(s.metrics.totalPaid),
                    Icons.payments,
                    Colors.green,
                    "Paid amount",
                  ),
                  _enhancedKpiCard(
                    "Outstanding",
                    fmtMoney(s.metrics.outstanding),
                    Icons.schedule,
                    Colors.orange,
                    "Pending payment",
                  ),
                  _enhancedKpiCard(
                    "Collection Rate",
                    "${((s.metrics.totalPaid / (s.metrics.totalAmount > 0 ? s.metrics.totalAmount : 1)) * 100).toStringAsFixed(1)}%",
                    Icons.trending_up,
                    s.metrics.totalPaid / (s.metrics.totalAmount > 0 ? s.metrics.totalAmount : 1) > 0.8 ? Colors.green : Colors.red,
                    "Payment efficiency",
                  ),
                ],
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // LAST 3 INVOICES
          Row(
            children: [
              Text(
                "Recent Invoices",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.go('/invoices'),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text("View All"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _enhancedInvoicesTable(s.recentInvoices),

          const SizedBox(height: 24),

          // LAST 3 PAYMENTS
          Row(
            children: [
              Text(
                "Recent Payments",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.go('/payments'),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text("View All"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _enhancedPaymentsTable(s.recentPayments),
        ],
      ),
    );
  }

  // ---- Widgets ----
  Widget _filterBar(BuildContext context, DashboardState state) {
    final companyState = ref.watch(companyProvider);
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile: Stack filters vertically
              return Column(
                children: [
                  _dropdown<String>(
                    label: "Duration",
                    value: _durationLabel,
                    items: _durationItems.keys.toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _durationLabel = v);
                      ref
                          .read(dashboardProvider.notifier)
                          .setDays(_durationItems[v]!);
                    },
                  ),
                  const SizedBox(height: 12),
                  _dateRangePicker(context),
                  const SizedBox(height: 12),
                  _dropdown<int?>(
                    label: "Company",
                    value: _selectedCompany,
                    items: [null, ...companyState.companies.map((c) => c.id)],
                    display: (v) {
                      if (v == null) return "All Companies";
                      final company = companyState.companies.firstWhere(
                        (c) => c.id == v,
                        orElse: () => Company(id: v, name: "Unknown"),
                      );
                      return company.name;
                    },
                    onChanged: (v) {
                      setState(() {
                        _selectedCompany = v;
                        _selectedClient = null;
                        _selectedProject = null;
                      });
                      ref
                          .read(dashboardProvider.notifier)
                          .setFilters(
                            companyId: v,
                            clientId: null,
                            projectId: null,
                          );
                    },
                  ),
                  const SizedBox(height: 12),
                  _dropdown<int?>(
                    label: "Client",
                    value: _selectedClient,
                    items: _selectedCompany != null
                        ? [null, ...clientState.clients
                            .where((c) => c.companyId == _selectedCompany)
                            .map((c) => c.id)]
                        : [null, ...clientState.clients.map((c) => c.id)],
                    display: (v) {
                      if (v == null) return "All Clients";
                      final client = clientState.clients.firstWhere(
                        (c) => c.id == v,
                        orElse: () => Client(id: v, name: "Unknown", companyId: 0),
                      );
                      return client.name;
                    },
                    onChanged: (v) {
                      setState(() {
                        _selectedClient = v;
                        _selectedProject = null;
                      });
                      ref
                          .read(dashboardProvider.notifier)
                          .setFilters(
                            companyId: _selectedCompany,
                            clientId: v,
                            projectId: null,
                          );
                    },
                  ),
                  const SizedBox(height: 12),
                  _dropdown<int?>(
                    label: "Project",
                    value: _selectedProject,
                    items: _selectedClient != null
                        ? [null, ...projectState.projects
                            .where((p) => p.clientId == _selectedClient)
                            .map((p) => p.id)]
                        : [null, ...projectState.projects.map((p) => p.id)],
                    display: (v) {
                      if (v == null) return "All Projects";
                      final project = projectState.projects.firstWhere(
                        (p) => p.id == v,
                        orElse: () => Project(id: v, name: "Unknown", companyId: 0, clientId: 0),
                      );
                      return project.name;
                    },
                    onChanged: (v) {
                      setState(() => _selectedProject = v);
                      ref
                          .read(dashboardProvider.notifier)
                          .setFilters(
                            companyId: _selectedCompany,
                            clientId: _selectedClient,
                            projectId: v,
                          );
                    },
                  ),
                ],
              );
            } else {
              // Desktop: Wrap layout
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
            // Duration
            _dropdown<String>(
              label: "Duration",
              value: _durationLabel,
              items: _durationItems.keys.toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _durationLabel = v);
                ref
                    .read(dashboardProvider.notifier)
                    .setDays(_durationItems[v]!);
              },
            ),
            // Date Range Picker
            _dateRangePicker(context),
            // Company
            _dropdown<int?>(
              label: "Company",
              value: _selectedCompany,
              items: [null, ...companyState.companies.map((c) => c.id)],
              display: (v) {
                if (v == null) return "All Companies";
                final company = companyState.companies.firstWhere(
                  (c) => c.id == v,
                  orElse: () => Company(id: v, name: "Unknown"),
                );
                return company.name;
              },
              onChanged: (v) {
                setState(() {
                  _selectedCompany = v;
                  // Reset client and project when company changes
                  _selectedClient = null;
                  _selectedProject = null;
                });
                ref
                    .read(dashboardProvider.notifier)
                    .setFilters(
                      companyId: v,
                      clientId: null,
                      projectId: null,
                    );
              },
            ),
            // Client
            _dropdown<int?>(
              label: "Client",
              value: _selectedClient,
              items: _selectedCompany != null
                  ? [null, ...clientState.clients
                      .where((c) => c.companyId == _selectedCompany)
                      .map((c) => c.id)]
                  : [null, ...clientState.clients.map((c) => c.id)],
              display: (v) {
                if (v == null) return "All Clients";
                final client = clientState.clients.firstWhere(
                  (c) => c.id == v,
                  orElse: () => Client(id: v, name: "Unknown", companyId: 0),
                );
                return client.name;
              },
              onChanged: (v) {
                setState(() {
                  _selectedClient = v;
                  // Reset project when client changes
                  _selectedProject = null;
                });
                ref
                    .read(dashboardProvider.notifier)
                    .setFilters(
                      companyId: _selectedCompany,
                      clientId: v,
                      projectId: null,
                    );
              },
            ),
            // Project
            _dropdown<int?>(
              label: "Project",
              value: _selectedProject,
              items: _selectedClient != null
                  ? [null, ...projectState.projects
                      .where((p) => p.clientId == _selectedClient)
                      .map((p) => p.id)]
                  : [null, ...projectState.projects.map((p) => p.id)],
              display: (v) {
                if (v == null) return "All Projects";
                final project = projectState.projects.firstWhere(
                  (p) => p.id == v,
                  orElse: () => Project(id: v, name: "Unknown", companyId: 0, clientId: 0),
                );
                return project.name;
              },
              onChanged: (v) {
                setState(() => _selectedProject = v);
                ref
                    .read(dashboardProvider.notifier)
                    .setFilters(
                      companyId: _selectedCompany,
                      clientId: _selectedClient,
                      projectId: v,
                    );
              },
            ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value) {
    return SizedBox(
      width: 320,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _enhancedKpiCard(String title, String value, IconData icon, Color color, String subtitle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth < 600 ? double.infinity : 280,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _invoicesTable(List<Map<String, dynamic>> items) {
    // expected fields: invoice_number, issue_date, client_id, project_id, total, status
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);
    
    final rows =
        items
            .take(3)
            .map(
              (inv) {
                // Get client name
                final clientId = inv['client_id'] as int?;
                String clientName = 'Unknown';
                if (clientId != null) {
                  try {
                    final client = clientState.clients.firstWhere((c) => c.id == clientId);
                    clientName = client.name;
                  } catch (e) {
                    clientName = 'Client #$clientId';
                  }
                }
                
                // Get project name
                final projectId = inv['project_id'] as int?;
                String projectName = 'Unknown';
                if (projectId != null) {
                  try {
                    final project = projectState.projects.firstWhere((p) => p.id == projectId);
                    projectName = project.name;
                  } catch (e) {
                    projectName = 'Project #$projectId';
                  }
                }
                
                return DataRow(
                  cells: [
                    DataCell(Text(inv['invoice_number'].toString())),
                    DataCell(Text(fmtDate(inv['issue_date'].toString()))),
                    DataCell(Text(clientName)),
                    DataCell(Text(projectName)),
                    DataCell(Text(fmtMoney((inv['total'] ?? 0) as num))),
                    DataCell(_statusChip(inv['status'].toString())),
                  ],
                );
              },
            )
            .toList();

    return _dataCard(
      columns: const [
        DataColumn(label: Text("Invoice #")),
        DataColumn(label: Text("Date")),
        DataColumn(label: Text("Client")),
        DataColumn(label: Text("Project")),
        DataColumn(label: Text("Amount")),
        DataColumn(label: Text("Status")),
      ],
      rows: rows,
    );
  }

  Widget _paymentsTable(List<Map<String, dynamic>> items) {
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);
    
    final rows =
        items
            .take(3)
            .map(
              (p) {
                // Get client name
                final clientId = p['client_id'] as int?;
                String clientName = 'Unknown';
                if (clientId != null) {
                  try {
                    final client = clientState.clients.firstWhere((c) => c.id == clientId);
                    clientName = client.name;
                  } catch (e) {
                    clientName = 'Client #$clientId';
                  }
                }
                
                // Get project name
                final projectId = p['project_id'] as int?;
                String projectName = 'Unknown';
                if (projectId != null) {
                  try {
                    final project = projectState.projects.firstWhere((proj) => proj.id == projectId);
                    projectName = project.name;
                  } catch (e) {
                    projectName = 'Project #$projectId';
                  }
                }
                
                return DataRow(
                  cells: [
                    DataCell(Text(fmtDate(p['payment_date'].toString()))),
                    DataCell(Text(clientName)),
                    DataCell(Text(projectName)),
                    DataCell(Text(fmtMoney((p['amount'] ?? 0) as num))),
                    DataCell(Text(p['method']?.toString() ?? "-")),
                  ],
                );
              },
            )
            .toList();

    return _dataCard(
      columns: const [
        DataColumn(label: Text("Date")),
        DataColumn(label: Text("Client")),
        DataColumn(label: Text("Project")),
        DataColumn(label: Text("Amount")),
        DataColumn(label: Text("Method")),
      ],
      rows: rows,
    );
  }

  Widget _enhancedInvoicesTable(List<Map<String, dynamic>> items) {
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);
    
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No invoices found",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create your first invoice to get started",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: items.take(3).map((invoice) {
          // Get client name
          final clientId = invoice['client_id'] as int?;
          String clientName = 'Unknown';
          if (clientId != null) {
            try {
              final client = clientState.clients.firstWhere((c) => c.id == clientId);
              clientName = client.name;
            } catch (e) {
              clientName = 'Client #$clientId';
            }
          }
          
          // Get project name
          final projectId = invoice['project_id'] as int?;
          String projectName = 'Unknown';
          if (projectId != null) {
            try {
              final project = projectState.projects.firstWhere((proj) => proj.id == projectId);
              projectName = project.name;
            } catch (e) {
              projectName = 'Project #$projectId';
            }
          }

          final status = invoice['status']?.toString() ?? 'draft';
          final statusColor = _getStatusColor(status);
          final statusIcon = _getStatusIcon(status);

          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              title: Text(
                invoice['invoice_number']?.toString() ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('$clientName • $projectName'),
                  const SizedBox(height: 2),
                  Text(
                    fmtDate(invoice['issue_date']?.toString() ?? ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmtMoney((invoice['total'] ?? 0) as num),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Navigate to invoice details
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _enhancedPaymentsTable(List<Map<String, dynamic>> items) {
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);
    
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.payments, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No payments found",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Record your first payment to get started",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: items.take(3).map((payment) {
          // Get client name
          final clientId = payment['client_id'] as int?;
          String clientName = 'Unknown';
          if (clientId != null) {
            try {
              final client = clientState.clients.firstWhere((c) => c.id == clientId);
              clientName = client.name;
            } catch (e) {
              clientName = 'Client #$clientId';
            }
          }
          
          // Get project name
          final projectId = payment['project_id'] as int?;
          String projectName = 'Unknown';
          if (projectId != null) {
            try {
              final project = projectState.projects.firstWhere((proj) => proj.id == projectId);
              projectName = project.name;
            } catch (e) {
              projectName = 'Project #$projectId';
            }
          }

          final method = payment['method']?.toString() ?? 'cash';
          final methodColor = _getPaymentMethodColor(method);
          final methodIcon = _getPaymentMethodIcon(method);

          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: methodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(methodIcon, color: methodColor, size: 20),
              ),
              title: Text(
                fmtDate(payment['payment_date']?.toString() ?? ''),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('$clientName • $projectName'),
                  const SizedBox(height: 2),
                  Text(
                    method.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: methodColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                fmtMoney((payment['amount'] ?? 0) as num),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              onTap: () {
                // Navigate to payment details
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dataCard({
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "No data available",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            : DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w700),
                columns: columns,
                rows: rows,
                dividerThickness: 0.5,
                dataRowMinHeight: 44,
              ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case "paid":
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case "sent":
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        break;
      case "overdue":
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
      default: // draft
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF616161);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  // generic dropdown
  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    String Function(T)? display,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      width: 220,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            items:
                items.map((e) {
                  final text = display != null ? display(e) : e.toString();
                  return DropdownMenuItem<T>(value: e, child: Text(text));
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      case 'cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'sent':
        return Icons.send;
      case 'overdue':
        return Icons.warning;
      case 'draft':
        return Icons.edit;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'cheque':
        return Colors.blue;
      case 'bank_transfer':
        return Colors.purple;
      case 'upi':
        return Colors.orange;
      case 'card':
        return Colors.red;
      case 'other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'cheque':
        return Icons.account_balance;
      case 'bank_transfer':
        return Icons.account_balance_wallet;
      case 'upi':
        return Icons.phone_android;
      case 'card':
        return Icons.credit_card;
      case 'other':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  void _showInvoiceForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => InvoiceFormDialog(
        invoice: null, // null for new invoice
        onSave: (InvoiceCreate invoiceCreate) async {
          try {
            await ref.read(invoiceProvider.notifier).createInvoice(invoiceCreate);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Invoice created successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh dashboard data
              ref.read(dashboardProvider.notifier).load();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error creating invoice: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showPaymentForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PaymentFormDialog(
        payment: null, // null for new payment
        onSave: (PaymentCreate paymentCreate) async {
          try {
            await ref.read(paymentProvider.notifier).createPayment(paymentCreate);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Payment recorded successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh dashboard data
              ref.read(dashboardProvider.notifier).load();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error recording payment: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  // Date Range Picker
  Widget _dateRangePicker(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    String displayText = 'Select Date Range';
    
    if (_fromDate != null || _toDate != null) {
      displayText = '';
      if (_fromDate != null) {
        displayText += dateFormat.format(_fromDate!);
      }
      if (_toDate != null) {
        if (_fromDate != null) displayText += ' - ';
        displayText += dateFormat.format(_toDate!);
      }
    }

    return SizedBox(
      width: 220,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.date_range, size: 18),
        label: Text(
          displayText,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            initialDateRange: _fromDate != null && _toDate != null
                ? DateTimeRange(start: _fromDate!, end: _toDate!)
                : null,
          );
          
          if (picked != null) {
            setState(() {
              _fromDate = picked.start;
              _toDate = picked.end;
            });
            
            ref.read(dashboardProvider.notifier).setDateRange(
              fromDate: dateFormat.format(picked.start),
              toDate: dateFormat.format(picked.end),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }

  // Paid vs Outstanding Pie Chart
  Widget _buildPaidVsOutstandingChart(summary) {
    final total = summary.metrics.totalAmount;
    final paid = summary.metrics.totalPaid;
    final outstanding = summary.metrics.outstanding;

    if (total == 0) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('No data available for chart'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Distribution',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: paid,
                            title: '${((paid / total) * 100).toStringAsFixed(1)}%',
                            color: Colors.green,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: outstanding,
                            title: '${((outstanding / total) * 100).toStringAsFixed(1)}%',
                            color: Colors.orange,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _chartLegendItem('Paid', Colors.green, fmtMoney(paid)),
                        const SizedBox(height: 12),
                        _chartLegendItem('Outstanding', Colors.orange, fmtMoney(outstanding)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Export Button
  Widget _exportButton(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Export Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _exportData('csv'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.code, size: 18),
              label: const Text('Export JSON'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _exportData('json'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(String format) async {
    try {
      final response = await ref.read(dashboardProvider.notifier).exportDashboard(format);
      
      // Create blob and download
      final bytes = response.data as Uint8List;
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'dashboard_export_${DateTime.now().millisecondsSinceEpoch}.$format')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dashboard exported as $format successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
