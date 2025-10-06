import '../dtos/company_create.dart';
import '../dtos/company_update.dart';
import '../models/company.dart';
import '../services/company_service.dart';

class CompanyRepository {
  final CompanyService _companyService;

  CompanyRepository(this._companyService);

  Future<List<Company>> getCompanies({
    String? search,
    int skip = 0,
    int limit = 20,
  }) {
    return _companyService.getCompanies(
      search: search,
      skip: skip,
      limit: limit,
    );
  }

  Future<Company> getCompanyById(int companyId) {
    return _companyService.getCompanyById(companyId);
  }

  Future<Company> createCompany(CompanyCreate companyCreate) {
    return _companyService.createCompany(companyCreate);
  }

  Future<Company> updateCompany(int companyId, CompanyUpdate companyUpdate) {
    return _companyService.updateCompany(companyId, companyUpdate);
  }

  Future<void> deleteCompany(int companyId) {
    return _companyService.deleteCompany(companyId);
  }
}
