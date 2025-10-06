import 'package:dio/dio.dart';

import '../dtos/project_create.dart';
import '../dtos/project_update.dart';
import '../models/project.dart';
import 'api_service.dart';

class ProjectService {
  final ApiService _apiService;

  ProjectService(this._apiService);

  Future<List<Project>> getProjects({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final Response response = await _apiService.dio.get(
        "/projects/",
        queryParameters: {
          if (search != null) "q": search,
          "skip": skip,
          "limit": limit,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to fetch projects"
              : "Failed to fetch projects";
      throw Exception(msg);
    }
  }

  Future<Project> getProjectById(int projectId) async {
    try {
      final Response response = await _apiService.dio.get("/projects/$projectId");
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ?? "Project not found"
              : "Project not found";
      throw Exception(msg);
    }
  }

  Future<List<Project>> getProjectsByClientId(int clientId) async {
    try {
      final Response response = await _apiService.dio.get(
        "/projects/",
        queryParameters: {
          "client_id": clientId,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to fetch projects for client"
              : "Failed to fetch projects for client";
      throw Exception(msg);
    }
  }

  Future<Project> createProject(ProjectCreate projectCreate) async {
    try {
      final Response response = await _apiService.dio.post(
        "/projects/",
        data: projectCreate.toJson(),
      );
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to create project"
              : "Failed to create project";
      throw Exception(msg);
    }
  }

  Future<Project> updateProject(int projectId, ProjectUpdate projectUpdate) async {
    try {
      final Response response = await _apiService.dio.put(
        "/projects/$projectId",
        data: projectUpdate.toJson(),
      );
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to update project"
              : "Failed to update project";
      throw Exception(msg);
    }
  }

  Future<void> deleteProject(int projectId) async {
    try {
      await _apiService.dio.delete("/projects/$projectId");
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to delete project"
              : "Failed to delete project";
      throw Exception(msg);
    }
  }
}
