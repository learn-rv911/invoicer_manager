class PaymentUpdate {
  final int? invoiceId;
  final int? projectId;
  final String? paymentNumber;
  final double? amount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? referenceNumber;
  final String? bankName;
  final String? notes;

  PaymentUpdate({
    this.invoiceId,
    this.projectId,
    this.paymentNumber,
    this.amount,
    this.paymentDate,
    this.paymentMethod,
    this.referenceNumber,
    this.bankName,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (invoiceId != null) json['invoice_id'] = invoiceId;
    if (projectId != null) json['project_id'] = projectId;
    if (paymentNumber != null) json['payment_number'] = paymentNumber;
    if (amount != null) json['amount'] = amount;
    if (paymentDate != null) json['payment_date'] = paymentDate!.toIso8601String().split('T')[0];
    if (paymentMethod != null) json['method'] = paymentMethod;  // Backend uses 'method'
    if (referenceNumber != null) json['transaction_no'] = referenceNumber;  // Backend uses 'transaction_no'
    if (bankName != null) json['bank'] = bankName;  // Backend uses 'bank'
    if (notes != null) json['notes'] = notes;
    return json;
  }
}

