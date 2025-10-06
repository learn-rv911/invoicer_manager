import '../../utils/json_helpers.dart';

class Payment {
  final int id;
  final int invoiceId;
  final int projectId;
  final String? paymentNumber;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod; // cash, cheque, bank_transfer, upi, card, other
  final String? referenceNumber;
  final String? bankName;
  final String? notes;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.projectId,
    this.paymentNumber,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.bankName,
    this.notes,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Backend uses 'method' not 'payment_method'
    final method = json['method'] as String? ?? json['payment_method'] as String? ?? 'cash';
    
    return Payment(
      id: json['id'] as int,
      invoiceId: json['invoice_id'] as int,
      projectId: json['project_id'] as int? ?? 0,
      paymentNumber: json['payment_number'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      paymentDate: parseDateTime(json['payment_date']) ?? DateTime.now(),
      paymentMethod: method,
      // Backend uses 'transaction_no' not 'reference_number'
      referenceNumber: json['transaction_no'] as String? ?? json['reference_number'] as String?,
      // Backend uses 'bank' not 'bank_name'
      bankName: json['bank'] as String? ?? json['bank_name'] as String?,
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoice_id': invoiceId,
    'project_id': projectId,
    if (paymentNumber != null) 'payment_number': paymentNumber,
    'amount': amount,
    'payment_date': paymentDate.toIso8601String(),
    'payment_method': paymentMethod,
    if (referenceNumber != null) 'reference_number': referenceNumber,
    if (bankName != null) 'bank_name': bankName,
    if (notes != null) 'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  String get paymentMethodDisplayName {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'cheque':
        return 'Cheque';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'upi':
        return 'UPI';
      case 'card':
        return 'Card';
      case 'other':
        return 'Other';
      default:
        return paymentMethod;
    }
  }
}

