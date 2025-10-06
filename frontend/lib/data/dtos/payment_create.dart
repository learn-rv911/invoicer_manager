class PaymentCreate {
  final int invoiceId;
  final int projectId;
  final String? paymentNumber;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? referenceNumber;
  final String? bankName;
  final String? notes;

  PaymentCreate({
    required this.invoiceId,
    required this.projectId,
    this.paymentNumber,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.bankName,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'invoice_id': invoiceId,
      'project_id': projectId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'method': paymentMethod,  // Backend uses 'method' not 'payment_method'
    };
    
    // Only include optional fields if they have values
    if (paymentNumber != null && paymentNumber!.isNotEmpty) {
      json['payment_number'] = paymentNumber;
    }
    if (referenceNumber != null && referenceNumber!.isNotEmpty) {
      json['transaction_no'] = referenceNumber;  // Backend uses 'transaction_no'
    }
    if (bankName != null && bankName!.isNotEmpty) {
      json['bank'] = bankName;  // Backend uses 'bank' not 'bank_name'
    }
    if (notes != null && notes!.isNotEmpty) {
      json['notes'] = notes;
    }
    
    return json;
  }
}

