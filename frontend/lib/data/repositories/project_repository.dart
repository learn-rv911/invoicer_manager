import '../dtos/project_create.dart';
import '../dtos/project_update.dart';
import '../models/project.dart';
import '../services/project_service.dart';

class ProjectRepository {
  final ProjectService _projectService;

  ProjectRepository(this._projectService);

  Future<List<Project>> getProjects({
    String? search,
    int skip = 0,
    int limit = 20,
  }) {
    return _projectService.getProjects(search: search, skip: skip, limit: limit);
  }

  Future<Project> getProjectById(int projectId) {
    return _projectService.getProjectById(projectId);
  }

  Future<List<Project>> getProjectsByClientId(int clientId) {
    return _projectService.getProjectsByClientId(clientId);
  }

  Future<Project> createProject(ProjectCreate projectCreate) {
    return _projectService.createProject(projectCreate);
  }

  Future<Project> updateProject(int projectId, ProjectUpdate projectUpdate) {
    return _projectService.updateProject(projectId, projectUpdate);
  }

  Future<void> deleteProject(int projectId) {
    return _projectService.deleteProject(projectId);
  }
}
