import 'package:dio/dio.dart';

import '../dtos/client_create.dart';
import '../dtos/client_update.dart';
import '../models/client.dart';
import 'api_service.dart';

class ClientService {
  final ApiService _apiService;

  ClientService(this._apiService);

  Future<List<Client>> getClients({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final Response response = await _apiService.dio.get(
        "/clients/",
        queryParameters: {
          if (search != null) "q": search,
          "skip": skip,
          "limit": limit,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Client.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to fetch clients"
              : "Failed to fetch clients";
      throw Exception(msg);
    }
  }

  Future<Client> getClientById(int clientId) async {
    try {
      final Response response = await _apiService.dio.get("/clients/$clientId");
      return Client.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ?? "Client not found"
              : "Client not found";
      throw Exception(msg);
    }
  }

  Future<Client> createClient(ClientCreate clientCreate) async {
    try {
      final Response response = await _apiService.dio.post(
        "/clients/",
        data: clientCreate.toJson(),
      );
      return Client.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to create client"
              : "Failed to create client";
      throw Exception(msg);
    }
  }

  Future<Client> updateClient(int clientId, ClientUpdate clientUpdate) async {
    try {
      final Response response = await _apiService.dio.put(
        "/clients/$clientId",
        data: clientUpdate.toJson(),
      );
      return Client.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to update client"
              : "Failed to update client";
      throw Exception(msg);
    }
  }

  Future<void> deleteClient(int clientId) async {
    try {
      await _apiService.dio.delete("/clients/$clientId");
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to delete client"
              : "Failed to delete client";
      throw Exception(msg);
    }
  }
}
