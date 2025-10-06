import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:invoice/data/services/api_service.dart';

import '../data/dtos/payment_create.dart';
import '../data/dtos/payment_update.dart';
import '../data/models/payment.dart';
import '../data/repositories/payment_repository.dart';
import '../data/services/payment_service.dart';

class PaymentState {
  final List<Payment> payments;
  final bool loading;
  final String? error;

  PaymentState({this.payments = const [], this.loading = false, this.error});

  PaymentState copyWith({List<Payment>? payments, bool? loading, String? error}) {
    return PaymentState(
      payments: payments ?? this.payments,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class PaymentController extends StateNotifier<PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentController(this._paymentRepository) : super(PaymentState());

  Future<void> loadPayments({
    int? invoiceId,
    int skip = 0,
    int limit = 20,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final payments = await _paymentRepository.getPayments(
        invoiceId: invoiceId,
        skip: skip,
        limit: limit,
      );
      state = state.copyWith(payments: payments, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadPaymentsByInvoice(int invoiceId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final payments = await _paymentRepository.getPaymentsByInvoice(invoiceId);
      state = state.copyWith(payments: payments, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<Payment?> loadPaymentById(int paymentId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final payment = await _paymentRepository.getPaymentById(paymentId);
      state = state.copyWith(loading: false);
      return payment;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Payment?> createPayment(PaymentCreate paymentCreate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final payment = await _paymentRepository.createPayment(paymentCreate);
      // Add the new payment to the list
      final updatedPayments = [...state.payments, payment];
      state = state.copyWith(payments: updatedPayments, loading: false);
      return payment;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Payment?> updatePayment(int paymentId, PaymentUpdate paymentUpdate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final payment = await _paymentRepository.updatePayment(paymentId, paymentUpdate);
      // Update the payment in the list
      final updatedPayments = state.payments
          .map((pay) => pay.id == paymentId ? payment : pay)
          .toList();
      state = state.copyWith(payments: updatedPayments, loading: false);
      return payment;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> deletePayment(int paymentId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _paymentRepository.deletePayment(paymentId);
      // Remove the payment from the list
      final updatedPayments = state.payments
          .where((pay) => pay.id != paymentId)
          .toList();
      state = state.copyWith(payments: updatedPayments, loading: false);
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
final _paymentServiceProvider = Provider(
  (ref) => PaymentService(ref.read(apiServiceProvider)),
);
final _paymentRepositoryProvider = Provider(
  (ref) => PaymentRepository(ref.read(_paymentServiceProvider)),
);
final paymentProvider = StateNotifierProvider<PaymentController, PaymentState>(
  (ref) => PaymentController(ref.read(_paymentRepositoryProvider)),
);

