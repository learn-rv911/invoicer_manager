import 'package:dio/dio.dart';

import '../dtos/company_create.dart';
import '../dtos/company_update.dart';
import '../models/company.dart';
import 'api_service.dart';

class CompanyService {
  final ApiService _apiService;

  CompanyService(this._apiService);

  Future<List<Company>> getCompanies({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final Response response = await _apiService.dio.get(
        "/companies/",
        queryParameters: {
          if (search != null) "q": search,
          "skip": skip,
          "limit": limit,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Company.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to fetch companies"
              : "Failed to fetch companies";
      throw Exception(msg);
    }
  }

  Future<Company> getCompanyById(int companyId) async {
    try {
      final Response response = await _apiService.dio.get(
        "/companies/$companyId",
      );
      return Company.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ?? "Company not found"
              : "Company not found";
      throw Exception(msg);
    }
  }

  Future<Company> createCompany(CompanyCreate companyCreate) async {
    try {
      final Response response = await _apiService.dio.post(
        "/companies/",
        data: companyCreate.toJson(),
      );
      return Company.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to create company"
              : "Failed to create company";
      throw Exception(msg);
    }
  }

  Future<Company> updateCompany(int companyId, CompanyUpdate companyUpdate) async {
    try {
      final Response response = await _apiService.dio.put(
        "/companies/$companyId",
        data: companyUpdate.toJson(),
      );
      return Company.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to update company"
              : "Failed to update company";
      throw Exception(msg);
    }
  }

  Future<void> deleteCompany(int companyId) async {
    try {
      await _apiService.dio.delete("/companies/$companyId");
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to delete company"
              : "Failed to delete company";
      throw Exception(msg);
    }
  }
}
