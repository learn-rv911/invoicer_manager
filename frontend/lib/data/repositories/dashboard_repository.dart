import 'package:dio/dio.dart';

import '../models/dashboard.dart';
import '../services/dashboard_service.dart';

class DashboardRepository {
  final DashboardService _service;

  DashboardRepository(this._service);

  Future<DashboardSummary> getDashboardSummary({
    int days = 30,
    String? fromDate,
    String? toDate,
    int? companyId,
    int? clientId,
    int? projectId,
  }) {
    return _service.getDashboardSummary(
      days: days,
      fromDate: fromDate,
      toDate: toDate,
      companyId: companyId,
      clientId: clientId,
      projectId: projectId,
    );
  }

  Future<Response> exportDashboard({
    required String format,
    String? fromDate,
    String? toDate,
    int? companyId,
    int? clientId,
    int? projectId,
  }) {
    return _service.exportDashboard(
      format: format,
      fromDate: fromDate,
      toDate: toDate,
      companyId: companyId,
      clientId: clientId,
      projectId: projectId,
    );
  }
}
