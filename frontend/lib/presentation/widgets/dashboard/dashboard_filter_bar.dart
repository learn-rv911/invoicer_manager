import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme_constants.dart';
import '../../../application/dashboard_provider.dart';
import '../../../application/company_provider.dart';
import '../../../application/client_provider.dart';
import '../../../application/project_provider.dart';
import '../../../data/models/company.dart';
import '../../../data/models/client.dart';
import '../../../data/models/project.dart';

class DashboardFilterBar extends ConsumerStatefulWidget {
  const DashboardFilterBar({super.key});

  @override
  ConsumerState<DashboardFilterBar> createState() =>
      _DashboardFilterBarState();
}

class _DashboardFilterBarState extends ConsumerState<DashboardFilterBar> {
  int? _selectedCompany;
  int? _selectedClient;
  int? _selectedProject;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _durationLabel = "Last 30 days";

  final _durationItems = const {
    "Last 7 days": 7,
    "Last 30 days": 30,
    "Last 90 days": 90,
  };

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);
    final clientState = ref.watch(clientProvider);
    final projectState = ref.watch(projectProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: AppTheme.elevationLow,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neutral.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 768) {
              return _buildMobileLayout(
                  companyState, clientState, projectState);
            }
            return _buildDesktopLayout(
                companyState, clientState, projectState);
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      CompanyState companyState, ClientState clientState, ProjectState projectState) {
    return Wrap(
      spacing: AppTheme.spacing12,
      runSpacing: AppTheme.spacing12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildFilterChip(
          icon: Icons.calendar_today_rounded,
          label: _durationLabel,
          onTap: () => _showDurationMenu(context),
        ),
        _buildFilterChip(
          icon: Icons.date_range_rounded,
          label: _getDateRangeLabel(),
          onTap: () => _selectDateRange(context),
        ),
        _buildFilterDropdown<int?>(
          icon: Icons.business_rounded,
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
            ref.read(dashboardProvider.notifier).setFilters(
                  companyId: v,
                  clientId: null,
                  projectId: null,
                );
          },
        ),
        _buildFilterDropdown<int?>(
          icon: Icons.person_rounded,
          label: "Client",
          value: _selectedClient,
          items: _selectedCompany != null
              ? [
                  null,
                  ...clientState.clients
                      .where((c) => c.companyId == _selectedCompany)
                      .map((c) => c.id)
                ]
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
            ref.read(dashboardProvider.notifier).setFilters(
                  companyId: _selectedCompany,
                  clientId: v,
                  projectId: null,
                );
          },
        ),
        _buildFilterDropdown<int?>(
          icon: Icons.folder_rounded,
          label: "Project",
          value: _selectedProject,
          items: _selectedClient != null
              ? [
                  null,
                  ...projectState.projects
                      .where((p) => p.clientId == _selectedClient)
                      .map((p) => p.id)
                ]
              : [null, ...projectState.projects.map((p) => p.id)],
          display: (v) {
            if (v == null) return "All Projects";
            final project = projectState.projects.firstWhere(
              (p) => p.id == v,
              orElse: () =>
                  Project(id: v, name: "Unknown", companyId: 0, clientId: 0),
            );
            return project.name;
          },
          onChanged: (v) {
            setState(() => _selectedProject = v);
            ref.read(dashboardProvider.notifier).setFilters(
                  companyId: _selectedCompany,
                  clientId: _selectedClient,
                  projectId: v,
                );
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      CompanyState companyState, ClientState clientState, ProjectState projectState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilterChip(
          icon: Icons.calendar_today_rounded,
          label: _durationLabel,
          onTap: () => _showDurationMenu(context),
        ),
        const SizedBox(height: AppTheme.spacing8),
        _buildFilterChip(
          icon: Icons.date_range_rounded,
          label: _getDateRangeLabel(),
          onTap: () => _selectDateRange(context),
        ),
        const SizedBox(height: AppTheme.spacing8),
        _buildFilterDropdown<int?>(
          icon: Icons.business_rounded,
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
            ref.read(dashboardProvider.notifier).setFilters(
                  companyId: v,
                  clientId: null,
                  projectId: null,
                );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.05),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primary),
            const SizedBox(width: AppTheme.spacing8),
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: AppTheme.spacing4),
            Icon(Icons.arrow_drop_down_rounded,
                size: 18, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required IconData icon,
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.neutral.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
                items: items.map((e) {
                  return DropdownMenuItem<T>(
                    value: e,
                    child: Text(
                      display(e),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeLabel() {
    if (_fromDate != null || _toDate != null) {
      final format = DateFormat('MMM d');
      String text = '';
      if (_fromDate != null) text += format.format(_fromDate!);
      if (_toDate != null) {
        if (_fromDate != null) text += ' - ';
        text += format.format(_toDate!);
      }
      return text;
    }
    return 'Select Date Range';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });

      final format = DateFormat('yyyy-MM-dd');
      ref.read(dashboardProvider.notifier).setDateRange(
            fromDate: format.format(picked.start),
            toDate: format.format(picked.end),
          );
    }
  }

  void _showDurationMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: _durationItems.keys.map((String key) {
        return PopupMenuItem<String>(
          value: key,
          child: Text(key),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() => _durationLabel = value);
        ref
            .read(dashboardProvider.notifier)
            .setDays(_durationItems[value]!);
      }
    });
  }
}

