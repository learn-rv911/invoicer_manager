import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/company_provider.dart';
import '../../data/dtos/company_create.dart';
import '../../data/dtos/company_update.dart';
import '../../data/models/company.dart';

class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loadedOnce) {
        ref.read(companyProvider.notifier).loadCompanies();
        _loadedOnce = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);

    return companyState.loading && companyState.companies.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _buildBody(companyState);
  }

  Widget _buildBody(CompanyState state) {
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
              onPressed:
                  () => ref.read(companyProvider.notifier).loadCompanies(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (state.companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No companies found",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first company to get started",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateCompanyDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Add Company"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(companyProvider.notifier).loadCompanies(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.companies.length,
        itemBuilder: (context, index) {
          final company = state.companies[index];
          return _buildCompanyCard(company);
        },
      ),
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            company.name.isNotEmpty ? company.name[0].toUpperCase() : "?",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          company.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (company.address != null) ...[
              const SizedBox(height: 4),
              Text(company.address!, style: TextStyle(color: Colors.grey[600])),
            ],
            if (company.gstPercent != null) ...[
              const SizedBox(height: 4),
              Text(
                "GST: ${company.gstPercent}%",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCompanyDialog(context, company);
                break;
              case 'delete':
                _showDeleteConfirmation(context, company);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  void _showCreateCompanyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => CompanyFormDialog(
            onSave: (companyCreate) async {
              final result = await ref
                  .read(companyProvider.notifier)
                  .createCompany(companyCreate);
              if (result != null && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Company created successfully")),
                );
              }
            },
          ),
    );
  }

  void _showEditCompanyDialog(BuildContext context, Company company) {
    showDialog(
      context: context,
      builder:
          (context) => CompanyFormDialog(
            company: company,
            onSave: (companyCreate) async {
              // Convert CompanyCreate to CompanyUpdate
              final companyUpdate = CompanyUpdate(
                name: companyCreate.name,
                address: companyCreate.address,
                gstPercent: companyCreate.gstPercent,
              );
              final result = await ref
                  .read(companyProvider.notifier)
                  .updateCompany(company.id, companyUpdate);
              if (result != null && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Company updated successfully")),
                );
              }
            },
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Company company) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Company"),
            content: Text("Are you sure you want to delete '${company.name}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final success = await ref
                      .read(companyProvider.notifier)
                      .deleteCompany(company.id);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Company deleted successfully"),
                      ),
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

class CompanyFormDialog extends StatefulWidget {
  final Company? company;
  final Function(CompanyCreate) onSave;

  const CompanyFormDialog({super.key, this.company, required this.onSave});

  @override
  State<CompanyFormDialog> createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends State<CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameController.text = widget.company!.name;
      _addressController.text = widget.company!.address ?? "";
      _gstController.text = widget.company!.gstPercent?.toString() ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.company == null ? "Add Company" : "Edit Company"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Company Name *",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Company name is required";
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
            TextFormField(
              controller: _gstController,
              decoration: const InputDecoration(
                labelText: "GST Percentage",
                border: OutlineInputBorder(),
                suffixText: "%",
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final gst = int.tryParse(value);
                  if (gst == null || gst < 0 || gst > 100) {
                    return "GST must be between 0 and 100";
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _saveCompany,
          child: Text(widget.company == null ? "Create" : "Update"),
        ),
      ],
    );
  }

  void _saveCompany() {
    if (_formKey.currentState!.validate()) {
      final companyCreate = CompanyCreate(
        name: _nameController.text.trim(),
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        gstPercent:
            _gstController.text.trim().isEmpty
                ? null
                : int.tryParse(_gstController.text.trim()),
      );
      widget.onSave(companyCreate);
    }
  }
}
