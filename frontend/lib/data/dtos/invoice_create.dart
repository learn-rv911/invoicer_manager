class InvoiceCreate {
  final String invoiceNumber;
  final int clientId;
  final int projectId;
  final DateTime issueDate;
  final double amount;
  final double? taxAmount;
  final double totalAmount;
  final String status;
  final DateTime? dueDate;
  final String? notes;
  final String? description;

  InvoiceCreate({
    required this.invoiceNumber,
    required this.clientId,
    required this.projectId,
    required this.issueDate,
    required this.amount,
    this.taxAmount,
    required this.totalAmount,
    required this.status,
    this.dueDate,
    this.notes,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'invoice_number': invoiceNumber,
    'client_id': clientId,
    'project_id': projectId,
    'issue_date': issueDate.toIso8601String().split('T')[0],
    'subtotal': amount,  // Backend uses 'subtotal' not 'amount'
    if (taxAmount != null) 'tax': taxAmount,  // Backend uses 'tax' not 'tax_amount'
    'total': totalAmount,  // Backend uses 'total' not 'total_amount'
    'status': status,
    if (dueDate != null) 'due_date': dueDate!.toIso8601String().split('T')[0],
    if (notes != null) 'notes': notes,
    if (description != null) 'description': description,
  };
}
