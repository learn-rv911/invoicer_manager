import 'package:dio/dio.dart';

import '../dtos/invoice_create.dart';
import '../dtos/invoice_update.dart';
import '../models/invoice.dart';
import 'api_service.dart';

class InvoiceService {
  final ApiService _apiService;

  InvoiceService(this._apiService);

  Future<List<Invoice>> getInvoices({
    int? clientId,
    String? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final Response response = await _apiService.dio.get(
        "/invoices/",
        queryParameters: {
          if (clientId != null) "client_id": clientId,
          if (status != null) "status": status,
          "skip": skip,
          "limit": limit,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to fetch invoices"
              : "Failed to fetch invoices";
      throw Exception(msg);
    }
  }

  Future<List<Invoice>> getInvoicesByProject(int projectId) async {
    try {
      final Response response = await _apiService.dio.get(
        "/invoices/",
        queryParameters: {
          "project_id": projectId,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to fetch invoices for project"
              : "Failed to fetch invoices for project";
      throw Exception(msg);
    }
  }

  Future<Invoice> getInvoiceById(int invoiceId) async {
    try {
      final Response response = await _apiService.dio.get("/invoices/$invoiceId");
      return Invoice.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ?? "Invoice not found"
              : "Invoice not found";
      throw Exception(msg);
    }
  }

  Future<Invoice> createInvoice(InvoiceCreate invoiceCreate) async {
    try {
      final Response response = await _apiService.dio.post(
        "/invoices/",
        data: invoiceCreate.toJson(),
      );
      return Invoice.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to create invoice"
              : "Failed to create invoice";
      throw Exception(msg);
    }
  }

  Future<Invoice> updateInvoice(int invoiceId, InvoiceUpdate invoiceUpdate) async {
    try {
      final Response response = await _apiService.dio.put(
        "/invoices/$invoiceId",
        data: invoiceUpdate.toJson(),
      );
      return Invoice.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to update invoice"
              : "Failed to update invoice";
      throw Exception(msg);
    }
  }

  Future<void> deleteInvoice(int invoiceId) async {
    try {
      await _apiService.dio.delete("/invoices/$invoiceId");
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to delete invoice"
              : "Failed to delete invoice";
      throw Exception(msg);
    }
  }
}
