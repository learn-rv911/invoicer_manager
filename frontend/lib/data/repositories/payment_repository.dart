import '../dtos/payment_create.dart';
import '../dtos/payment_update.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _paymentService;

  PaymentRepository(this._paymentService);

  Future<List<Payment>> getPayments({
    int? invoiceId,
    int skip = 0,
    int limit = 20,
  }) async {
    return await _paymentService.getPayments(
      invoiceId: invoiceId,
      skip: skip,
      limit: limit,
    );
  }

  Future<List<Payment>> getPaymentsByInvoice(int invoiceId) async {
    return await _paymentService.getPaymentsByInvoice(invoiceId);
  }

  Future<Payment> getPaymentById(int paymentId) async {
    return await _paymentService.getPaymentById(paymentId);
  }

  Future<Payment> createPayment(PaymentCreate paymentCreate) async {
    return await _paymentService.createPayment(paymentCreate);
  }

  Future<Payment> updatePayment(int paymentId, PaymentUpdate paymentUpdate) async {
    return await _paymentService.updatePayment(paymentId, paymentUpdate);
  }

  Future<void> deletePayment(int paymentId) async {
    return await _paymentService.deletePayment(paymentId);
  }
}

