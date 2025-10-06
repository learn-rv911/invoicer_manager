import '../dtos/invoice_create.dart';
import '../dtos/invoice_update.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';

class InvoiceRepository {
  final InvoiceService _service;

  InvoiceRepository(this._service);

  Future<List<Invoice>> getInvoices({
    int? clientId,
    String? status,
    int skip = 0,
    int limit = 20,
  }) async {
    return await _service.getInvoices(
      clientId: clientId,
      status: status,
      skip: skip,
      limit: limit,
    );
  }

  Future<List<Invoice>> getInvoicesByProject(int projectId) async {
    return await _service.getInvoicesByProject(projectId);
  }

  Future<Invoice> getInvoiceById(int invoiceId) async {
    return await _service.getInvoiceById(invoiceId);
  }

  Future<Invoice> createInvoice(InvoiceCreate invoiceCreate) async {
    return await _service.createInvoice(invoiceCreate);
  }

  Future<Invoice> updateInvoice(int invoiceId, InvoiceUpdate invoiceUpdate) async {
    return await _service.updateInvoice(invoiceId, invoiceUpdate);
  }

  Future<void> deleteInvoice(int invoiceId) async {
    await _service.deleteInvoice(invoiceId);
  }
}
