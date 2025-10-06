import 'package:dio/dio.dart';

import '../dtos/payment_create.dart';
import '../dtos/payment_update.dart';
import '../models/payment.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService;

  PaymentService(this._apiService);

  Future<List<Payment>> getPayments({
    int? invoiceId,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final Response response = await _apiService.dio.get(
        "/payments/",
        queryParameters: {
          if (invoiceId != null) "invoice_id": invoiceId,
          "skip": skip,
          "limit": limit,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Payment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to fetch payments"
              : "Failed to fetch payments";
      throw Exception(msg);
    }
  }

  Future<List<Payment>> getPaymentsByInvoice(int invoiceId) async {
    try {
      final Response response = await _apiService.dio.get(
        "/payments/",
        queryParameters: {
          "invoice_id": invoiceId,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Payment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to fetch payments for invoice"
              : "Failed to fetch payments for invoice";
      throw Exception(msg);
    }
  }

  Future<Payment> getPaymentById(int paymentId) async {
    try {
      final Response response = await _apiService.dio.get("/payments/$paymentId");
      return Payment.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ?? "Payment not found"
              : "Payment not found";
      throw Exception(msg);
    }
  }

  Future<Payment> createPayment(PaymentCreate paymentCreate) async {
    try {
      final Response response = await _apiService.dio.post(
        "/payments/",
        data: paymentCreate.toJson(),
      );
      return Payment.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to create payment"
              : "Failed to create payment";
      throw Exception(msg);
    }
  }

  Future<Payment> updatePayment(int paymentId, PaymentUpdate paymentUpdate) async {
    try {
      final Response response = await _apiService.dio.put(
        "/payments/$paymentId",
        data: paymentUpdate.toJson(),
      );
      return Payment.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to update payment"
              : "Failed to update payment";
      throw Exception(msg);
    }
  }

  Future<void> deletePayment(int paymentId) async {
    try {
      await _apiService.dio.delete("/payments/$paymentId");
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ??
                  "Failed to delete payment"
              : "Failed to delete payment";
      throw Exception(msg);
    }
  }
}

