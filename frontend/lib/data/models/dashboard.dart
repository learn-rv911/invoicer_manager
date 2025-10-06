class DashboardMetrics {
  final int totalInvoices;
  final double totalAmount;
  final double totalPaid;
  final double outstanding;

  DashboardMetrics({
    required this.totalInvoices,
    required this.totalAmount,
    required this.totalPaid,
    required this.outstanding,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> j) {
    return DashboardMetrics(
      totalInvoices: j['total_invoices'] ?? 0,
      totalAmount: (j['total_amount'] ?? 0).toDouble(),
      totalPaid: (j['total_paid'] ?? 0).toDouble(),
      outstanding: (j['outstanding'] ?? 0).toDouble(),
    );
  }
}

class DashboardSummary {
  final DashboardMetrics metrics;
  final List<Map<String, dynamic>> recentInvoices;
  final List<Map<String, dynamic>> recentPayments;

  DashboardSummary({
    required this.metrics,
    required this.recentInvoices,
    required this.recentPayments,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) {
    return DashboardSummary(
      metrics: DashboardMetrics.fromJson(j['metrics']),
      recentInvoices: List<Map<String, dynamic>>.from(j['recent_invoices']),
      recentPayments: List<Map<String, dynamic>>.from(j['recent_payments']),
    );
  }
}
