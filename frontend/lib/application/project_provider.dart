import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:invoice/data/services/api_service.dart';

import '../data/dtos/project_create.dart';
import '../data/dtos/project_update.dart';
import '../data/models/project.dart';
import '../data/repositories/project_repository.dart';
import '../data/services/project_service.dart';

class ProjectState {
  final List<Project> projects;
  final bool loading;
  final String? error;

  ProjectState({this.projects = const [], this.loading = false, this.error});

  ProjectState copyWith({List<Project>? projects, bool? loading, String? error}) {
    return ProjectState(
      projects: projects ?? this.projects,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ProjectController extends StateNotifier<ProjectState> {
  final ProjectRepository _projectRepository;

  ProjectController(this._projectRepository) : super(ProjectState());

  Future<void> loadProjects({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final projects = await _projectRepository.getProjects(
        search: search,
        skip: skip,
        limit: limit,
      );
      state = state.copyWith(projects: projects, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<Project?> loadProjectById(int projectId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final project = await _projectRepository.getProjectById(projectId);
      state = state.copyWith(loading: false);
      return project;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<List<Project>> loadProjectsByClientId(int clientId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final projects = await _projectRepository.getProjectsByClientId(clientId);
      state = state.copyWith(loading: false);
      return projects;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return [];
    }
  }

  Future<Project?> createProject(ProjectCreate projectCreate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final project = await _projectRepository.createProject(projectCreate);
      // Add the new project to the list
      final updatedProjects = [...state.projects, project];
      state = state.copyWith(projects: updatedProjects, loading: false);
      return project;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Project?> updateProject(int projectId, ProjectUpdate projectUpdate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final project = await _projectRepository.updateProject(
        projectId,
        projectUpdate,
      );
      // Update the project in the list
      final updatedProjects =
          state.projects.map((p) => p.id == projectId ? project : p).toList();
      state = state.copyWith(projects: updatedProjects, loading: false);
      return project;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> deleteProject(int projectId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _projectRepository.deleteProject(projectId);
      // Remove the project from the list
      final updatedProjects =
          state.projects.where((p) => p.id != projectId).toList();
      state = state.copyWith(projects: updatedProjects, loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final _projectServiceProvider = Provider(
  (ref) => ProjectService(ref.read(apiServiceProvider)),
);
final _projectRepositoryProvider = Provider(
  (ref) => ProjectRepository(ref.read(_projectServiceProvider)),
);
final projectProvider = StateNotifierProvider<ProjectController, ProjectState>(
  (ref) => ProjectController(ref.read(_projectRepositoryProvider)),
);
