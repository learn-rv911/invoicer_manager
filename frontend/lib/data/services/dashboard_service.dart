import 'package:dio/dio.dart';

import '../models/dashboard.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService;

  DashboardService(this._apiService);

  Future<DashboardSummary> getDashboardSummary({
    int days = 30,
    int? companyId,
    int? clientId,
    int? projectId,
  }) async {
    final Response response = await _apiService.dio.get(
      "/dashboard/summary",
      queryParameters: {
        "days": days,
        if (companyId != null) "company_id": companyId,
        if (clientId != null) "client_id": clientId,
        if (projectId != null) "project_id": projectId,
      },
    );
    return DashboardSummary.fromJson(response.data);
  }
}
