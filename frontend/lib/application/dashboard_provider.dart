import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:invoice/data/models/dashboard.dart';

import '../data/repositories/dashboard_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/dashboard_service.dart';

class DashboardState {
  final DashboardSummary? summary;
  final bool loading;
  final String? error;

  // filters
  final int days;
  final String? fromDate;
  final String? toDate;
  final int? companyId;
  final int? clientId;
  final int? projectId;

  DashboardState({
    this.summary,
    this.loading = false,
    this.error,
    this.days = 30,
    this.fromDate,
    this.toDate,
    this.companyId,
    this.clientId,
    this.projectId,
  });

  DashboardState copyWith({
    DashboardSummary? summary,
    bool? loading,
    String? error,
    int? days,
    String? fromDate,
    String? toDate,
    int? companyId,
    int? clientId,
    int? projectId,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      loading: loading ?? this.loading,
      error: error,
      days: days ?? this.days,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      companyId: companyId ?? this.companyId,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  Timer? _debounceTimer;

  DashboardController(this._repository) : super(DashboardState());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _repository.getDashboardSummary(
        days: state.days,
        fromDate: state.fromDate,
        toDate: state.toDate,
        companyId: state.companyId,
        clientId: state.clientId,
        projectId: state.projectId,
      );
      state = state.copyWith(summary: data, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void _debouncedLoad() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      load();
    });
  }

  void setDays(int days) {
    state = state.copyWith(days: days);
    _debouncedLoad();
  }

  void setDateRange({String? fromDate, String? toDate}) {
    state = state.copyWith(fromDate: fromDate, toDate: toDate);
    _debouncedLoad();
  }

  void setFilters({int? companyId, int? clientId, int? projectId}) {
    state = state.copyWith(
      companyId: companyId,
      clientId: clientId,
      projectId: projectId,
    );
    _debouncedLoad();
  }

  Future<Response> exportDashboard(String format) {
    return _repository.exportDashboard(
      format: format,
      fromDate: state.fromDate,
      toDate: state.toDate,
      companyId: state.companyId,
      clientId: state.clientId,
      projectId: state.projectId,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final dashboardServiceProvider = Provider(
  (ref) => DashboardService(ref.read(apiServiceProvider)),
);
final dashboardRepositoryProvider = Provider(
  (ref) => DashboardRepository(ref.read(dashboardServiceProvider)),
);
final dashboardProvider =
    StateNotifierProvider<DashboardController, DashboardState>(
      (ref) => DashboardController(ref.read(dashboardRepositoryProvider)),
    );
