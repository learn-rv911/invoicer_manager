import '../models/dashboard.dart';
import '../services/dashboard_service.dart';

class DashboardRepository {
  final DashboardService _service;

  DashboardRepository(this._service);

  Future<DashboardSummary> getDashboardSummary({
    int days = 30,
    int? companyId,
    int? clientId,
    int? projectId,
  }) {
    return _service.getDashboardSummary(
      days: days,
      companyId: companyId,
      clientId: clientId,
      projectId: projectId,
    );
  }
}
