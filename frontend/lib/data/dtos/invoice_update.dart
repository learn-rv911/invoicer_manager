class InvoiceUpdate {
  final String? invoiceNumber;
  final int? clientId;
  final int? projectId;
  final DateTime? issueDate;
  final double? amount;
  final double? taxAmount;
  final double? totalAmount;
  final String? status;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String? notes;
  final String? description;

  InvoiceUpdate({
    this.invoiceNumber,
    this.clientId,
    this.projectId,
    this.issueDate,
    this.amount,
    this.taxAmount,
    this.totalAmount,
    this.status,
    this.dueDate,
    this.paidDate,
    this.notes,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (invoiceNumber != null) json['invoice_number'] = invoiceNumber;
    if (clientId != null) json['client_id'] = clientId;
    if (projectId != null) json['project_id'] = projectId;
    if (issueDate != null) json['issue_date'] = issueDate!.toIso8601String().split('T')[0];
    if (amount != null) json['subtotal'] = amount;  // Backend uses 'subtotal'
    if (taxAmount != null) json['tax'] = taxAmount;  // Backend uses 'tax'
    if (totalAmount != null) json['total'] = totalAmount;  // Backend uses 'total'
    if (status != null) json['status'] = status;
    if (dueDate != null) json['due_date'] = dueDate!.toIso8601String().split('T')[0];
    if (paidDate != null) json['paid_date'] = paidDate!.toIso8601String().split('T')[0];
    if (notes != null) json['notes'] = notes;
    if (description != null) json['description'] = description;
    return json;
  }
}
