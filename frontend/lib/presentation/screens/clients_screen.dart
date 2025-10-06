import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/client_provider.dart';
import '../../application/company_provider.dart';
import '../../data/dtos/client_create.dart';
import '../../data/dtos/client_update.dart';
import '../../data/models/client.dart';
import '../../data/models/company.dart';
import 'client_details_screen.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loadedOnce) {
        ref.read(clientProvider.notifier).loadClients();
        ref.read(companyProvider.notifier).loadCompanies();
        _loadedOnce = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(clientProvider);

    return clientState.loading && clientState.clients.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _buildBody(clientState);
  }

  Widget _buildBody(ClientState state) {
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
                  () => ref.read(clientProvider.notifier).loadClients(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (state.clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No clients found",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first client to get started",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateClientDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Add Client"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(clientProvider.notifier).loadClients(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.clients.length,
        itemBuilder: (context, index) {
          final client = state.clients[index];
          return _buildClientCard(client);
        },
      ),
    );
  }

  Widget _buildClientCard(Client client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ClientDetailsScreen(client: client),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            client.name.isNotEmpty ? client.name[0].toUpperCase() : "?",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (client.address != null) ...[
              const SizedBox(height: 4),
              Text(client.address!, style: TextStyle(color: Colors.grey[600])),
            ],
            if (client.gstPercent != null) ...[
              const SizedBox(height: 4),
              Text(
                "GST: ${client.gstPercent}%",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              "Company ID: ${client.companyId}",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
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

  void _showCreateClientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ClientFormDialog(
            onSave: (clientCreate) async {
              final result = await ref
                  .read(clientProvider.notifier)
                  .createClient(clientCreate);
              if (result != null && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Client created successfully")),
                );
              }
            },
          ),
    );
  }

  void _showEditClientDialog(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder:
          (context) => ClientFormDialog(
            client: client,
            onSave: (clientCreate) async {
              // Convert ClientCreate to ClientUpdate
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
              }
            },
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Client"),
            content: Text("Are you sure you want to delete '${client.name}'?"),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Client deleted successfully"),
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

class ClientFormDialog extends ConsumerStatefulWidget {
  final Client? client;
  final Function(ClientCreate) onSave;

  const ClientFormDialog({super.key, this.client, required this.onSave});

  @override
  ConsumerState<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends ConsumerState<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  int? _selectedCompanyId;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _addressController.text = widget.client!.address ?? "";
      _gstController.text = widget.client!.gstPercent?.toString() ?? "";
      _selectedCompanyId = widget.client!.companyId;
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
    final companyState = ref.watch(companyProvider);

    return AlertDialog(
      title: Text(widget.client == null ? "Add Client" : "Edit Client"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Client Name *",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Client name is required";
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
              onChanged: (value) {
                setState(() {
                  _selectedCompanyId = value;
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
          onPressed: _saveClient,
          child: Text(widget.client == null ? "Create" : "Update"),
        ),
      ],
    );
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      final clientCreate = ClientCreate(
        name: _nameController.text.trim(),
        companyId: _selectedCompanyId!,
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        gstPercent:
            _gstController.text.trim().isEmpty
                ? null
                : int.tryParse(_gstController.text.trim()),
      );
      widget.onSave(clientCreate);
    }
  }
}
