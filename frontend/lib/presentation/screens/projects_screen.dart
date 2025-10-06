import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/client_provider.dart';
import '../../application/company_provider.dart';
import '../../application/project_provider.dart';
import '../../data/dtos/project_create.dart';
import '../../data/dtos/project_update.dart';
import '../../data/models/client.dart';
import '../../data/models/project.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  bool _loadedOnce = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loadedOnce) {
        ref.read(projectProvider.notifier).loadProjects();
        ref.read(companyProvider.notifier).loadCompanies();
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
    final projectState = ref.watch(projectProvider);

    return projectState.loading && projectState.projects.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _buildBody(projectState);
  }

  Widget _buildBody(ProjectState state) {
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
                  () => ref.read(projectProvider.notifier).loadProjects(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final filteredProjects = _getFilteredProjects(state.projects);
    final paginatedProjects = _getPaginatedProjects(filteredProjects);

    if (state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No projects found",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first project to get started",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateProjectDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Add Project"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(projectProvider.notifier).loadProjects(),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  _currentPage = 1; // Reset to first page when searching
                });
              },
              decoration: InputDecoration(
                hintText: "Search projects by name or client...",
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
          ),
          // Projects List
          Expanded(
            child: filteredProjects.isEmpty
                ? _buildNoResultsFound()
                : _buildProjectsList(paginatedProjects),
          ),
          // Pagination
          if (filteredProjects.length > _itemsPerPage)
            _buildPagination(filteredProjects.length),
        ],
      ),
    );
  }

  List<Project> _getFilteredProjects(List<Project> projects) {
    if (_searchQuery.isEmpty) return projects;
    
    return projects.where((project) {
      final client = _getClientForProject(project);
      final projectName = project.name.toLowerCase();
      final clientName = client?.name.toLowerCase() ?? '';
      final status = project.status?.toLowerCase() ?? '';
      
      return projectName.contains(_searchQuery) ||
             clientName.contains(_searchQuery) ||
             status.contains(_searchQuery);
    }).toList();
  }

  List<Project> _getPaginatedProjects(List<Project> projects) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, projects.length);
    return projects.sublist(startIndex, endIndex);
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No projects found",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search terms",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    final client = _getClientForProject(project);
    final statusColor = _getStatusColor(project.status ?? "Unknown");
    
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
                builder: (context) => ProjectDetailsScreen(project: project),
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
              // Circular Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    project.name.isNotEmpty ? project.name[0].toUpperCase() : 'P',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Project Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (client != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        client.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Status: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _getStatusDisplayName(project.status ?? "Unknown"),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "ID: ${project.id}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (project.address != null && project.address!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        project.address!,
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
              ),
              
              // Ellipsis Menu
              GestureDetector(
                onTap: () {
                  print('Ellipsis tapped for project: ${project.name}');
                  _showActionMenu(context, project);
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
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
    final totalPages = (_getFilteredProjects(ref.read(projectProvider).projects).length / _itemsPerPage).ceil();
    if (_currentPage < totalPages) {
      setState(() {
        _currentPage++;
      });
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

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            onSave: (projectCreate) async {
              final result = await ref
                  .read(projectProvider.notifier)
                  .createProject(projectCreate);
              if (result != null && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Project created successfully")),
                );
              }
            },
          ),
    );
  }

  void _showActionMenu(BuildContext context, Project project) {
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
                    builder: (context) => ProjectDetailsScreen(project: project),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                print('Edit selected for project: ${project.name}');
                _showEditProjectDialog(context, project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                print('Delete selected for project: ${project.name}');
                _showDeleteConfirmation(context, project);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    print('_showEditProjectDialog called for project: ${project.name}'); // Debug print
    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => ProjectFormDialog(
          project: project,
          onSave: (projectCreate) async {
            try {
              // Convert ProjectCreate to ProjectUpdate
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening edit dialog: $e")),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Project deleted successfully"),
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

class ProjectFormDialog extends ConsumerStatefulWidget {
  final Project? project;
  final Function(ProjectCreate) onSave;

  const ProjectFormDialog({super.key, this.project, required this.onSave});

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
                items:
                    companyState.companies.map((company) {
                      return DropdownMenuItem<int>(
                        value: company.id,
                        child: Text(company.name),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCompanyId = value;
                    // Reset client selection when company changes
                    _selectedClientId = null;
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
              DropdownButtonFormField<int>(
                value: _selectedClientId,
                decoration: const InputDecoration(
                  labelText: "Client *",
                  border: OutlineInputBorder(),
                ),
                items:
                    _selectedCompanyId != null
                        ? clientState.clients
                            .where(
                              (client) =>
                                  client.companyId == _selectedCompanyId,
                            )
                            .map((client) {
                              return DropdownMenuItem<int>(
                                value: client.id,
                                child: Text(client.name),
                              );
                            })
                            .toList()
                        : [],
                onChanged:
                    _selectedCompanyId != null
                        ? (value) {
                          setState(() {
                            _selectedClientId = value;
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
                value:
                    _statusController.text.isEmpty
                        ? null
                        : _statusController.text,
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
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        status:
            _statusController.text.trim().isEmpty
                ? null
                : _statusController.text.trim(),
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );
      widget.onSave(projectCreate);
    }
  }
}
