import '../../utils/json_helpers.dart';

class Invoice {
  final int id;
  final String invoiceNumber;
  final int projectId;
  final double amount;
  final double? taxAmount;
  final double totalAmount;
  final String status; // draft, sent, paid, overdue, cancelled
  final DateTime? dueDate;
  final DateTime? paidDate;
  final DateTime createdAt;
  final String? notes;
  final String? description;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.projectId,
    required this.amount,
    this.taxAmount,
    required this.totalAmount,
    required this.status,
    this.dueDate,
    this.paidDate,
    required this.createdAt,
    this.notes,
    this.description,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    // Backend uses 'subtotal', 'tax', 'total' not 'amount', 'tax_amount', 'total_amount'
    final amount = json['subtotal'] != null 
        ? (json['subtotal'] as num).toDouble() 
        : (json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0);
    
    final taxAmount = json['tax'] != null 
        ? (json['tax'] as num).toDouble() 
        : (json['tax_amount'] != null ? (json['tax_amount'] as num).toDouble() : null);
    
    final totalAmount = json['total'] != null 
        ? (json['total'] as num).toDouble() 
        : (json['total_amount'] != null 
            ? (json['total_amount'] as num).toDouble() 
            : amount + (taxAmount ?? 0.0));
    
    return Invoice(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      projectId: json['project_id'] as int,
      amount: amount,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      status: json['status'] as String,
      dueDate: parseDateTime(json['due_date']),
      paidDate: parseDateTime(json['paid_date']),
      createdAt: parseDateTime(json['created_at']) ?? DateTime.now(),
      notes: json['notes'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoice_number': invoiceNumber,
    'project_id': projectId,
    'amount': amount,
    'tax_amount': taxAmount,
    'total_amount': totalAmount,
    'status': status,
    'due_date': dueDate?.toIso8601String(),
    'paid_date': paidDate?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'notes': notes,
    'description': description,
  };

  bool get isOverdue {
    if (status == 'paid' || status == 'cancelled') return false;
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isPaid => status == 'paid';
  bool get isDraft => status == 'draft';
  bool get isSent => status == 'sent';
  bool get isCancelled => status == 'cancelled';
}
