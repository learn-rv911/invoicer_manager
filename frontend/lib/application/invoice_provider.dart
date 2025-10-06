import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:invoice/data/services/api_service.dart';

import '../data/dtos/invoice_create.dart';
import '../data/dtos/invoice_update.dart';
import '../data/models/invoice.dart';
import '../data/repositories/invoice_repository.dart';
import '../data/services/invoice_service.dart';

class InvoiceState {
  final List<Invoice> invoices;
  final bool loading;
  final String? error;

  InvoiceState({this.invoices = const [], this.loading = false, this.error});

  InvoiceState copyWith({List<Invoice>? invoices, bool? loading, String? error}) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class InvoiceController extends StateNotifier<InvoiceState> {
  final InvoiceRepository _invoiceRepository;

  InvoiceController(this._invoiceRepository) : super(InvoiceState());

  Future<void> loadInvoices({
    int? clientId,
    String? status,
    int skip = 0,
    int limit = 20,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final invoices = await _invoiceRepository.getInvoices(
        clientId: clientId,
        status: status,
        skip: skip,
        limit: limit,
      );
      state = state.copyWith(invoices: invoices, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadInvoicesByProject(int projectId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final invoices = await _invoiceRepository.getInvoicesByProject(projectId);
      state = state.copyWith(invoices: invoices, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<Invoice?> loadInvoiceById(int invoiceId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final invoice = await _invoiceRepository.getInvoiceById(invoiceId);
      state = state.copyWith(loading: false);
      return invoice;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Invoice?> createInvoice(InvoiceCreate invoiceCreate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final invoice = await _invoiceRepository.createInvoice(invoiceCreate);
      // Add the new invoice to the list
      final updatedInvoices = [...state.invoices, invoice];
      state = state.copyWith(invoices: updatedInvoices, loading: false);
      return invoice;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Invoice?> updateInvoice(int invoiceId, InvoiceUpdate invoiceUpdate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final invoice = await _invoiceRepository.updateInvoice(invoiceId, invoiceUpdate);
      // Update the invoice in the list
      final updatedInvoices = state.invoices
          .map((inv) => inv.id == invoiceId ? invoice : inv)
          .toList();
      state = state.copyWith(invoices: updatedInvoices, loading: false);
      return invoice;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> deleteInvoice(int invoiceId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _invoiceRepository.deleteInvoice(invoiceId);
      // Remove the invoice from the list
      final updatedInvoices = state.invoices
          .where((inv) => inv.id != invoiceId)
          .toList();
      state = state.copyWith(invoices: updatedInvoices, loading: false);
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
final _invoiceServiceProvider = Provider(
  (ref) => InvoiceService(ref.read(apiServiceProvider)),
);
final _invoiceRepositoryProvider = Provider(
  (ref) => InvoiceRepository(ref.read(_invoiceServiceProvider)),
);
final invoiceProvider = StateNotifierProvider<InvoiceController, InvoiceState>(
  (ref) => InvoiceController(ref.read(_invoiceRepositoryProvider)),
);
