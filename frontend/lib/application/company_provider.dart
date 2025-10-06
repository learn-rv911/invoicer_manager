import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:invoice/data/services/api_service.dart';

import '../data/dtos/company_create.dart';
import '../data/dtos/company_update.dart';
import '../data/models/company.dart';
import '../data/repositories/company_repository.dart';
import '../data/services/company_service.dart';

class CompanyState {
  final List<Company> companies;
  final bool loading;
  final String? error;

  CompanyState({this.companies = const [], this.loading = false, this.error});

  CompanyState copyWith({
    List<Company>? companies,
    bool? loading,
    String? error,
  }) {
    return CompanyState(
      companies: companies ?? this.companies,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class CompanyController extends StateNotifier<CompanyState> {
  final CompanyRepository _companyRepository;

  CompanyController(this._companyRepository) : super(CompanyState());

  Future<void> loadCompanies({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final companies = await _companyRepository.getCompanies(
        search: search,
        skip: skip,
        limit: limit,
      );
      state = state.copyWith(companies: companies, loading: false);
    } catch (e) {
      state = CompanyState(loading: false, error: e.toString());
    }
  }

  Future<Company?> loadCompanyById(int companyId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final company = await _companyRepository.getCompanyById(companyId);
      state = state.copyWith(loading: false);
      return company;
      // Update the companies list with the fetched company
      // final updatedCompanies =
      //     state.companies.map((c) => c.id == companyId ? company : c).toList();
      // if (!updatedCompanies.any((c) => c.id == companyId)) {
      //   updatedCompanies.add(company);
      // }
      // state = state.copyWith(companies: updatedCompanies, loading: false);
    } catch (e) {
      state = CompanyState(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Company?> createCompany(CompanyCreate companyCreate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final company = await _companyRepository.createCompany(companyCreate);
      // Add the new company to the list
      final updatedCompanies = [...state.companies, company];
      state = state.copyWith(companies: updatedCompanies, loading: false);
      return company;
    } catch (e) {
      state = CompanyState(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Company?> updateCompany(int companyId, CompanyUpdate companyUpdate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final company = await _companyRepository.updateCompany(companyId, companyUpdate);
      // Update the company in the list
      final updatedCompanies = state.companies
          .map((c) => c.id == companyId ? company : c)
          .toList();
      state = state.copyWith(companies: updatedCompanies, loading: false);
      return company;
    } catch (e) {
      state = CompanyState(loading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> deleteCompany(int companyId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _companyRepository.deleteCompany(companyId);
      // Remove the company from the list
      final updatedCompanies = state.companies
          .where((c) => c.id != companyId)
          .toList();
      state = state.copyWith(companies: updatedCompanies, loading: false);
      return true;
    } catch (e) {
      state = CompanyState(loading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final _companyServiceProvider = Provider(
  (ref) => CompanyService(ref.read(apiServiceProvider)),
);
final _companyRepositoryProvider = Provider(
  (ref) => CompanyRepository(ref.read(_companyServiceProvider)),
);
final companyProvider = StateNotifierProvider<CompanyController, CompanyState>(
  (ref) => CompanyController(ref.read(_companyRepositoryProvider)),
);
